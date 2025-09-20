import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late FlutterTts flutterTts;
  final List<String> labels = ["Upload", "Flashcard", "History", "Settings"];

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

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        for (int i = 0; i < labels.length; i++)
          BottomNavigationBarItem(
            icon: GestureDetector(
              onLongPress: () => _speak(labels[i]),
              child: Icon(_getIcon(i)),
            ),
            label: labels[i],
          ),
      ],
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.upload;
      case 1:
        return Icons.style;
      case 2:
        return Icons.history;
      case 3:
        return Icons.settings;
      default:
        return Icons.error;
    }
  }
}
