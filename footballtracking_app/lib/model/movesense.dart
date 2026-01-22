import 'dart:async';
import 'package:movesense_plus/movesense_plus.dart';

class MovesenseManager {            //Controller           
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