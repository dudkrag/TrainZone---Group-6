import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../model/users.dart';
import '../model/gps_model.dart';
import '../model/calculate_distance.dart';
import '../model/speed_calculator.dart';
import '../model/movesense.dart';
import '../model/training.dart';
import '../model/storage.dart';

class TrainingViewModel extends ChangeNotifier {
  final Player player;
  final MovesenseManager movesense;
  final TrainingRepository repository;
  final GpsModel gps;

  late final TrainingLogic logic;
  late final CalculateDistance distanceCalculator;
  late final SpeedCalculator speedCalculator;

  int? currentHr;
  TrainingZone? currentZone;
  TrainingZone? lastZone;

  final List<int> _hrSamples = [];
  DateTime? _startTime;
  DateTime? _lastSampleTime;

  bool isTraining = false;

 
  Duration _totalTime = Duration.zero;
  Duration _lowZoneTime = Duration.zero;
  Duration _idealZoneTime = Duration.zero;
  Duration _highZoneTime = Duration.zero;

  TrainingSession? lastSession;

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


  double get distanceMeters =>
      distanceCalculator.state.totalDistanceMeters;

  double get distanceKm =>
      distanceCalculator.state.totalDistanceKm;

  double get currentSpeedKmh =>
      speedCalculator.state.currentKmh;

  double get avgSpeedKmh =>
      speedCalculator.state.avgKmh;

  double get maxSpeedKmh =>
      speedCalculator.state.maxKmh;

  void startTraining() {
    _hrSamples.clear();
    _startTime = DateTime.now();
    _lastSampleTime = null;

    _totalTime = Duration.zero;
    _lowZoneTime = Duration.zero;
    _idealZoneTime = Duration.zero;
    _highZoneTime = Duration.zero;

    isTraining = true;

    distanceCalculator.reset();
    speedCalculator.reset();

    gps.start();
    distanceCalculator.start((_) => notifyListeners());
    speedCalculator.start((_) => notifyListeners());

    movesense.startHrStream((hr) {
      final now = DateTime.now();

      if (_lastSampleTime != null) {
        final delta = now.difference(_lastSampleTime!);
        _totalTime += delta;

        switch (currentZone) {
          case TrainingZone.low:
            _lowZoneTime += delta;
            break;
          case TrainingZone.ideal:
            _idealZoneTime += delta;
            break;
          case TrainingZone.high:
            _highZoneTime += delta;
            break;
          default:
            break;
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

  TrainingSession stopTraining() {
    movesense.stopHrStream();
    gps.stop();
    distanceCalculator.stop();
    speedCalculator.stop();

    isTraining = false;

    final duration = DateTime.now().difference(_startTime!);

    final avgHr = _hrSamples.isEmpty
        ? 0.0
        : _hrSamples.reduce((a, b) => a + b) / _hrSamples.length;

    lastSession = TrainingSession(
      playerId: player.id,
      date: DateTime.now(),
      duration: duration,
      avgHr: avgHr,
      lowZonePercentage: lowZonePercentage,
      idealZonePercentage: idealZonePercentage,
      highZonePercentage: highZonePercentage,
      distanceMeters: distanceMeters,
      avgSpeedMps: speedCalculator.state.avgSpeedMps,
      maxSpeedMps: speedCalculator.state.maxSpeedMps,
    );

    repository.addSession(lastSession!);
    notifyListeners();

    return lastSession!;
  }

  double get lowZonePercentage =>
      _totalTime.inMilliseconds == 0
          ? 0
          : (_lowZoneTime.inMilliseconds / _totalTime.inMilliseconds) * 100;

  double get idealZonePercentage =>
      _totalTime.inMilliseconds == 0
          ? 0
          : (_idealZoneTime.inMilliseconds / _totalTime.inMilliseconds) * 100;

  double get highZonePercentage =>
      _totalTime.inMilliseconds == 0
          ? 0
          : (_highZoneTime.inMilliseconds / _totalTime.inMilliseconds) * 100;

  String get elapsedTimeFormatted {
    if (_startTime == null) return '00:00';
    final diff = DateTime.now().difference(_startTime!);
    return '${diff.inMinutes.toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
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

  Future<void> _vibrateForZone(TrainingZone zone) async {
    if (!await Vibration.hasVibrator()) return;

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
}
