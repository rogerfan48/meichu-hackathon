import 'dart:typed_data';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../api_key.dart';

class FlashCard extends StatefulWidget {
  final String text;
  const FlashCard({super.key, required this.text});

  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard> {
  late final FlutterTts flutterTts;
  Future<Uint8List?>? _imageFuture;

  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _model = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: apiKey,
    );
  }

  bool _isChinese(String text) {
    return RegExp(r'[\u4E00-\u9FFF]').hasMatch(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 100,
        height: 200,
        child: FlipCard(
          front: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(widget.text,
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
          back: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FutureBuilder<Uint8List?>(
                future: _imageFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Icon(Icons.error);
                  } else if (snapshot.hasData) {
                    return Image.memory(snapshot.data!);
                  } else {
                    // Placeholder when no image is available.
                    return const Icon(Icons.image_not_supported);
                  }
                },
              ),
            ),
          ),
          onFlip: () {
            final lang = _isChinese(widget.text) ? 'zh-TW' : 'en-US';
            flutterTts.setLanguage(lang);
          },
          onFlipDone: (isFront) {
            if (!isFront) {
              flutterTts.speak(widget.text);
            }
          },
        ),
      ),
    );
  }
}
