// lib/scan_page.dart
import 'package:flutter/material.dart';
import 'package:movesense_plus/movesense_plus.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final List<MovesenseDevice> _devices = [];
  bool _scanning = false;

  @override
  void initState() {
    super.initState();

    // Lyt på fundne enheder
    Movesense().devices.listen((device) {
      if (!_devices.any((d) => d.address == device.address)) {
        setState(() => _devices.add(device));
      }
    });
  }

  void _toggleScan() {
    if (_scanning) {
      Movesense().stopScan();
    } else {
      _devices.clear();
      Movesense().scan();
    }
    setState(() => _scanning = !_scanning);
  }

  @override
  void dispose() {
    Movesense().stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan for Movesense')),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleScan,
        child: Icon(_scanning ? Icons.stop : Icons.search),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final d = _devices[index];
          return ListTile(
            title: Text(d.name ?? 'Unknown'),
            subtitle: Text('Address: ${d.address}'),
          );
        },
      ),
    );
  }
}
