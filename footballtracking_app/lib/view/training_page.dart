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
              final w = widget.viewModel.weather;

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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Training in Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.refresh, size: 18),
                      ],
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
                    width: 280,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
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
                        const SizedBox(height: 10),

                        _SmallStatRow(
                          label: 'Distance',
                          value:
                              '${widget.viewModel.distanceKm.toStringAsFixed(2)} km',
                          icon: Icons.route,
                        ),
                        const SizedBox(height: 8),
                        _SmallStatRow(
                          label: 'Speed',
                          value:
                              '${widget.viewModel.currentSpeedKmh.toStringAsFixed(1)} km/h',
                          icon: Icons.speed,
                        ),

                        const SizedBox(height: 14),

                        // WEATHER PILL (overflow-safe)
                        _WeatherPill(
                          tempC: w?.temperatureC,
                          windMps: w?.windSpeedMps,
                        ),

                        const SizedBox(height: 14),
                        Text(
                          widget.viewModel.zoneLabel.toUpperCase(),
                          style: TextStyle(
                            color: widget.viewModel.zoneColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final session = await widget.viewModel.stopTraining();

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

class _SmallStatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SmallStatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black87),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _WeatherPill extends StatelessWidget {
  final double? tempC;
  final double? windMps;

  const _WeatherPill({
    required this.tempC,
    required this.windMps,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = tempC != null && windMps != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_outlined, size: 18, color: Colors.black87),
          const SizedBox(width: 10),

          // Title
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Text(
              'Weather',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Trailing area that can wrap (prevents overflow)
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: !hasData
                  ? const Text(
                      '--',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.end,
                      children: [
                        _WeatherChip(
                          icon: Icons.thermostat,
                          text: '${tempC!.toStringAsFixed(1)}°C',
                        ),
                        _WeatherChip(
                          icon: Icons.air,
                          text: '${windMps!.toStringAsFixed(1)} m/s',
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WeatherChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
