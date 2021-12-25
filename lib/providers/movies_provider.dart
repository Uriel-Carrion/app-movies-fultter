// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas_app/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  final String _apiKey = "d74315408b0a4b9fc67b132af1237b3b";
  final String _baseUrl = "api.themoviedb.org";
  final String _language = "es-Es";

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> movieCast = {};

  int _popularPage = 0;

  MoviesProvider() {
    print('Provider movies inicializado');
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String endPoint, [int page = 1]) async {
    var url = Uri.https(_baseUrl, endPoint,
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
}
