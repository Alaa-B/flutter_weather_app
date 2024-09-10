// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Weather _$WeatherFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Weather',
      json,
      ($checkedConvert) {
        final val = Weather(
          location: $checkedConvert('location', (v) => v as String),
          temperature:
              $checkedConvert('temperature', (v) => (v as num).toDouble()),
          weatherCondition: $checkedConvert('weather_condition',
              (v) => $enumDecode(_$WeatherConditionEnumMap, v)),
        );
        return val;
      },
      fieldKeyMap: const {'weatherCondition': 'weather_condition'},
    );

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'location': instance.location,
      'temperature': instance.temperature,
      'weather_condition':
          _$WeatherConditionEnumMap[instance.weatherCondition]!,
    };

const _$WeatherConditionEnumMap = {
  WeatherCondition.cloudy: 'cloudy',
  WeatherCondition.clear: 'clear',
  WeatherCondition.rainy: 'rainy',
  WeatherCondition.snowy: 'snowy',
  WeatherCondition.unknown: 'unknown',
};
