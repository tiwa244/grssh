import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:weather_master_app/services/fetch_data.dart';
import 'package:hive/hive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'weather_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  final service = WeatherService();

  setUp(() {
    Hive.init('test');
    dotenv.load(fileName: "assets/.env");
  });

  group('WeatherService unit tests', () {
    test('nullSafeValue returns correct default', () {
      expect(service.nullSafeValue<int>(null), 0);
      expect(service.nullSafeValue<double>(null), 0.0000001);
    });

    test('sanitizeCurrent fills missing fields', () {
      final current = {'temperature_2m': 25.0};
      final sanitized = service.sanitizeCurrent(current);
      expect(sanitized['temperature_2m'], 25.0);
      expect(sanitized['wind_speed_10m'], 0.0000001);
    });

    test('fetchWeather returns data on successful API call', () async {
      final client = MockClient();

      when(client.get(Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=0.0&longitude=0.0&current=temperature_2m%2Cis_day%2Capparent_temperature%2Cpressure_msl%2Crelative_humidity_2m%2Cprecipitation%2Cweather_code%2Ccloud_cover%2Cwind_speed_10m%2Cwind_direction_10m%2Cwind_gusts_10m&hourly=wind_speed_10m%2Cwind_direction_10m%2Crelative_humidity_2m%2Cpressure_msl%2Ccloud_cover%2Ctemperature_2m%2Cdew_point_2m%2Capparent_temperature%2Cprecipitation_probability%2Cprecipitation%2Cweather_code%2Cvisibility%2Cuv_index&daily=weather_code%2Ctemperature_2m_max%2Ctemperature_2m_min%2Csunrise%2Csunset%2Cdaylight_duration%2Cuv_index_max%2Cprecipitation_sum%2Cprecipitation_probability_max%2Cprecipitation_hours%2Cwind_speed_10m_max%2Cwind_gusts_10m_max&timezone=Etc%2FGMT&forecast_days=7&models=best_match&past_days=1')))
          .thenAnswer((_) async => http.Response('{"current": {"temperature_2m": 25.0}}', 200));
      when(client.get(Uri.parse('https://air-quality-api.open-meteo.com/v1/air-quality?latitude=0.0&longitude=0.0&current=us_aqi%2Ceuropean_aqi%2Cpm10%2Cpm2_5%2Ccarbon_monoxide%2Cnitrogen_dioxide%2Csulphur_dioxide%2Cozone%2Calder_pollen%2Cbirch_pollen%2Cgrass_pollen%2Cmugwort_pollen%2Colive_pollen%2Cragweed_pollen&timezone=Etc%2FGMT&forecast_hours=1')))
          .thenAnswer((_) async => http.Response('{}', 200));
      when(client.get(Uri.parse('https://api.weatherapi.com/v1/astronomy.json?key=dummy_key&q=0.0,0.0')))
          .thenAnswer((_) async => http.Response('{}', 200));

      final weather = await service.fetchWeather(0.0, 0.0);

      expect(weather, isNotNull);
      expect(weather!['data']['current']['temperature_2m'], 25.0);
    });

    test('fetchWeather throws exception on failed API call', () async {
      final client = MockClient();

      when(client.get(any)).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(service.fetchWeather(0.0, 0.0), throwsException);
    });
  });
}
