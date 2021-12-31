// ignore_for_file: avoid_print
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas_app/helpers/debouncer.dart';
import 'package:peliculas_app/models/models.dart';
import 'package:peliculas_app/models/search_movie_response.dart';

class MoviesProvider extends ChangeNotifier {
  final String _apiKey = "api";
  final String _baseUrl = "api.themoviedb.org";
  final String _language = "es-Es";

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  List<Movie> topRatedMovies = [];

  Map<int, List<Cast>> movieCast = {};

  int _popularPage = 0;
  int _topRatedPage = 0;

  final debouncer = Debouncer(duration: Duration(milliseconds: 500));

  final StreamController<List<Movie>> _suggestionStreamController =
      new StreamController.broadcast();

  Stream<List<Movie>> get suggestionStream =>
      this._suggestionStreamController.stream;

  MoviesProvider() {
    print('Provider movies inicializado');
    getOnDisplayMovies();
    getPopularMovies();
    getTopRatedMovies();
  }

  Future<String> _getJsonData(String endPoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endPoint,
        {'api_key': _apiKey, 'language': _language, 'page': '$page'});

    // Await the http get response, then decode the json-formatted response.
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponde = NowPayingResponse.fromJson(jsonData);

    onDisplayMovies = nowPlayingResponde.results;
    //Notifica el cambio en otras pantallas
    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;
    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);

    popularMovies = [...popularMovies, ...popularResponse.results];
    //Notifica el cambio en otras pantallas
    notifyListeners();
  }

  getTopRatedMovies() async {
    _topRatedPage++;
    final jsonData = await _getJsonData('3/movie/top_rated', _topRatedPage);
    final popularResponse = PopularResponse.fromJson(jsonData);
    topRatedMovies = [...topRatedMovies, ...popularResponse.results];
    //Notifica el cambio en otras pantallas
    notifyListeners();
  }

  Future<List<Cast>> getMoviCast(int id) async {
    //Se revisa si el id ya existe en el storage
    if (movieCast.containsKey(id)) return movieCast[id]!;
    print("Petición");
    final jsonData = await _getJsonData('3/movie/$id/credits');
    final credistResponse = CreditsResponse.fromJson(jsonData);
    //Se almacena en el mapa
    movieCast[id] = credistResponse.cast;

    return credistResponse.cast;
  }

  // Método que busca peliculas por el nombre
  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(_baseUrl, "3/search/movie",
        {'api_key': _apiKey, 'language': _language, 'query': query});

    final response = await http.get(url);
    final searchResponse = SearchMovieResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      print("Tenemos un valor $value");
      final results = await this.searchMovies(value);
      this._suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
  }
}
