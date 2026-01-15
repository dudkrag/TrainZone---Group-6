import 'package:flutter/material.dart';
import 'package:movesense_plus/movesense_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'movesense_manager.dart';

void main() => runApp(const MovesenseApp());

class MovesenseApp extends StatelessWidget {
  const MovesenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MovesenseHomePage());
  }
}

class MovesenseHomePage extends StatefulWidget {
  const MovesenseHomePage({super.key});

  @override
  State<MovesenseHomePage> createState() => MovesenseHomePageState();
}

class MovesenseHomePageState extends State<MovesenseHomePage> {
  // DIN Movesense-adresse:
  final MovesenseManager movesenseManager =
      MovesenseManager(address: '0C:8C:DC:1B:23:61');

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      // På nogle Android-versioner:
      // Permission.locationWhenInUse,
    ].request();
  }

  void onButtonPressed() async {
    await movesenseManager.toggleSampling(
      onHeartRate: (hr) {
        debugPrint('>> HR: ${hr.average}, R-R: ${hr.rr} ms');
      },
      onState: (state) {
        debugPrint('>> State: ${state.toString()}');
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    movesenseManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = (!movesenseManager.isConnected)
        ? const Icon(Icons.refresh) // connect
        : (!movesenseManager.isSampling)
            ? const Icon(Icons.play_arrow) // start sampling
            : const Icon(Icons.stop); // stop sampling

    return Scaffold(
      appBar: AppBar(title: const Text('Movesense HR Monitor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<DeviceConnectionStatus>(
              stream: movesenseManager.connectionStatusStream,
              builder: (context, snapshot) {
                final status =
                    snapshot.data?.name ?? movesenseManager.device.status.name;
                return Text(
                  'Movesense [${movesenseManager.address}] - $status',
                  textAlign: TextAlign.center,
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('Heart rate:'),
            StreamBuilder<MovesenseHR>(
              stream: movesenseManager.hrStream,
              builder: (context, snapshot) {
                final hr = snapshot.data?.average;
                return Text(
                  hr?.toString() ?? '...',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onButtonPressed,
        child: icon,
      ),
    );
  }
}
