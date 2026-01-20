import 'package:flutter/material.dart';
import '../viewmodel/coach_player_viewmodel.dart';

class CoachPlayerDetailPage extends StatelessWidget {
  final CoachPlayerViewModel viewModel;

  const CoachPlayerDetailPage({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sessions = viewModel.sessions;

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.player.name),
      ),
      body: sessions.isEmpty
          ? const Center(
              child: Text('No registered training'),
            )
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final s = sessions[index];

                final avgSpeedText = s.avgSpeedKmh == null
                    ? '--'
                    : s.avgSpeedKmh!.toStringAsFixed(1);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      'Avg HR: ${s.avgHr.toStringAsFixed(1)} bpm',
                    ),

                    /// UPDATED subtitle (duration + date + avg speed)
                    subtitle: Text(
                      'Duration: ${s.duration.inMinutes} min\n'
                      'Date: ${s.date.day}/${s.date.month}/${s.date.year}\n'
                      'Avg speed: $avgSpeedText km/h',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
