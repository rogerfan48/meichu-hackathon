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
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
        width: 320,
        height: 220,
        child: FlipCard(
          front: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF4FFF9), Color(0xFFF4FFF9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.07),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                child: Center(
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Color.fromARGB(255, 41, 44, 41),
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.15),
                          blurRadius: 2,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          back: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF4FFF9), Color(0xFFF4FFF9)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.15),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: FutureBuilder<Uint8List?>(
                  future: _imageFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('圖片生成中...', style: theme.textTheme.bodyLarge),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 40),
                          SizedBox(height: 8),
                          Text('圖片載入失敗', style: theme.textTheme.bodyLarge),
                        ],
                      );
                    } else if (snapshot.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(snapshot.data!, fit: BoxFit.cover, width: 180, height: 120),
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                          SizedBox(height: 8),
                          Text('無圖片', style: theme.textTheme.bodyLarge),
                        ],
                      );
                    }
                  },
                ),
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
