import 'package:flutter/material.dart';
import '../model/app_model.dart';
import '../viewmodel/history_viewmodel.dart';

class HistoryPage extends StatelessWidget {
  final Player player;
  final HistoryViewModel viewModel;

  const HistoryPage({
    Key? key,
    required this.player,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: viewModel.isEmpty
            ? const Center(
                child: Text(
                  'No registered training',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: viewModel.history.length,
                itemBuilder: (context, index) {
                  final session = viewModel.history[index];

                  final avgSpeedText = session.avgSpeedKmh == null
                      ? '--'
                      : session.avgSpeedKmh!.toStringAsFixed(1);

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: Text(
                        'Avg HR: ${session.avgHr.toStringAsFixed(1)} bpm',
                      ),

                      /// ✅ UPDATED subtitle (duration + avg speed)
                      subtitle: Text(
                        'Duration: ${session.duration.inMinutes} min\n'
                        'Avg speed: $avgSpeedText km/h',
                      ),

                      trailing: Text(
                        _formatDate(session.date),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
