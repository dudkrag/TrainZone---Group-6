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
    final history = viewModel.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: history.isEmpty
            ? const Center(
                child: Text(
                  'No registered training',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final s = history[index];

                  final dateText = _formatDateTime(s.date);

                  final durationText = '${s.duration.inMinutes} min';

                  final avgHrText = s.avgHr.toStringAsFixed(1);

                  final idealText = '${s.idealZonePercentage.toStringAsFixed(0)}%';

                  final distanceText = (s.distanceKm == null)
                      ? '--'
                      : '${s.distanceKm!.toStringAsFixed(2)} km';

                  final avgSpeedText = (s.avgSpeedKmh == null)
                      ? '--'
                      : '${s.avgSpeedKmh!.toStringAsFixed(1)} km/h';

                  final maxSpeedText = (s.maxSpeedKmh == null)
                      ? '--'
                      : '${s.maxSpeedKmh!.toStringAsFixed(1)} km/h';

                  final tempText = (s.weather == null)
                      ? '--'
                      : '${s.weather!.temperatureC.toStringAsFixed(1)}°C';

                  final windText = (s.weather == null)
                      ? '--'
                      : '${s.weather!.windSpeedMps.toStringAsFixed(1)} m/s';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row: date + duration
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  dateText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              _Pill(text: durationText),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // HR + Zone
                          Row(
                            children: [
                              Expanded(
                                child: _MetricLine(
                                  icon: Icons.favorite,
                                  label: 'Avg HR',
                                  value: '$avgHrText bpm',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricLine(
                                  icon: Icons.speed_outlined,
                                  label: 'Ideal zone',
                                  value: idealText,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Distance + Speeds
                          Row(
                            children: [
                              Expanded(
                                child: _MetricLine(
                                  icon: Icons.route,
                                  label: 'Distance',
                                  value: distanceText,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricLine(
                                  icon: Icons.av_timer,
                                  label: 'Avg speed',
                                  value: avgSpeedText,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: _MetricLine(
                                  icon: Icons.trending_up,
                                  label: 'Max speed',
                                  value: maxSpeedText,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricLine(
                                  icon: Icons.cloud_outlined,
                                  label: 'Weather',
                                  value: '$tempText • $windText',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    // dd/MM/yyyy HH:mm
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    final hh = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy  $hh:$min';
  }
}

class _MetricLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black87),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
