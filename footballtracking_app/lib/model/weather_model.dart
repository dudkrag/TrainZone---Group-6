class WeatherData {
  final double temperatureC;
  final double windSpeedMps;

  WeatherData({
    required this.temperatureC,
    required this.windSpeedMps,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
        temperatureC: (json['temperatureC'] as num).toDouble(),
        windSpeedMps: (json['windSpeedMps'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'temperatureC': temperatureC,
        'windSpeedMps': windSpeedMps,
      };
}
