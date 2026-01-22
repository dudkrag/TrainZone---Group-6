import 'package:flutter/material.dart';
import '../model/app_model.dart';

class SummaryPage extends StatelessWidget {
  final TrainingSession session;

  const SummaryPage({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distanceText = session.distanceKm == null
        ? '--'
        : '${session.distanceKm!.toStringAsFixed(2)} km';

    final avgSpeedText = session.avgSpeedKmh == null
        ? '--'
        : '${session.avgSpeedKmh!.toStringAsFixed(1)} km/h';

    final maxSpeedText = session.maxSpeedKmh == null
        ? '--'
        : '${session.maxSpeedKmh!.toStringAsFixed(1)} km/h';

    final w = session.weather;
    final tempText = (w == null) ? '--' : '${w.temperatureC.toStringAsFixed(1)}°C';
    final windText = (w == null) ? '--' : '${w.windSpeedMps.toStringAsFixed(1)} m/s';

    return Scaffold(
      appBar: AppBar(title: const Text('Training Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            const Text('Avg HR:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${session.avgHr.toStringAsFixed(1)} bpm'),

            const SizedBox(height: 16),

            const Text('Duration:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${session.duration.inMinutes} minutes'),

            const SizedBox(height: 16),

            const Text('Distance:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(distanceText),

            const SizedBox(height: 16),

            const Text('Avg speed:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(avgSpeedText),

            const SizedBox(height: 16),

            const Text('Max speed:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(maxSpeedText),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            const Text('Weather:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.thermostat, size: 18),
                const SizedBox(width: 8),
                Text('Temp: $tempText'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.air, size: 18),
                const SizedBox(width: 8),
                Text('Wind: $windText'),
              ],
            ),

            const SizedBox(height: 32),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/home'));
                },
                child: const Text('Return to Home screen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
