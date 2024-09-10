import 'package:open_meteo_api/open_meteo_api.dart' hide Weather;
import './models/models.dart';

class WeatherRepository {
  WeatherRepository({OpenMeteoApiClient? openMeteoApiClient})
      : _weatherApiClient = openMeteoApiClient ?? OpenMeteoApiClient();
  final OpenMeteoApiClient _weatherApiClient;

  Future<Weather> getWeather(String city) async {
    
    final location = await _weatherApiClient.findLocation(city);
    final weather = await _weatherApiClient.getWeather(
        latitude: location.latitude, longitude: location.longitude);

    return Weather(
        location: location.name,
        temperature: weather.temperature,
        weatherCondition: weather.weatherCode.toInt().getCondition);
  }
}

extension on int {
  WeatherCondition get getCondition {
    switch (this) {
      case 0:
        return WeatherCondition.clear;
      case 1:
      case 2:
      case 3:
      case 45:
      case 48:
        return WeatherCondition.cloudy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
      case 95:
      case 96:
      case 99:
        return WeatherCondition.rainy;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return WeatherCondition.snowy;
      default:
        return WeatherCondition.unknown;
    }
  }
}
