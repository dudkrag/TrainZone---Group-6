import 'package:flutter/material.dart';
import '../model/users.dart';

class AddPlayerPage extends StatefulWidget {
  final void Function(Player player) onSave;

  const AddPlayerPage({Key? key, required this.onSave}) : super(key: key);

  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Player')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageCtrl,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _positionCtrl,
              decoration: const InputDecoration(labelText: 'Position'),
            ),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final player = Player(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameCtrl.text,
                  age: int.parse(_ageCtrl.text),
                  position: _positionCtrl.text,
                  
                  coachId: '', 
                  permissions: DataPermissions(),
                );

                widget.onSave(player);
                Navigator.pop(context);
              },
              child: const Text('Save Player'),
            ),
          ],
        ),
      ),
    );
  }
}
