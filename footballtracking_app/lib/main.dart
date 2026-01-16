// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movesense_plus/movesense_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MovesenseApp());

class MovesenseApp extends StatelessWidget {
  const MovesenseApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: MovesenseHomePage());
}

class MovesenseHomePage extends StatefulWidget {
  const MovesenseHomePage({super.key});

  @override
  State<MovesenseHomePage> createState() => MovesenseHomePageState();
}

class MovesenseHomePageState extends State<MovesenseHomePage> {
  // BRUG DIN EGEN MOVESENSE-ADRESSE HER
  final MovesenseDevice device =
      MovesenseDevice(address: '4D6C3EBA-FE78-5EB9-AE44-933C604B17CF');

  bool isSampling = false;
  StreamSubscription<MovesenseHR>? hrSubscription;
  StreamSubscription<MovesenseState>? stateSubscription;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    if (!mounted) return;

    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movesense HR Monitor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Viser connection-status
            StreamBuilder<DeviceConnectionStatus>(
              stream: device.statusEvents,
              builder: (context, snapshot) =>
                  Text('Movesense [${device.address}] - ${device.status.name}'),
            ),
            const SizedBox(height: 16),
            const Text('Heart rate:'),
            // Viser HR (eller ... hvis der ingen data er endnu)
            StreamBuilder<MovesenseHR>(
              stream: device.hr,
              builder: (context, snapshot) => Text(
                snapshot.hasData ? '${snapshot.data?.average}' : '...',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onButtonPressed,
        child: (!device.isConnected)
            ? const Icon(Icons.refresh)      // connect
            : (!isSampling)
                ? const Icon(Icons.play_arrow) // start HR
                : const Icon(Icons.stop),      // stop HR
      ),
    );
  }

  /// Håndterer tryk på knappen: connect + start/stop HR-sampling.
  void onButtonPressed() {
    setState(() {
      if (!device.isConnected) {
        // Hvis ikke forbundet, så begynd at forbinde
        device.connect();
      } else {
        // Hvis forbundet, kan vi hente info (valgfrit – mest til debug)
        device.getDeviceInfo().then(
          (info) => debugPrint('>> Product name: ${info?.productName}'),
        );
        device.getBatteryStatus().then(
          (battery) => debugPrint('>> Battery level: ${battery.name}'),
        );

        // Start/stop HR-sampling
        if (!isSampling) {
          // Lyt på HR-streamen
          hrSubscription = device.hr.listen((hr) {
            debugPrint(
              '>> Heart Rate: ${hr.average}, R-R Interval: ${hr.rr} ms',
            );
          });

          // Eksempel på state-events (kan fjernes hvis du ikke bruger det)
          stateSubscription = device
              .getStateEvents(SystemStateComponent.tap)
              .listen((state) {
            debugPrint('>> State: ${state.toString()}');
          });

          isSampling = true;
        } else {
          hrSubscription?.cancel();
          stateSubscription?.cancel();
          isSampling = false;
        }
      }
    });
  }
}
