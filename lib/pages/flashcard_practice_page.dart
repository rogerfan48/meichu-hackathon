import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:foodie/widgets/flashcard/icon_button.dart';

class FlashcardPracticePage extends StatefulWidget {
  const FlashcardPracticePage({super.key});

  @override
  State<FlashcardPracticePage> createState() => _FlashcardPracticePageState();
}

class _FlashcardPracticePageState extends State<FlashcardPracticePage> with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _recognizedWords = '';
  bool _speechEnabled = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        if (mounted) {
          setState(() {
            _isRecording = status == 'listening';
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isRecording = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech recognition error: ${error.errorMsg}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      debugLogging: true,
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    setState(() {
      _recognizedWords = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedWords = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      localeId: 'zh-TW', // Changed to English for simplicity
      cancelOnError: true,
      partialResults: true,
      listenMode: stt.ListenMode.confirmation,
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recognition Test'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    _recognizedWords.isEmpty
                        ? 'Press the mic button and start speaking'
                        : _recognizedWords,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedIconButton(
                icon: _isRecording ? Icons.mic : Icons.mic_off,
                color: _isRecording ? colorScheme.primary : (_speechEnabled ? Colors.red : Colors.grey),
                onPressed: _speechEnabled ? _toggleRecording : () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
