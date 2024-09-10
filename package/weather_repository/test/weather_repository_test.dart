import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart' as open_meteo_api;
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

class MockApiClient extends Mock implements open_meteo_api.OpenMeteoApiClient {}

class MockLocation extends Mock implements open_meteo_api.Location {}

class MockWeather extends Mock implements open_meteo_api.Weather {}

void main() {
  group('Weather Repository', () {
    late open_meteo_api.OpenMeteoApiClient weatherApiClient;
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherApiClient = MockApiClient();
      weatherRepository =
          WeatherRepository(openMeteoApiClient: weatherApiClient);
    });

    group('Weather Constructor', () {
      test('Weather initial constructor is not null', () {
        expect(WeatherRepository(), isNotNull);
      });
    });

    group('get weather', () {
      const city = 'chicago';
      const latitude = 41.85003;
      const longitude = -87.65005;

      test('call FindLocation with valid city', () async {
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(() => weatherApiClient.findLocation(city)).called(1);
      });

      test('throw exception when FindLocation fail', () async {
        final exception = Exception('error occurred');
        when(
          () => weatherApiClient.findLocation(city),
        ).thenThrow(exception);
        expect(
            () async => weatherRepository.getWeather(city), throwsA(exception));
      });

      test('get weather with valid longitude and latitude', () async {
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(
          () => weatherApiClient.findLocation(any()),
        ).thenAnswer((_) async => location);
        try {
           await weatherRepository.getWeather(city);
        } catch (_) {}

        verify(
          () => weatherApiClient.getWeather(
              latitude: latitude, longitude: longitude),
        ).called(1);
      });

      test('calling get weather with false long/lat', () {
        final location = MockLocation();
        final exception = Exception('error occurred');
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(
          () => weatherApiClient.findLocation(any()),
        ).thenAnswer((_) async => location);
        when(() => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'))).thenThrow(exception);
        expect(
            () async => weatherRepository.getWeather(city), throwsA(exception));
      });

      test('return a Clear weather condition on success', () async {
        final weather = MockWeather();
        final location = MockLocation();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(28);
        when(() => weather.weatherCode).thenReturn(0);
        when(
          () => weatherApiClient.findLocation(city),
        ).thenAnswer((_) async => location);
        when(
          () => weatherApiClient.getWeather(
              latitude: latitude, longitude: longitude),
        ).thenAnswer((_) async => weather);

        final actual = await weatherRepository.getWeather(city);
        expect(
            actual,
          const  Weather(
                location: city,
                temperature: 28,
                weatherCondition: WeatherCondition.clear));
      });
      test('return a Cloudy weather condition on success', () async {
        final weather = MockWeather();
        final location = MockLocation();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(28);
        when(() => weather.weatherCode).thenReturn(3);
        when(
          () => weatherApiClient.findLocation(city),
        ).thenAnswer((_) async => location);
        when(
          () => weatherApiClient.getWeather(
              latitude: latitude, longitude: longitude),
        ).thenAnswer((_) async => weather);

        final actual = await weatherRepository.getWeather(city);
        expect(
            actual,
          const  Weather(
                location: city,
                temperature: 28,
                weatherCondition: WeatherCondition.cloudy));
      });
      test('return a Rainy weather condition on success', () async {
        final weather = MockWeather();
        final location = MockLocation();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(28);
        when(() => weather.weatherCode).thenReturn(82);
        when(
          () => weatherApiClient.findLocation(city),
        ).thenAnswer((_) async => location);
        when(
          () => weatherApiClient.getWeather(
              latitude: latitude, longitude: longitude),
        ).thenAnswer((_) async => weather);

        final actual = await weatherRepository.getWeather(city);
        expect(
            actual,
          const  Weather(
                location: city,
                temperature: 28,
                weatherCondition: WeatherCondition.rainy));
      });
      test('return a Snowy weather condition on success', () async {
        final weather = MockWeather();
        final location = MockLocation();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(28);
        when(() => weather.weatherCode).thenReturn(75);
        when(
          () => weatherApiClient.findLocation(city),
        ).thenAnswer((_) async => location);
        when(
          () => weatherApiClient.getWeather(
              latitude: latitude, longitude: longitude),
        ).thenAnswer((_) async => weather);

        final actual = await weatherRepository.getWeather(city);
        expect(
            actual,
          const  Weather(
                location: city,
                temperature: 28,
                weatherCondition: WeatherCondition.snowy));
      });
      test('return a Unknown weather condition on success', () async {
        final weather = MockWeather();
        final location = MockLocation();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(28);
        when(() => weather.weatherCode).thenReturn(200);
        when(
          () => weatherApiClient.findLocation(city),
        ).thenAnswer((_) async => location);
        when(
          () => weatherApiClient.getWeather(
              latitude: latitude, longitude: longitude),
        ).thenAnswer((_) async => weather);

        final actual = await weatherRepository.getWeather(city);
        expect(
            actual,
          const  Weather(
                location: city,
                temperature: 28,
                weatherCondition: WeatherCondition.unknown));
      });
    });
  });
}
