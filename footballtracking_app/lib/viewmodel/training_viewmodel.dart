import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../model/app_model.dart';
import '../model/gps_model.dart';
import '../model/calculate_distance.dart';
import '../model/speed_calculator.dart';
import '../model/training_repository.dart';
import '../model/weather_model.dart';
import '../model/weather_service.dart';

class TrainingViewModel extends ChangeNotifier {
  final Player player;
  final MovesenseManager movesense;
  final TrainingRepository repository;

  /// =========================
  /// GPS (stream + distance + speed)
  /// =========================
  final GpsModel gps;
  late final CalculateDistance distanceCalculator;
  late final SpeedCalculator speedCalculator;

  double get distanceMeters => distanceCalculator.state.totalDistanceMeters;
  double get distanceKm => distanceCalculator.state.totalDistanceKm;

  double get currentSpeedKmh => speedCalculator.state.currentKmh;
  double get avgSpeedKmh => speedCalculator.state.avgKmh;
  double get maxSpeedKmh => speedCalculator.state.maxKmh;

  late final TrainingLogic logic;

  int? currentHr;
  TrainingZone? currentZone;
  TrainingZone? lastZone;

  final List<int> _hrSamples = [];
  DateTime? _startTime;
  bool isTraining = false;

  TrainingSession? lastSession;

  // Ideal zone tracking
  Duration _totalTime = Duration.zero;
  Duration _idealZoneTime = Duration.zero;
  DateTime? _lastSampleTime;

  /// =========================
  /// WEATHER
  /// =========================
  final WeatherService _weatherService = WeatherService();
  StreamSubscription<GpsPoint>? _gpsTapSub; // tap GPS for last point + weather fetch
  bool _weatherRequested = false;
  GpsPoint? _lastGpsPoint;

  WeatherData? weather;

  TrainingViewModel({
    required this.player,
    required this.movesense,
    required this.repository,
    required this.gps,
  }) {
    logic = TrainingLogic(player: player);
    distanceCalculator = CalculateDistance(gps: gps);
    speedCalculator = SpeedCalculator(gps: gps);
  }

  void startTraining() {
    _hrSamples.clear();
    _startTime = DateTime.now();
    _lastSampleTime = null;

    isTraining = true;

    _totalTime = Duration.zero;
    _idealZoneTime = Duration.zero;

    // Reset metrics
    distanceCalculator.reset();
    speedCalculator.reset();

    // Reset weather
    weather = null;
    _weatherRequested = false;
    _lastGpsPoint = null;

    _gpsTapSub?.cancel();
    _gpsTapSub = null;

    // Start GPS stream
    gps.start();

    // Tap GPS points so we always keep last point and can fetch weather once
    _gpsTapSub = gps.stream.listen((p) async {
      _lastGpsPoint = p;

      // Only fetch weather once
      if (_weatherRequested) return;

      // Brug en mere tolerant threshold end 25m (mange telefoner ligger 30-60m i starten)
      // Justér evt. til 60 hvis du ofte får null
      if (p.accuracy > 50) return;

      _weatherRequested = true;

      try {
        final w = await _weatherService
            .fetchCurrentWeather(lat: p.lat, lon: p.lon)
            .timeout(const Duration(seconds: 4));
        weather = w;
        notifyListeners();
      } catch (_) {
        // keep null
      }
    });

    // Start distance calculation
    distanceCalculator.start((_) {
      notifyListeners();
    });

    // Start speed calculation
    speedCalculator.start((_) {
      notifyListeners();
    });

    // Start HR stream
    movesense.startHrStream((hr) {
      final now = DateTime.now();

      if (_lastSampleTime != null) {
        final delta = now.difference(_lastSampleTime!);
        _totalTime += delta;

        if (currentZone == TrainingZone.ideal) {
          _idealZoneTime += delta;
        }
      }

      _lastSampleTime = now;

      currentHr = hr;
      final newZone = logic.calculateZone(hr);

      if (lastZone != null && newZone != lastZone) {
        _vibrateForZone(newZone);
      }

      currentZone = newZone;
      lastZone = newZone;

      _hrSamples.add(hr);
      notifyListeners();
    });
  }

  Future<void> _vibrateForZone(TrainingZone zone) async {
    if (!await (Vibration.hasVibrator() ?? Future.value(false))) return;

    switch (zone) {
      case TrainingZone.low:
        Vibration.vibrate(duration: 2000);
        break;
      case TrainingZone.ideal:
        Vibration.vibrate(duration: 600);
        break;
      case TrainingZone.high:
        Vibration.vibrate(pattern: [0, 300, 200, 300, 200, 300]);
        break;
    }
  }

  Future<TrainingSession> stopTraining() async {
    // Stop HR stream first (GPS can keep running a moment if we need weather)
    movesense.stopHrStream();

    // If we still have no weather, try once using the last GPS point we saw
    if (weather == null && _lastGpsPoint != null) {
      try {
        final p = _lastGpsPoint!;
        final w = await _weatherService
            .fetchCurrentWeather(lat: p.lat, lon: p.lon)
            .timeout(const Duration(seconds: 4));
        weather = w;
      } catch (_) {
        // keep null
      }
    }

    // Stop streams
    distanceCalculator.stop();
    speedCalculator.stop();
    await gps.stop();

    _gpsTapSub?.cancel();
    _gpsTapSub = null;

    isTraining = false;

    final duration = DateTime.now().difference(_startTime!);

    final avgHr = _hrSamples.isEmpty
        ? 0.0
        : _hrSamples.reduce((a, b) => a + b) / _hrSamples.length;

    lastSession = TrainingSession(
      playerId: player.id,
      date: DateTime.now(),
      avgHr: avgHr,
      duration: duration,
      idealZonePercentage: idealZonePercentage,
      distanceMeters: distanceCalculator.state.totalDistanceMeters,
      avgSpeedMps: speedCalculator.state.avgSpeedMps,
      maxSpeedMps: speedCalculator.state.maxSpeedMps,
      weather: weather, // should now be set more reliably
    );

    await repository.addSession(lastSession!);
    notifyListeners();

    return lastSession!;
  }

  String get elapsedTimeFormatted {
    if (_startTime == null) return '00:00';

    final diff = DateTime.now().difference(_startTime!);
    final minutes = diff.inMinutes.toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get idealZonePercentage {
    if (_totalTime.inMilliseconds == 0) return 0;
    return (_idealZoneTime.inMilliseconds / _totalTime.inMilliseconds) * 100;
  }

  String get zoneLabel {
    switch (currentZone) {
      case TrainingZone.low:
        return 'Low Intensity';
      case TrainingZone.ideal:
        return 'Ideal Intensity';
      case TrainingZone.high:
        return 'High Intensity';
      default:
        return '-';
    }
  }

  Color get zoneColor {
    switch (currentZone) {
      case TrainingZone.low:
        return Colors.orange;
      case TrainingZone.ideal:
        return Colors.green;
      case TrainingZone.high:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
