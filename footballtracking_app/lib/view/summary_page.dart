import 'package:flutter/material.dart';
import '../model/app_model.dart';


class SummaryPage extends StatelessWidget {
  final TrainingSession session;
  
  const SummaryPage({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Training Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 24),

            Text(
              'Avg HR:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${session.avgHr.toStringAsFixed(1)} bpm'),

            const SizedBox(height: 16),

            Text(
              'Duration:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${session.duration.inMinutes} minutes'),

            const SizedBox(height: 32),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('/home')
                      
                    
                  );
                },
                child: const Text('Return to Home screen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
