import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_bloc_app/weather/models/models.dart';
import 'package:weather_bloc_app/weather/models/weather.dart';

part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit() : super(WeatherState());
}
