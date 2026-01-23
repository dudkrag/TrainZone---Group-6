import 'package:flutter/material.dart';
import '../model/training.dart';
import '../viewmodel/home_viewmodel.dart';

class SummaryPage extends StatelessWidget {
  final TrainingSession session;
  final HomeViewModel homeViewModel;

  const SummaryPage({
    Key? key,
    required this.session,
    required this.homeViewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Summary'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            
            const Text(
              'Session Completed',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

          
            _MetricRow(
              label: 'Duration',
              value: '${session.duration.inMinutes} min',
            ),
            _MetricRow(
              label: 'Average HR',
              value: '${session.avgHr.toStringAsFixed(1)} bpm',
            ),

            const SizedBox(height: 24),

            

            const Text(
              'Time in Training Zones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            _ZoneRow(
              label: 'Low intensity',
              value: session.lowZonePercentage,
              color: Colors.orange,
            ),
            _ZoneRow(
              label: 'Ideal intensity',
              value: session.idealZonePercentage,
              color: Colors.green,
            ),
            _ZoneRow(
              label: 'High intensity',
              value: session.highZonePercentage,
              color: Colors.red,
            ),

            const SizedBox(height: 24),

            
            
            if (session.distanceKm != null)
              _MetricRow(
                label: 'Distance',
                value: '${session.distanceKm!.toStringAsFixed(2)} km',
              ),

            if (session.avgSpeedKmh != null)
              _MetricRow(
                label: 'Avg speed',
                value: '${session.avgSpeedKmh!.toStringAsFixed(1)} km/h',
              ),

            if (session.maxSpeedKmh != null)
              _MetricRow(
                label: 'Max speed',
                value: '${session.maxSpeedKmh!.toStringAsFixed(1)} km/h',
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ZoneRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ZoneRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: value / 100,
              color: color,
              backgroundColor: color.withOpacity(0.2),
              minHeight: 10,
            ),
          ),
          const SizedBox(width: 12),
          Text('${value.toStringAsFixed(1)} %'),
        ],
      ),
    );
  }
}
