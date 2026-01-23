import 'package:flutter/material.dart';
import '../view/welcome_page.dart';
import '../viewmodel/home_viewmodel.dart';
import '../viewmodel/history_viewmodel.dart';
import '../viewmodel/training_viewmodel.dart';
import '../viewmodel/settings_viewmodel.dart';
import '../model/gps_model.dart';
import '../model/storage.dart';
import 'settings_page.dart';
import 'training_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  final HomeViewModel viewModel;
  final GpsModel gpsModel;

  final PlayerRepository playerRepository;
  final TrainingRepository trainingRepository;
  final CoachRepository coachRepository;

  const HomePage({
    Key? key,
    required this.viewModel,
    required this.gpsModel,
    required this.playerRepository,
    required this.trainingRepository,
    required this.coachRepository,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadLastSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('TrainZone'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => WelcomePage(
                  playerRepository: widget.playerRepository,
                  trainingRepository: widget.trainingRepository,
                  coachRepository: widget.coachRepository,
                ),
              ),
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    viewModel: SettingsViewModel(
                      player: widget.viewModel.player,
                      repository: widget.playerRepository,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final player = widget.viewModel.player;
            final last = widget.viewModel.lastSession;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  //P
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
                              Text('${player.age} years'),
                              Text(player.position),
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

                 //LS
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

                 //M
                  Card(
                    child: ListTile(
                      leading: Icon(
                        widget.viewModel.isConnected
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        color: widget.viewModel.isConnected
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(
                        widget.viewModel.isConnected
                            ? 'Movesense connected'
                            : 'Movesense disconnected',
                      ),
                      subtitle: widget.viewModel.isConnected &&
                              widget.viewModel.batteryStatus != null
                          ? (() {
                              final isLowBattery = widget
                                      .viewModel.batteryStatus!
                                      .toLowerCase() ==
                                  'low';
                              return Text(
                                'Battery: ${isLowBattery ? "LOW" : "OK"}',
                                style: TextStyle(
                                  color: isLowBattery
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            })()
                          : null,
                      trailing: widget.viewModel.isConnecting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : ElevatedButton(
                              onPressed: widget.viewModel.isConnected
                                  ? widget.viewModel.disconnectMovesense
                                  : widget.viewModel.connect,
                              child: Text(
                                widget.viewModel.isConnected
                                    ? 'Disconnect'
                                    : 'Connect',
                              ),
                            ),
                    ),
                  ),

                  const Spacer(),

                 
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
                                  player: widget.viewModel.player,
                                  viewModel: HistoryViewModel(
                                    repository:
                                        widget.trainingRepository,
                                    player: widget.viewModel.player,
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
                          onTap: widget.viewModel.isConnected
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TrainingPage(
                                        viewModel: TrainingViewModel(
                                          player:
                                              widget.viewModel.player,
                                          sensor:
                                              widget.viewModel.movesense,
                                          repository:
                                              widget.trainingRepository,
                                          gps: widget.gpsModel,
                                        ),
                                        homeViewModel:
                                            widget.viewModel,
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

//widgets

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
