import 'package:flutter/material.dart';
import '../model/users.dart';

class AddCoachPage extends StatefulWidget {
  final void Function(Coach coach) onSave;

  const AddCoachPage({Key? key, required this.onSave}) : super(key: key);

  @override
  State<AddCoachPage> createState() => _AddCoachPageState();
}

class _AddCoachPageState extends State<AddCoachPage> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Coach')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Coach name'),
            ),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'Coach ID'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final coach = Coach(
                  id: _idController.text,
                  name: _nameController.text,
                );

                widget.onSave(coach);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
