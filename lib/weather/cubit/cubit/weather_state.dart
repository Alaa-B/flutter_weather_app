// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'weather_cubit.dart';

enum WeatherStatus { initial, loading, success, failure }

extension GetWeatherStatus on WeatherStatus {
  bool get isInitial => this == WeatherStatus.initial;
  bool get isLoading => this == WeatherStatus.loading;
  bool get isSuccess => this == WeatherStatus.success;
  bool get isFailure => this == WeatherStatus.failure;
}

@JsonSerializable()
class WeatherState extends Equatable {
  WeatherState(
      {this.status = WeatherStatus.initial,
      Weather? weather,
      this.temperatureUnits = TemperatureUnits.celsius})
      : weather = weather ?? Weather.emptyWeather;

  factory WeatherState.fromJson(Map<String, dynamic> json) =>
      _$WeatherStateFromJson(json);

  final WeatherStatus status;
  final Weather weather;
  final TemperatureUnits temperatureUnits;

  Map<String, dynamic> toJson() => _$WeatherStateToJson(this);

  @override
  List<Object> get props => [];

  WeatherState copyWith({
    WeatherStatus? status,
    Weather? weather,
    TemperatureUnits? temperatureUnits,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      temperatureUnits: temperatureUnits ?? this.temperatureUnits,
    );
  }
}
