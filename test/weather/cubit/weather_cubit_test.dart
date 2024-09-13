import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:weather_bloc_app/weather/cubit/cubit/weather_cubit.dart';
import 'package:weather_bloc_app/weather/models/models.dart';
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;
import 'package:weather_repository/weather_repository.dart'
    show WeatherCondition;
import '../../helpers/hydrated_cubit.dart';

const weatherLocation = 'London';
const weatherCondition = weather_repository.WeatherCondition.rainy;
const weatherTemperature = 9.8;

class MockWeatherRepository extends Mock
    implements weather_repository.WeatherRepository {}

class MockWeather extends Mock implements weather_repository.Weather {}

void main() {
  initHydratedStorage();
  group('Weather Cubit', () {
    late weather_repository.WeatherRepository weatherRepository;
    late weather_repository.Weather weather;
    late WeatherCubit weatherCubit;

    setUp(() async {
      weatherRepository = MockWeatherRepository();
      weather = MockWeather();

      when(() => weather.location).thenReturn(weatherLocation);
      when(() => weather.weatherCondition).thenReturn(weatherCondition);
      when(() => weather.temperature).thenReturn(weatherTemperature);
      when(
        () => weatherRepository.getWeather(any()),
      ).thenAnswer((_) async => weather);
      weatherCubit = WeatherCubit(weatherRepository);
    });

    test('initial state constructor is correct', () {
      final weatherCubit = WeatherCubit(weatherRepository);
      expect(weatherCubit.state, WeatherState());
    });

    group('toJson & fromJson', () {
      test('weather toJson&FromJson are working good', () {
        final weatherCubit = WeatherCubit(weatherRepository);
        expect(weatherCubit.fromJson(weatherCubit.toJson(weatherCubit.state)),
            weatherCubit.state);
      });
    });

    group('fetch weather', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when null City is added.',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(null),
        expect: () => const <WeatherCubit>[],
      );
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when empty City is added.',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(''),
        expect: () => const <WeatherCubit>[],
      );
      blocTest<WeatherCubit, WeatherState>(
        'call getWeather when valid city is added.',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        verify: (_) {
          verify(
            () => weatherRepository.getWeather(weatherLocation),
          ).called(1);
        },
      );
      blocTest<WeatherCubit, WeatherState>(
        'emits [loading , failure] when fetchWeather is added.',
        setUp: () {
          when(
            () => weatherRepository.getWeather(any()),
          ).thenThrow(Exception('error occurred'));
        },
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => <WeatherState>[
          WeatherState(status: WeatherStatus.loading),
          WeatherState(status: WeatherStatus.failure),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading , success] when MyEvent(celsius) is added.',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => <dynamic>[
          WeatherState(status: WeatherStatus.loading),
          isA<WeatherState>()
              .having((w) => w.status, 'Status', WeatherStatus.success)
              .having(
                (w) => w.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.location, 'Location', weatherLocation)
                    .having((w) => w.weatherCondition, 'weatherCondition',
                        weatherCondition)
                    .having((w) => w.temperature, 'temperature',
                        const TemperatureValue(value: weatherTemperature)),
              ),
        ],
      );
      blocTest<WeatherCubit, WeatherState>(
        'emits [loading , success] when MyEvent(fahrenheit) is added.',
        build: () => weatherCubit,
        seed: () => WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => <dynamic>[
          WeatherState(
              status: WeatherStatus.loading,
              temperatureUnits: TemperatureUnits.fahrenheit),
          isA<WeatherState>()
              .having((w) => w.status, 'Status', WeatherStatus.success)
              .having((w)=>w.temperatureUnits, 'tmpUnit', TemperatureUnits.fahrenheit)
              .having(
                (w) => w.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.location, 'Location', weatherLocation)
                    .having((w) => w.weatherCondition, 'weatherCondition',
                        weatherCondition)
                    .having(
                        (w) => w.temperature,
                        'temperature',
                        TemperatureValue(
                            value: weatherTemperature.toFahrenheit())),
              ),
        ],
      );
    });
    group('refresh weather', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits [nothing] when weather state  is not success.',
        build: () => weatherCubit,
        act: (bloc) => bloc.refreshWeather(),
        expect: () => const <WeatherState>[],
        verify: (_) {
          verifyNever(
            () => weatherRepository.getWeather(any()),
          );
        },
      );
      blocTest<WeatherCubit, WeatherState>(
        'emits [nothing] when weather location  is null.',
        build: () => weatherCubit,
        seed: () => WeatherState(status: WeatherStatus.success),
        act: (bloc) => bloc.refreshWeather(),
        expect: () => const <WeatherState>[],
        verify: (_) {
          verifyNever(
            () => weatherRepository.getWeather(any()),
          );
        },
      );
      blocTest<WeatherCubit, WeatherState>(
        'call getWeather with valid location.',
        build: () => weatherCubit,
        seed: () => WeatherState(
            status: WeatherStatus.success,
            weather: Weather(
                weatherCondition: weatherCondition,
                lastUpdated: DateTime(2024),
                location: weatherLocation,
                temperature:
                    const TemperatureValue(value: weatherTemperature))),
        act: (bloc) => bloc.refreshWeather(),
        verify: (_) {
          verify(
            () => weatherRepository.getWeather(weatherLocation),
          ).called(1);
        },
      );
      blocTest<WeatherCubit, WeatherState>(
        'emit [nothing] when getWeather throw exception.',
        build: () => weatherCubit,
        setUp: () {
          when(() => weatherRepository.getWeather(weatherLocation))
              .thenThrow(Exception('oops'));
        },
        seed: () => WeatherState(
            status: WeatherStatus.success,
            weather: Weather(
                weatherCondition: weatherCondition,
                lastUpdated: DateTime(2024),
                location: weatherLocation,
                temperature:
                    const TemperatureValue(value: weatherTemperature))),
        act: (bloc) => bloc.refreshWeather(),
        expect: () => <WeatherState>[],
      );
      blocTest<WeatherCubit, WeatherState>(
        'emit [new weather] when refreshWeather(celsius).',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather(
              weatherCondition: weatherCondition,
              lastUpdated: DateTime(2020),
              location: weatherLocation,

              /// changing the temperature here
              temperature: const TemperatureValue(value: 0)),
        ),
        act: (bloc) => bloc.refreshWeather(),
        expect: () => <Matcher>[
          isA<WeatherState>()
              .having((w) => w.status, 'Status', WeatherStatus.success)
              .having(
                (w) => w.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.location, 'Location', weatherLocation)
                    .having((w) => w.weatherCondition, 'weatherCondition',
                        weatherCondition)
                    .having((w) => w.temperature, 'temperature',
                        const TemperatureValue(value: weatherTemperature)),
              ),
        ],
      );
      blocTest<WeatherCubit, WeatherState>(
        'emit [new weather] when refreshWeather(fahrenheit).',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          temperatureUnits: TemperatureUnits.fahrenheit,
          weather: Weather(
              weatherCondition: weatherCondition,
              lastUpdated: DateTime(2024),
              location: weatherLocation,

              /// changing the temperature here
              temperature: const TemperatureValue(value: 30.0)),
        ),
        act: (bloc) => bloc.refreshWeather(),
        expect: () => <Matcher>[
          isA<WeatherState>()
              .having((w) => w.status, 'Status', WeatherStatus.success)
              .having(
                (w) => w.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.location, 'Location', weatherLocation)
                    .having((w) => w.weatherCondition, 'weatherCondition',
                        weatherCondition)
                    .having(
                        (w) => w.temperature,
                        'temperature',
                        TemperatureValue(
                            value: weatherTemperature.toFahrenheit())),
              ),
        ],
      );
    });
    group('toggle temperature unit', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits [updated unit] when status is not success.',
        build: () => weatherCubit,
        act: (bloc) => bloc.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(temperatureUnits: TemperatureUnits.fahrenheit)
        ],
      );
      blocTest<WeatherCubit, WeatherState>(
        'emits [updated unit & temperature](celsius) when status is success.',
        build: () => weatherCubit,
        seed: () => WeatherState(
            status: WeatherStatus.success,
            temperatureUnits: TemperatureUnits.fahrenheit,
            weather: Weather(
                weatherCondition: WeatherCondition.cloudy,
                lastUpdated: DateTime(2024),
                location: weatherLocation,
                temperature: const TemperatureValue(value: 87.0))),
        act: (bloc) => bloc.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(
              status: WeatherStatus.success,
              weather: Weather(
                  weatherCondition: WeatherCondition.cloudy,
                  lastUpdated: DateTime(2024),
                  location: weatherLocation,
                  temperature: TemperatureValue(value: 87.0.toCelsius())))
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [updated unit & temperature] (fahrenheit) when status is success.',
        build: () => weatherCubit,
        seed: () => WeatherState(
            status: WeatherStatus.success,
            temperatureUnits: TemperatureUnits.celsius,
            weather: Weather(
                weatherCondition: WeatherCondition.cloudy,
                lastUpdated: DateTime(2024),
                location: weatherLocation,
                temperature:
                    const TemperatureValue(value: weatherTemperature))),
        act: (bloc) => bloc.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(
              status: WeatherStatus.success,
              temperatureUnits: TemperatureUnits.fahrenheit,
              weather: Weather(
                  weatherCondition: WeatherCondition.cloudy,
                  lastUpdated: DateTime(2024),
                  location: weatherLocation,
                  temperature: TemperatureValue(
                      value: weatherTemperature.toFahrenheit())))
        ],
      );
    });
  });
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;
  double toCelsius() => (this - 32) * 5 / 9;
}
