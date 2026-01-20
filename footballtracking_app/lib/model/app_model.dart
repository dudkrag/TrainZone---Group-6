import 'dart:async';
import 'package:movesense_plus/movesense_plus.dart';

//users
class Player {
  final String id;
  String name;
  String position;
  String coachId;
  int age;
  int restingHr;
  DataPermissions permissions;

  Player({
    required this.id,
    required this.name,
    required this.position,
    required this.coachId,
    required this.age,
    required this.restingHr,
    required this.permissions,
  });
}

class DataPermissions {
  bool heartRate;
  bool trainingZones;
  bool trainingHistory;

  DataPermissions({
    this.heartRate = true,
    this.trainingZones = true,
    this.trainingHistory = true,
  });
}

class Coach {
  final String id;
  final String name;

  Coach({
    required this.id,
    required this.name,
  });
}


//zoner
enum TrainingZone {
  low,
  ideal,
  high,
}


class TrainingLogic {
  final Player player;

  TrainingLogic({required this.player});

  int get maxHr => 220 - player.age;  ///look 

  TrainingZone calculateZone(int hr) {
    final double percent = hr / maxHr;

    if (percent < 0.60) {
      return TrainingZone.low;
    } else if (percent <= 0.80) {
      return TrainingZone.ideal;
    } else {
      return TrainingZone.high;
    }
  }
}

// data of training
class TrainingSession {
  final String playerId;
  final double avgHr;
  final Duration duration;
  final DateTime date;
  final double idealZonePercentage;

  TrainingSession({
    required this.playerId,
    required this.avgHr,
    required this.duration,
    required this.date, required this.idealZonePercentage,
  });
}


// "save" data training, change to DataManager when implementing database. obs: store.record(xxx.id:xx.toJson());
class TrainingRepository {
  final List<TrainingSession> _sessions = [];

  void addSession(TrainingSession session) {
    _sessions.add(session);
  }

  List<TrainingSession> getSessionsByPlayer(String playerId) {
    return _sessions
        .where((s) => s.playerId == playerId)
        .toList();
  }
}


class MovesenseManager {            //Controller           - move to another file 
  static const String macAddress = '0C:8C:DC:1B:23:1F';   //change here if we use Amins Movesense
  MovesenseDevice? _device;
  StreamSubscription<MovesenseHR>? _hrSub;
  String? batteryStatus;
  bool get isConnected => _device != null;

  Future<void> connect() async {
    _device = MovesenseDevice(address: macAddress);
    _device!.connect();

    final battery = await _device!.getBatteryStatus();
    batteryStatus = battery.name;
  }

  Future<void> disconnect() async {
    stopHrStream();              
    _device?.disconnect();       
    _device = null;                   
    batteryStatus = null;
  }

  /// HEART RATE STREAM
  void startHrStream(void Function(int hr) onData) {
    if (_device == null) return;

    _hrSub = _device!.hr.listen((data) {
      onData(data.average);
    });
  }

  void stopHrStream() {
    _hrSub?.cancel();
  }
}
