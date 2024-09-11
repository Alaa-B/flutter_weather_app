import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_bloc_app/weather/models/models.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository;

part 'weather_cubit.g.dart';
part 'weather_state.dart';

class WeatherCubit extends HydratedCubit<WeatherState> {
  WeatherCubit(this._weatherRepository) : super(WeatherState());
  final WeatherRepository _weatherRepository;

  Future<void> fetchWeather(String? city) async {
    if (city == null || city.isEmpty) return;

    emit(state.copyWith(status: WeatherStatus.loading));

    try {
      final weather =
          Weather.fromRepository(await _weatherRepository.getWeather(city));
      final tempUnit = state.temperatureUnits;
      final tempValue = tempUnit.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value.toCelsius();

      emit(state.copyWith(
        status: WeatherStatus.success,
        temperatureUnits: tempUnit,
        weather:
            weather.copyWith(temperature: TemperatureValue(value: tempValue)),
      ));
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }

  Future<void> refreshWeather() async {
    if (!state.status.isSuccess) return;
    if (state.weather == Weather.emptyWeather) return;
    try {
      final weather = Weather.fromRepository(
          await _weatherRepository.getWeather(state.weather.location));
      final tempUnit = state.temperatureUnits;
      final value = tempUnit.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value.toCelsius();

      emit(state.copyWith(
        status: WeatherStatus.success,
        temperatureUnits: tempUnit,
        weather: weather.copyWith(temperature: TemperatureValue(value: value)),
      ));
    } on Exception {
      emit(state);
    }
  }

  void toggleUnits() {
    final units = state.temperatureUnits.isFahrenheit
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;

    if (!state.status.isSuccess) {
      emit(state.copyWith(temperatureUnits: units));
      return;
    }
    final weather = state.weather;

    if (weather != Weather.emptyWeather) {
      final temperature = weather.temperature;
      final value = units.isFahrenheit
          ? temperature.value.toFahrenheit()
          : temperature.value.toCelsius();

      emit(
        state.copyWith(
          temperatureUnits: units,
          weather:
              weather.copyWith(temperature: TemperatureValue(value: value)),
        ),
      );
    }
  }

  @override
  WeatherState fromJson(Map<String, dynamic> json) =>
      WeatherState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(WeatherState state) => state.toJson();
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;
  double toCelsius() => (this - 32) * 5 / 9;
}
