import 'package:flutter/material.dart';
import '../model/users.dart';
import '../viewmodel/history_viewmodel.dart';

class HistoryPage extends StatefulWidget {
  final Player player;
  final HistoryViewModel viewModel;

  const HistoryPage({
    Key? key,
    required this.player,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export sessions (JSON)',
            onPressed: () async {
              final file = await widget.viewModel.exportHistory();

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Exported to:\n${file.path}',
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            },
          ),
        ],
      ),

      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.isEmpty) {
            return const Center(
              child: Text(
                'No registered training sessions',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.viewModel.sessions.length,
            itemBuilder: (context, index) {
              final session = widget.viewModel.sessions[index];

              final distanceText = session.distanceKm == null
                  ? '--'
                  : session.distanceKm!.toStringAsFixed(2);

              final avgSpeedText = session.avgSpeedKmh == null
                  ? '--'
                  : session.avgSpeedKmh!.toStringAsFixed(1);

              final maxSpeedText = session.maxSpeedKmh == null
                  ? '--'
                  : session.maxSpeedKmh!.toStringAsFixed(1);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session • ${_formatDate(session.date)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text('Duration: ${session.duration.inMinutes} min'),

                      const Divider(height: 24),

                      Text(
                        'Avg HR: ${session.avgHr.toStringAsFixed(1)} bpm',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Training Zones',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      Text('Low: ${session.lowZonePercentage.toStringAsFixed(1)} %'),
                      Text('Ideal: ${session.idealZonePercentage.toStringAsFixed(1)} %'),
                      Text('High: ${session.highZonePercentage.toStringAsFixed(1)} %'),

                      const Divider(height: 24),

                      const Text(
                        'Movement',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      Text('Distance: $distanceText km'),
                      Text('Avg speed: $avgSpeedText km/h'),
                      Text('Max speed: $maxSpeedText km/h'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
