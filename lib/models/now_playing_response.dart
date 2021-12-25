// To parse this JSON data, do
//
//     final nowPayingResponse = nowPayingResponseFromMap(jsonString);

import 'dart:convert';

import 'package:peliculas_app/models/movie.dart';

class NowPayingResponse {
  NowPayingResponse({
    required this.dates,
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  Dates dates;
  int page;
  List<Movie> results;
  int totalPages;
  int totalResults;

  factory NowPayingResponse.fromJson(String str) =>
      NowPayingResponse.fromMap(json.decode(str));

  factory NowPayingResponse.fromMap(Map<String, dynamic> json) =>
      NowPayingResponse(
        dates: Dates.fromMap(json["dates"]),
        page: json["page"],
        results: List<Movie>.from(json["results"].map((x) => Movie.fromMap(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );
}

class Dates {
  Dates({
    required this.maximum,
    required this.minimum,
  });

  DateTime maximum;
  DateTime minimum;

  factory Dates.fromJson(String str) => Dates.fromMap(json.decode(str));

  factory Dates.fromMap(Map<String, dynamic> json) => Dates(
        maximum: DateTime.parse(json["maximum"]),
        minimum: DateTime.parse(json["minimum"]),
      );
}
