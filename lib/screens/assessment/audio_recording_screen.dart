import 'package:flutter/material.dart';
import '../../widgets/virtual_character.dart';

class AudioRecordingScreen extends StatefulWidget {
  const AudioRecordingScreen({super.key});

  @override
  State<AudioRecordingScreen> createState() => _AudioRecordingScreenState();
}

class _AudioRecordingScreenState extends State<AudioRecordingScreen> {
  bool _isRecording = false;

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // Start streaming...
    } else {
      // Stop streaming and show results...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ceritakan kisahmu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(child: VirtualCharacter()),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Bagaimana perasaanmu hari ini? Ceritakan kepadaku.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
            IconButton(
              iconSize: 80,
              icon: Icon(
                _isRecording ? Icons.stop_circle : Icons.mic_rounded,
                color: _isRecording ? Colors.red : Colors.blue,
              ),
              onPressed: _toggleRecording,
            ),
            const SizedBox(height: 20),
            Text(_isRecording ? 'Mendengarkan...' : 'Ketuk untuk mulai'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
