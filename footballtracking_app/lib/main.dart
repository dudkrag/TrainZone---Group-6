//main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movesense_plus/movesense_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'scan_page.dart';

const _prefsKeyMovesenseUuid = 'movesense_uuid';

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
  MovesenseDevice? device;

  String? savedUuid;

  bool isSampling = false;
  StreamSubscription<MovesenseHR>? hrSubscription;
  StreamSubscription<MovesenseState>? stateSubscription;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _requestPermissions();
    await _loadSavedUuid();
    if (savedUuid != null && savedUuid!.isNotEmpty) {
      _setDevice(savedUuid!);
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<void> _loadSavedUuid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedUuid = prefs.getString(_prefsKeyMovesenseUuid);
    });
  }

  Future<void> _saveUuid(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyMovesenseUuid, uuid);
    setState(() => savedUuid = uuid);
  }

  Future<void> _clearSavedUuid() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyMovesenseUuid);
    setState(() => savedUuid = null);
  }

  void _setDevice(String uuid) {
    // Stop evt. aktiv sampling på gammel device
    _stopSampling();

    setState(() {
      device = MovesenseDevice(address: uuid);
      isSampling = false;
    });
  }

  Future<void> _openScanAndSelect() async {
    final selectedUuid = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanPage()),
    );

    if (selectedUuid == null || selectedUuid.isEmpty) return;

    await _saveUuid(selectedUuid);
    _setDevice(selectedUuid);
  }

  @override
  void dispose() {
    _stopSampling();
    super.dispose();
  }

  void _stopSampling() {
    hrSubscription?.cancel();
    stateSubscription?.cancel();
    hrSubscription = null;
    stateSubscription = null;
    isSampling = false;
  }

  void _onButtonPressed() {
    final d = device;
    if (d == null) return;

    setState(() {
      if (!d.isConnected) {
        d.connect();
      } else {
        if (!isSampling) {
          hrSubscription = d.hr.listen((hr) {
            debugPrint('>> Heart Rate: ${hr.average}, RR: ${hr.rr} ms');
          });

          stateSubscription =
              d.getStateEvents(SystemStateComponent.tap).listen((state) {
            debugPrint('>> State: $state');
          });

          isSampling = true;
        } else {
          _stopSampling();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = device;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movesense HR Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openScanAndSelect,
            tooltip: 'Scan & vælg sensor',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await _clearSavedUuid();
              setState(() {
                _stopSampling();
                device = null;
              });
            },
            tooltip: 'Fjern gemt UUID',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                savedUuid == null
                    ? 'Ingen gemt sensor endnu.\nTryk på søg (øverst) for at vælge.'
                    : 'Gemt UUID:\n$savedUuid',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              if (d != null) ...[
                StreamBuilder<DeviceConnectionStatus>(
                  stream: d.statusEvents,
                  builder: (context, snapshot) {
                    final status = snapshot.data?.name ?? d.status.name;
                    return Text(
                      'Movesense [$savedUuid] - $status',
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text('Heart rate:'),
                StreamBuilder<MovesenseHR>(
                  stream: d.hr,
                  builder: (context, snapshot) => Text(
                    snapshot.hasData ? '${snapshot.data?.average}' : '...',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: d == null ? _openScanAndSelect : _onButtonPressed,
        child: d == null
            ? const Icon(Icons.search)
            : (!d.isConnected)
                ? const Icon(Icons.refresh)
                : (!isSampling)
                    ? const Icon(Icons.play_arrow)
                    : const Icon(Icons.stop),
      ),
    );
  }
}
