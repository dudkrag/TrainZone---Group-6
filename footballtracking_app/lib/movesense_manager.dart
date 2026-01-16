// lib/movesense_manager.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:movesense_plus/movesense_plus.dart';

class MovesenseManager {
  /// Den adresse du har fundet via ScanPage.
  final MovesenseDevice device;

  bool _isSampling = false;
  StreamSubscription<MovesenseHR>? _hrSubscription;
  StreamSubscription<MovesenseState>? _stateSubscription;

  MovesenseManager({required String address})
      : device = MovesenseDevice(address: address);

  bool get isConnected => device.isConnected;
  bool get isSampling => _isSampling;

  Stream<DeviceConnectionStatus> get connectionStatusStream =>
      device.statusEvents;

  Stream<MovesenseHR> get hrStream => device.hr;

  Future<void> connect() async {
    if (!device.isConnected) {
      device.connect(); // ikke async i movesense_plus
    }
  }

  Future<void> disconnect() async {
    await stopSampling();
    if (device.isConnected) {
      device.disconnect();
    }
  }

  Future<void> startSampling({
    void Function(MovesenseHR hr)? onHeartRate,
    void Function(MovesenseState state)? onState,
  }) async {
    // Sørg for at vi er (eller bliver) forbundet
    if (!device.isConnected) {
      await connect();
      // INGEN return her – vi sætter bare lyttere op,
      // så de begynder at modtage så snart forbindelsen er klar.
    }
    if (_isSampling) return;

    if (kDebugMode) {
      device.getDeviceInfo().then((info) {
        debugPrint('>> Product name: ${info?.productName}');
      });
      device.getBatteryStatus().then((battery) {
        debugPrint('>> Battery: ${battery.name}');
      });
    }

    // Lyt på HR-streamen. Når sensoren først sender data,
    // vil både log og UI få dem.
    _hrSubscription = device.hr.listen((hr) {
      if (kDebugMode) {
        debugPrint('>> HR: ${hr.average}, RR: ${hr.rr} ms');
      }
      onHeartRate?.call(hr);
    });

    _stateSubscription =
        device.getStateEvents(SystemStateComponent.tap).listen((state) {
      if (kDebugMode) {
        debugPrint('>> State: $state');
      }
      onState?.call(state);
    });

    _isSampling = true;
  }

  Future<void> stopSampling() async {
    if (!_isSampling) return;
    await _hrSubscription?.cancel();
    await _stateSubscription?.cancel();
    _hrSubscription = null;
    _stateSubscription = null;
    _isSampling = false;
  }

  Future<void> toggleSampling({
    void Function(MovesenseHR hr)? onHeartRate,
    void Function(MovesenseState state)? onState,
  }) async {
    // Ét tryk på knappen skal både forbinde og starte/stoppe sampling
    if (!_isSampling) {
      await startSampling(onHeartRate: onHeartRate, onState: onState);
    } else {
      await stopSampling();
    }
  }

  Future<void> dispose() async {
    await stopSampling();
  }
}
