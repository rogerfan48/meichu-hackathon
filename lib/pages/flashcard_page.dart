import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlashcardPage extends StatelessWidget {
  const FlashcardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: const [
          _Card(text: '蘋果'),
          _Card(text: 'Card 2'),
          _Card(text: 'Card 3'),
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

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () => flutterTts.speak(widget.text),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(widget.text, style: Theme.of(context).textTheme.headlineMedium),
          ),
        ),
      ),
    );
  }
}


