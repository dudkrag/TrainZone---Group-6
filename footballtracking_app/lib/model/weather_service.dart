import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

class WeatherService {
  Future<WeatherData> fetchCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,wind_speed_10m'
      '&wind_speed_unit=ms',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Weather HTTP ${res.statusCode}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>?;

    if (current == null) {
      throw Exception('Weather response missing "current"');
    }

    final temp = (current['temperature_2m'] as num).toDouble();
    final wind = (current['wind_speed_10m'] as num).toDouble();

    return WeatherData(
      temperatureC: temp,
      windSpeedMps: wind,
    );
  }
}
