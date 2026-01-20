import 'package:flutter/material.dart';
import '../viewmodel/training_viewmodel.dart';
import 'summary_page.dart';

class TrainingPage extends StatefulWidget {
  final TrainingViewModel viewModel;

  const TrainingPage({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.startTraining();
  }

  @override
  void dispose() {
    // If user navigates back without pressing End training,
    // we stop streams to avoid leaks.
    if (widget.viewModel.isTraining) {
      widget.viewModel.stopTraining();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      body: SafeArea(
        child: Center(
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'Training in Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      const Text(
                        'ELAPSED TIME',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.viewModel.elapsedTimeFormatted,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    width: 260,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: widget.viewModel.zoneColor,
                          child: const Icon(
                            Icons.directions_walk,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${widget.viewModel.currentHr ?? '--'} BPM',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // NEW: Distance live
                        Text(
                          '${widget.viewModel.distanceKm.toStringAsFixed(2)} km',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          widget.viewModel.zoneLabel.toUpperCase(),
                          style: TextStyle(
                            color: widget.viewModel.zoneColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAE6F0),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          final session = widget.viewModel.stopTraining();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SummaryPage(session: session),
                            ),
                          );
                        },
                        child: const Text('End training'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
