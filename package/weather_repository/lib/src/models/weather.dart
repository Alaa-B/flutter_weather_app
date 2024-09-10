import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather.g.dart';

enum WeatherCondition {
  cloudy,
  clear,
  rainy,
  snowy,
  unknown,
}

@JsonSerializable()
class Weather extends Equatable {
  final String location;
  final double temperature;
  final WeatherCondition weatherCondition;

  const Weather(
      {required this.location,
      required this.temperature,
      required this.weatherCondition});


  factory Weather.fromJson (Map<String,dynamic> json)=> _$WeatherFromJson(json);

  Map<String,dynamic> toJson ()=> _$WeatherToJson(this);


  @override
  List<Object?> get props => [location, temperature, weatherCondition];

}
