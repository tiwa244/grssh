import 'dart:io';

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

  setUpAll(() async {
    // Create a dummy .env file for testing
    final envFile = File('/app/.env');
    await envFile.writeAsString('API_KEY_WEATHERAPI=dummy_key');

    // Initialize Hive and dotenv
    Hive.init('test');
    await dotenv.load(fileName: "/app/.env");
  });

  tearDownAll(() async {
    // Clean up the dummy .env file
    final envFile = File('.env');
    if (await envFile.exists()) {
      await envFile.delete();
    }
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

      when(client.get(any))
          .thenAnswer((_) async => http.Response('{"current": {"temperature_2m": 25.0}}', 200));

      final weather = await service.fetchWeather(0.0, 0.0, client: client);

      expect(weather, isNotNull);
      expect(weather!['data']['current']['temperature_2m'], 25.0);
    });

    test('fetchWeather throws exception on failed API call', () async {
      final client = MockClient();

      when(client.get(any)).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(service.fetchWeather(0.0, 0.0, client: client), throwsException);
    });
  });
}
