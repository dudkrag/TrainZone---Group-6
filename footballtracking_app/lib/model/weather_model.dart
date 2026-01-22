class WeatherData {
  final double temperatureC;
  final double windSpeedMps;

  WeatherData({
    required this.temperatureC,
    required this.windSpeedMps,
  });

  Map<String, dynamic> toJson() => {
        'temperatureC': temperatureC,
        'windSpeedMps': windSpeedMps,
      };

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperatureC: (json['temperatureC'] as num).toDouble(),
      windSpeedMps: (json['windSpeedMps'] as num).toDouble(),
    );
  }
}
