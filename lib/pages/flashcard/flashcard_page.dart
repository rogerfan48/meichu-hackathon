import 'dart:typed_data';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../api_key.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextCard() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: const [
                _Card(text: '蘋果'),
                _Card(text: 'Banana'),
                _Card(text: 'Orange'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AnimatedThumbButton(
                  icon: Icons.thumb_down,
                  color: Colors.red,
                  onPressed: _nextCard,
                ),
                _AnimatedThumbButton(
                  icon: Icons.thumb_up,
                  color: Colors.green,
                  onPressed: _nextCard,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatefulWidget {
  final String text;
  const _Card({required this.text});

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
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

  Future<Uint8List?> _generateImage(String text) async {
    final prompt = TextPart(
        "Generate a photorealistic image of ${widget.text}, with a white background.");
    final response = await _model.generateContent([
      Content.multi([prompt])
    ]);
    // Assuming the model returns image bytes in some way.
    // This part is tricky because the current gemini-pro-vision model is multimodal for *input*, not for generating images as output.
    // Let's assume there's a hypothetical image generation model or function.
    // For now, I'll return a placeholder. The user might need to use a different model like 'gemini-pro' and get an image URL, or use a different image generation API.
    // The google_generative_ai package does not directly support image generation output yet.
    // Let's change the model to a text model and ask for an image URL.
    // final textModel = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    // final textPrompt =
    //     "Give me a URL of a realistic-looking image of ${widget.text} with a white background.";
    // final textResponse =
    //     await textModel.generateContent([Content.text(textPrompt)]);

    // This is a placeholder for how you might get image data.
    // You'd typically use an HTTP client to download the image from a URL.
    // Since we don't have a real image generation model that outputs bytes,
    // we can't fully implement this.
    // I will simulate a network image load.
    // if (textResponse.text != null) {
    //   // In a real app, you would use http package to get the image bytes from URL
    //   // For this example, let's just return null and show a placeholder.
    //   print(textResponse.text); // You can see the URL in the console.
    // }

    return null; // Returning null to show placeholder.
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 450,
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
            if (_imageFuture == null) {
              final lang = _isChinese(widget.text) ? 'zh-TW' : 'en-US';
              flutterTts.setLanguage(lang);
              setState(() {
                _imageFuture = _generateImage(widget.text);
              });
            }
          },
          onFlipDone: (isFront) {
            if (isFront) {
              flutterTts.speak(widget.text);
            }
          },
        ),
      ),
    );
  }
}

class _AnimatedThumbButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _AnimatedThumbButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_AnimatedThumbButton> createState() => _AnimatedThumbButtonState();
}

class _AnimatedThumbButtonState extends State<_AnimatedThumbButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _animation,
        child: Icon(
          widget.icon,
          color: widget.color,
          size: 32,
        ),
      ),
    );
  }
}


