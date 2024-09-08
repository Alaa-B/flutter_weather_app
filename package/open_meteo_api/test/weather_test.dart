import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/test.dart';

void main() {
  group('Weather', () {
    group('from Json', () {
      test('return correct weather', () {
        expect(
            Weather.fromJson(
                <String, dynamic>{'temperature': 15.3, 'weatherCode': 63}),
            isA<Weather>()
                .having((w) => w.temperature, 'temperature', 15.3)
                .having((w) => w.weatherCode, 'weatherCode', 63));
      });
    });
  });
}
