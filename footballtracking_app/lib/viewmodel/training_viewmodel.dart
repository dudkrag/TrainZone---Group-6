import 'package:flutter/material.dart';
import '../model/app_model.dart';
import 'package:vibration/vibration.dart';

class TrainingViewModel extends ChangeNotifier {
  final Player player;
  final MovesenseManager movesense;
  final TrainingRepository repository;

  late final TrainingLogic logic;

  int? currentHr;
  TrainingZone? currentZone;
  TrainingZone? lastZone;

  final List<int> _hrSamples = [];
  DateTime? _startTime;
  bool isTraining = false;

  TrainingSession? lastSession;

  Duration _totalTime = Duration.zero;
  //ideal duration
  Duration _idealZoneTime = Duration.zero;
  DateTime? _lastSampleTime;

  TrainingViewModel({
    required this.player,
    required this.movesense,
    required this.repository,
  }) {
    logic = TrainingLogic(player: player);
  }

  
  void startTraining() {
    _hrSamples.clear();
    _startTime = DateTime.now();
    _lastSampleTime = null;
    
    isTraining = true;

    _totalTime = Duration.zero;
    _idealZoneTime = Duration.zero;
    

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
  if (!await (Vibration.hasVibrator())) return;

  switch (zone) {
    case TrainingZone.low:
      Vibration.vibrate(duration: 2000);   // continuos vibration in 2s
      break;

    case TrainingZone.ideal:
      Vibration.vibrate(duration: 600); // 1 kort vibration
      break;

    case TrainingZone.high:
      Vibration.vibrate(pattern: [0, 300, 200, 300, 200, 300]); // 3 multiples and kort vibrations
      break;
  }
}


  TrainingSession stopTraining() {
    movesense.stopHrStream();
    isTraining = false;

    final duration = DateTime.now().difference(_startTime!);
    final avgHr =
        _hrSamples.reduce((a, b) => a + b) / _hrSamples.length;

    lastSession = TrainingSession(
      playerId: player.id,
      date: DateTime.now(),
      avgHr: avgHr,
      duration: duration,
      idealZonePercentage: idealZonePercentage,
    );

    repository.addSession(lastSession!);
    notifyListeners();

    return lastSession!;
  }


 
  //timer
  String get elapsedTimeFormatted {
    if (_startTime == null) return '00:00';

    final diff = DateTime.now().difference(_startTime!);
    final minutes = diff.inMinutes.toString().padLeft(2, '0');
    final seconds =
        (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get idealZonePercentage {
    if (_totalTime.inMilliseconds == 0) return 0;
    return (_idealZoneTime.inMilliseconds /
            _totalTime.inMilliseconds) *
        100;
  }

  
  //ZONE visual info
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
        return Colors.grey; // when the data isnt running yet, could mean the device is not connected or data is not beeing recorded
    }
  }
}
