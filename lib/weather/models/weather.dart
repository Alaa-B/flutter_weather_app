import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;


part 'weather.g.dart';


enum TemperatureUnits { fahrenheit, celsius }

extension GetTemperatureUnits on TemperatureUnits {
  bool get isFahrenheit => this == TemperatureUnits.fahrenheit;
  bool get isCelsius => this == TemperatureUnits.celsius;
}

@JsonSerializable()
class TemperatureValue extends Equatable {

  const TemperatureValue({required this.value});

  factory TemperatureValue.fromJson(Map<String, dynamic> json) =>
      _$TemperatureValueFromJson(json);

  final double value;


  Map<String, dynamic> toJson() => _$TemperatureValueToJson(this);

  @override
  List<Object?> get props => [value];
}

@JsonSerializable()
class Weather extends Equatable {
  const Weather({
    required this.weatherCondition,
    required this.lastUpdated,
    required this.location,
    required this.temperature,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => _$WeatherFromJson(json);

  final WeatherCondition weatherCondition;
  final DateTime lastUpdated;
  final String location;
  final TemperatureValue temperature;

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  factory Weather.fromRepository(weather_repository.Weather weather) {
    return Weather(
      weatherCondition: weather.weatherCondition,
      lastUpdated: DateTime.now(),
      location: weather.location,
      temperature: TemperatureValue(value: weather.temperature),
    );
  }

  static final emptyWeather = Weather(
    weatherCondition: WeatherCondition.unknown,
    lastUpdated: DateTime(0),
    location: '---',
    temperature: const TemperatureValue(value: 0.0),
  );

  Weather copyWith({
    WeatherCondition? weatherCondition,
    DateTime? lastUpdated,
    String? location,
    TemperatureValue? temperature,
  }) {
    return Weather(
      weatherCondition: weatherCondition ?? this.weatherCondition,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
    );
  }

  @override
  List<Object?> get props =>
      [weatherCondition, lastUpdated, location, temperature];
}
