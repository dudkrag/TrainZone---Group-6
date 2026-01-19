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
      appBar: AppBar(
        title: const Text('Scan for Movesense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_scanning) {
                Movesense().stopScan();
              }
              _devices.clear();
              Movesense().scan();
              setState(() => _scanning = true);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleScan,
        child: Icon(_scanning ? Icons.stop : Icons.search),
      ),
      body: _devices.isEmpty
          ? const Center(
              child: Text('Tryk på søg for at scanne efter Movesense...'),
            )
          : ListView.separated(
              itemCount: _devices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final d = _devices[index];
                return ListTile(
                  title: Text(d.name ?? 'Movesense'),
                  subtitle: Text('UUID: ${d.address}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Returnér valgt UUID-adresse tilbage til main
                    Navigator.of(context).pop(d.address);
                  },
                );
              },
            ),
    );
  }
}
