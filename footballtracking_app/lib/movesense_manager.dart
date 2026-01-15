import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:movesense_plus/movesense_plus.dart';

/// MovesenseManager indkapsler forbindelsen til den rigtige Movesense-enhed.
/// Denne version bruger movesense_plus-plugin'et og måler rigtigt fra sensoren.
class MovesenseManager {
  final String address;
  late final MovesenseDevice device;

  bool _isSampling = false;
  StreamSubscription<MovesenseHR>? _hrSubscription;
  StreamSubscription<MovesenseState>? _stateSubscription;

  MovesenseManager({required this.address}) {
    device = MovesenseDevice(address: address);
  }

  bool get isConnected => device.isConnected;
  bool get isSampling => _isSampling;

  Stream<DeviceConnectionStatus> get connectionStatusStream =>
      device.statusEvents;

  Stream<MovesenseHR> get hrStream => device.hr;

  /// Forbinder til enheden, hvis ikke allerede forbundet
  Future<void> connect() async {
    if (!device.isConnected) {
      device.connect();
    }
  }

  /// Afbryder forbindelsen og stopper sampling
  Future<void> disconnect() async {
    await stopSampling();
    if (device.isConnected) {
      device.disconnect();
    }
  }

  /// Starter sampling af HR + eksempel på system state (tap)
  Future<void> startSampling({
    void Function(MovesenseHR hr)? onHeartRate,
    void Function(MovesenseState state)? onState,
  }) async {
    if (!device.isConnected) {
      await connect();
      // vent på næste tryk for at starte sampling
      return;
    }

    if (_isSampling) return;

    // Optional debug-info
    device.getDeviceInfo().then((info) {
      debugPrint('>> Product name: ${info?.productName}');
    });
    device.getBatteryStatus().then((battery) {
      debugPrint('>> Battery level: ${battery.name}');
    });

    _hrSubscription = device.hr.listen((hr) {
      if (kDebugMode) {
        debugPrint(
          '>> Heart Rate: ${hr.average}, R-R Interval: ${hr.rr} ms',
        );
      }
      onHeartRate?.call(hr);
    });

    _stateSubscription = device
        .getStateEvents(SystemStateComponent.tap)
        .listen((state) {
      if (kDebugMode) {
        debugPrint('>> State: ${state.toString()}');
      }
      onState?.call(state);
    });

    _isSampling = true;
  }

  /// Stopper sampling og rydder subscriptions
  Future<void> stopSampling() async {
    if (!_isSampling) return;

    await _hrSubscription?.cancel();
    await _stateSubscription?.cancel();

    _hrSubscription = null;
    _stateSubscription = null;
    _isSampling = false;
  }

  /// Bruges af UI-knappen:
  /// - hvis ikke connected: connect
  /// - ellers: start/stop sampling
  Future<void> toggleSampling({
    void Function(MovesenseHR hr)? onHeartRate,
    void Function(MovesenseState state)? onState,
  }) async {
    if (!device.isConnected) {
      device.connect();
      return; // næste tryk starter sampling
    }

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
