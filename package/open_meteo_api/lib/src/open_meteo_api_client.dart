import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models/models.dart';

/// Exception thrown when locationSearch fails.
class LocationRequestFailure implements Exception {}

/// Exception thrown when the provided location is not found.
class LocationNotFoundFailure implements Exception {}

/// Exception thrown when getWeather fails.
class WeatherRequestFailure implements Exception {}

/// Exception thrown when weather for provided location is not found.
class WeatherNotFoundFailure implements Exception {}

class OpenMeteoApiClient {
  OpenMeteoApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrlGeocoding = 'geocoding-api.open-meteo.com';
  static const _baseUrlWeather = 'api.open-meteo.com';

  final http.Client _httpClient;

  Future<Location> findLocation(String query) async {
    final locationRequest = Uri.https(
        _baseUrlGeocoding, '/v1/search', {'name': query, 'count': '1'});
    final locationResponse = await _httpClient.get(locationRequest);

    if (locationResponse.statusCode != 200) {
      throw LocationRequestFailure();
    }
    final locationBody = jsonDecode(locationResponse.body) as Map;

    if (!locationBody.containsKey('results')) throw LocationNotFoundFailure();

    final results = locationBody['results'] as List;

    if (results.isEmpty) throw LocationNotFoundFailure();

    return Location.fromJson(results.first as Map<String, dynamic>);
  }

  Future<Weather> getWeather(
      {required double latitude, required double longitude}) async {
    final weatherRequest = Uri.https(_baseUrlWeather, '/v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current_weather': 'true',
    });

    final response = await _httpClient.get(weatherRequest);

    if (response.statusCode != 200) throw WeatherRequestFailure();

    final weatherBody = jsonDecode(response.body) as Map<String ,dynamic>;

    if (!weatherBody.containsKey('current_weather')) {
      throw WeatherNotFoundFailure();
    }
    
    final weatherJson = weatherBody [ 'current_weather'] as Map<String,dynamic>;
  
    return Weather.fromJson(weatherJson);
  }
}
