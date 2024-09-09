import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  group('OpenMeteoApiClient', () {
    late http.Client httpClient;
    late OpenMeteoApiClient apiClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      apiClient = OpenMeteoApiClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('not require httpClient', () {
        expect(OpenMeteoApiClient(), isNotNull);
      });
    });

    group('location test', () {
      const query = 'mock-query';
      test('make a correct http request', ()async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
         await apiClient.findLocation(query);
        } catch (_) {}
        verify(
          ()async =>await httpClient.get(Uri.https(
            'geocoding-api.open-meteo.com',
            '/v1/search',
            <String, String>{'name': query, 'count': '1'},
          )),
        ).called(1);
      });
      test('threw LocationRequestFailure when response != 200', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => await apiClient.findLocation(query),
          throwsA(isA<LocationRequestFailure>()),
        );
      });
      test('threw LocationNotFoundFailure when body is empty', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        await expectLater(apiClient.findLocation(query),
            throwsA(isA<LocationNotFoundFailure>()));
      });

      test('threw LocationNotFoundFailure when results is empty', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{"results":[]}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        await expectLater(apiClient.findLocation(query),
            throwsA(isA<LocationNotFoundFailure>()));
      });

      test('return location with valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('''
              {
                "results":[
                  {
                  "id": 4887398,
                  "name": "Chicago",
                  "latitude": 41.85003,
                  "longitude": -87.65005
                  }
                    ]
              }
          ''');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final goodResponse = await apiClient.findLocation(query);
        expect(
          goodResponse,
          isA<Location>()
              .having((location) => location.id, 'id', 4887398)
              .having((location) => location.name, 'name', 'Chicago')
              .having((location) => location.latitude, 'latitude', 41.85003)
              .having((location) => location.longitude, 'longitude', -87.65005),
        );
      });
    });

    group('test weather', () {
      const longitude = 41.85003;
      const latitude = -87.65005;

      test('make a correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await apiClient.getWeather(latitude: latitude, longitude: longitude);
        } catch (_) {}

        verify(() =>
            httpClient.get(Uri.https('api.open-meteo.com', '/v1/forecast', {
              'latitude': '$latitude',
              'longitude': '$longitude',
              'current_weather': 'true',
            }))).called(1);
      });

      test('throw WeatherRequestFailure response != 200', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        expect(
            () async =>
               await apiClient.getWeather(latitude: latitude, longitude: longitude),
            throwsA(isA<WeatherRequestFailure>()));
      });
      test('throw WeatherNotFoundFailure current_weather is nul', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);

        expect(
            () async =>
              await  apiClient.getWeather(latitude: latitude, longitude: longitude),
            throwsA(isA<WeatherNotFoundFailure>()));
      });
      test('good response weather', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('''
{
"latitude": 43,
"longitude": -87.875,
"generationtime_ms": 0.2510547637939453,
"utc_offset_seconds": 0,
"timezone": "GMT",
"timezone_abbreviation": "GMT",
"elevation": 189,
"current_weather": {
"temperature": 15.3,
"windspeed": 25.8,
"winddirection": 310,
"weathercode": 63,
"time": "2022-09-12T01:00"
}
}
        ''');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final goodResponse = await apiClient.getWeather(
            latitude: latitude, longitude: longitude);
        expect(
            goodResponse,
            isA<Weather>()
                .having((weather) => weather.temperature, 'temperature', 15.3)
                .having((weather) => weather.weatherCode, 'weatherCode', 63));
      });
    });
  });
}
