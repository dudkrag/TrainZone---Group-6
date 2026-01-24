import 'package:flutter/material.dart';
import '../viewmodel/coach_player_viewmodel.dart';

class CoachPlayerPage extends StatefulWidget {
  final CoachPlayerViewModel viewModel;

  const CoachPlayerPage({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<CoachPlayerPage> createState() => _CoachPlayerPageState();
}

class _CoachPlayerPageState extends State<CoachPlayerPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.viewModel.player.name),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          
          if (widget.viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          ///PERMISSION BLOCK
          if (!widget.viewModel.canSeeHistory) {
            return const Center(
              child: Text(
                'Player did not allow sharing training history',
                textAlign: TextAlign.center,
              ),
            );
          }

          ///empty
          if (widget.viewModel.sessions.isEmpty) {
            return const Center(
              child: Text('No training sessions recorded'),
            );
          }

          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.viewModel.sessions.length,
            itemBuilder: (context, index) {
              final session = widget.viewModel.sessions[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session • ${session.date.day}/${session.date.month}/${session.date.year}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text('Duration: ${session.duration.inMinutes} min'),

                      const Divider(height: 24),

                      if (widget.viewModel.canSeeHeartRate)
                        Text(
                          'Avg HR: ${session.avgHr.toStringAsFixed(1)} bpm',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                      const SizedBox(height: 12),

                      if (widget.viewModel.canSeeZones) ...[
                        const Text(
                          'Training Zones',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Low: ${session.lowZonePercentage.toStringAsFixed(1)} %',
                        ),
                        Text(
                          'Ideal: ${session.idealZonePercentage.toStringAsFixed(1)} %',
                        ),
                        Text(
                          'High: ${session.highZonePercentage.toStringAsFixed(1)} %',
                        ),
                      ],

                      const Divider(height: 24),

                      Text(
                        'Movement',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      Text(
                        'Distance: ${session.distanceKm?.toStringAsFixed(2) ?? '--'} km',
                      ),
                      Text(
                        'Avg speed: ${session.avgSpeedKmh?.toStringAsFixed(1) ?? '--'} km/h',
                      ),
                      Text(
                        'Max speed: ${session.maxSpeedKmh?.toStringAsFixed(1) ?? '--'} km/h',
                      ),
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
}
