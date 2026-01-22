import 'package:flutter/material.dart';
import '../viewmodel/settings_viewmodel.dart';

class SettingsPage extends StatefulWidget {
  final SettingsViewModel viewModel;

  const SettingsPage({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _ageController;
  late TextEditingController _coachIdController;

  @override
  void initState() {
    super.initState();

    final player = widget.viewModel.player;

    _nameController = TextEditingController(text: player.name);
    _positionController =
        TextEditingController(text: player.position);
    _ageController =
        TextEditingController(text: player.age.toString());
    _coachIdController =
        TextEditingController(text: player.coachId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _ageController.dispose();
    _coachIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Settings')),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Personal Information',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: 'Name'),
                onChanged: widget.viewModel.updateName,
              ),

              TextField(
                controller: _positionController,
                decoration:
                    const InputDecoration(labelText: 'Position'),
                onChanged: widget.viewModel.updatePosition,
              ),

              TextField(
                controller: _ageController,
                decoration:
                    const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onChanged: widget.viewModel.updateAge,
              ),

              TextField(
                controller: _coachIdController,
                decoration:
                    const InputDecoration(labelText: 'Coach ID'),
                onChanged: widget.viewModel.updateCoachId,
              ),

              const SizedBox(height: 24),

              const Text(
                'Data Sharing Preferences',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SwitchListTile(
                title: const Text('Share heart rate data'),
                value: widget
                    .viewModel.player.permissions.heartRate,
                onChanged: widget.viewModel.toggleHeartRate,
              ),

              SwitchListTile(
                title: const Text('Share training zones'),
                value: widget.viewModel.player.permissions
                    .trainingZones,
                onChanged:
                    widget.viewModel.toggleTrainingZones,
              ),

              SwitchListTile(
                title: const Text('Share training history'),
                value: widget.viewModel.player.permissions
                    .trainingHistory,
                onChanged:
                    widget.viewModel.toggleTrainingHistory,
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () async {
                  await widget.viewModel.save(); // 🔥 AGORA SALVA
                  Navigator.pop(context);
                },
                child: const Text('Save & Back'),
              ),
            ],
          );
        },
      ),
    );
  }
}
