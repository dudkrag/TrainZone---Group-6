import 'package:flutter/material.dart';
import '../viewmodel/home_viewmodel.dart';
import '../viewmodel/history_viewmodel.dart';
import '../viewmodel/training_viewmodel.dart';
import '../viewmodel/settings_viewmodel.dart';
import '../view/scan_page.dart';

import 'settings_page.dart';
import 'training_page.dart';
import 'history_page.dart';

class HomePage extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomePage({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final player = viewModel.player;
            final last = viewModel.lastSession;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// =====================
                  /// TOP BAR
                  /// =====================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDF7),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        const Text(
                          'TrainZone',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_outline),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SettingsPage(
                                  viewModel: SettingsViewModel(
                                    player: viewModel.player,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// =====================
                  /// PLAYER CARD
                  /// =====================
                  _Card(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${player.age} years',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                player.position,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const CircleAvatar(
                          radius: 22,
                          child: Icon(Icons.person),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// =====================
                  /// LAST PERFORMANCE
                  /// =====================
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last performance metrics',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _Metric(
                              value: last != null
                                  ? last.avgHr.toStringAsFixed(1)
                                  : '--',
                              label: 'Avg HR',
                            ),
                            _Metric(
                              value: last != null
                                  ? '${last.idealZonePercentage.toStringAsFixed(0)}%'
                                  : '--',
                              label: '% ideal zone',
                            ),
                            _Metric(
                              value: last != null
                                  ? last.duration.inMinutes.toString()
                                  : '--',
                              label: 'min',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// =====================
                  /// SENSOR STATUS
                  /// =====================
                  Card(
                    child: ListTile(
                      leading: Icon(
                        viewModel.isConnected
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        color: viewModel.isConnected ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        viewModel.isConnected ? 'Movesense connected' : 'Movesense disconnected',
                      ),
                      subtitle: viewModel.isConnected && viewModel.batteryStatus != null
                          ? (() {
                              final isLowBattery =
                                  viewModel.batteryStatus!.toLowerCase() == 'low';

                              return Text(
                                'Battery: ${isLowBattery ? "LOW" : "OK"}',
                                style: TextStyle(
                                  color: isLowBattery ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            })()
                          : null,
                      trailing: viewModel.isConnecting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : _ActionButton(
                              label: 'Connect',
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const MovesenseHomePage(),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),


                  const SizedBox(height: 24),

                  /// =====================
                  /// ACTION BUTTONS
                  /// =====================
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'History',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HistoryPage(
                                  player: viewModel.player,
                                  viewModel: HistoryViewModel(
                                    repository: viewModel.repository,
                                    player: viewModel.player,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionButton(
                          label: 'Start training',
                          onTap: viewModel.isConnected
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TrainingPage(
                                        viewModel: TrainingViewModel(
                                          player: viewModel.player,
                                          movesense: viewModel.movesense,
                                          repository: viewModel.repository,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// =====================
/// REUSABLE WIDGETS
/// =====================

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;

  const _Metric({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFEDE7F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
