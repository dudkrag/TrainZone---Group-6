import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

class WeatherService {
  /// Uses Open-Meteo current weather, returns Celsius + m/s.
  /// No API key required.
  static Future<WeatherData> fetchCurrent({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat'
      '&longitude=$lon'
      '&current=temperature_2m,wind_speed_10m'
      '&windspeed_unit=ms'
      '&timezone=auto',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Weather API error: ${res.statusCode}');
    }

    final Map<String, dynamic> jsonMap = jsonDecode(res.body);
    final current = jsonMap['current'] as Map<String, dynamic>?;

    if (current == null) {
      throw Exception('Weather API: missing "current"');
    }

    final temp = (current['temperature_2m'] as num?)?.toDouble();
    final wind = (current['wind_speed_10m'] as num?)?.toDouble();

    if (temp == null || wind == null) {
      throw Exception('Weather API: missing temperature or wind');
    }

    return WeatherData(
      temperatureC: temp,
      windSpeedMps: wind,
    );
  }
}
