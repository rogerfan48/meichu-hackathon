import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:foodie/widgets/flashcard/icon_button.dart';
import 'package:foodie/widgets/flashcard/flashcard_deck.dart';

class FlashcardPracticePage extends StatefulWidget {
  const FlashcardPracticePage({super.key});

  @override
  State<FlashcardPracticePage> createState() => _FlashcardPracticePageState();
}

class _FlashcardPracticePageState extends State<FlashcardPracticePage> with TickerProviderStateMixin {
  final FlashcardDeckController _deckController = FlashcardDeckController();
  final List<String> _cardTexts = const ['蘋果', 'Banana', 'Orange'];
  final GlobalKey<AnimatedIconButtonState> _thumbUpKey = GlobalKey();
  final GlobalKey<AnimatedIconButtonState> _thumbDownKey = GlobalKey();
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _recognizedWords = '';
  bool _speechEnabled = false;
  bool _isRecording = false;
  int _currentCardIndex = 0;
  String bannerText = '--';

  @override
  void initState() {
    super.initState();
    _recognizedWords = '';
    _isRecording = false;
    bannerText = "--";
    _currentCardIndex = 0;
    _speech.stop();
    if(!_speechEnabled) {
      _requestMicPermission();
    }
    _initSpeech();
  }

  Future<void> _requestMicPermission() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請開啟麥克風權限才能使用語音辨識'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        if (mounted) {
          setState(() {});
          if (status == "notListening") {
            setState(() {
              _isRecording = false;
            });
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {});
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
    _speech.cancel();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _isRecording = false;
      _stopListening();
    } else {
      _isRecording = true;
      _startListening();
    }
  }

  void _startListening() async {
    setState(() {
      _recognizedWords = '';
    });
    await _speech.listen(
      onResult: (result) {
        if(result.finalResult) {
          setState(() {
            _recognizedWords = result.recognizedWords;
            _currentCardIndex = _deckController.getIndex();
            if(_cardTexts[_currentCardIndex].toLowerCase() == _recognizedWords.toLowerCase()){
              bannerText = "Correct";
              _deckController.thumbUp();
            } else {
              bannerText = "Wrong";
              _deckController.thumbDown();
            }
            _isRecording = false;
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                bannerText = "--";
                _recognizedWords = "";
              });
            });
          });
        }
      },
      listenFor: const Duration(seconds: 5),
      localeId: 'zh-TW', // Changed to English for simplicity
      cancelOnError: true,
      partialResults: true,
      listenMode: stt.ListenMode.confirmation,
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isRecording = false;
    });
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
              child: FlashcardDeck(
                controller: _deckController,
                cardTexts: _cardTexts,
                itemWidth: 500.0,
                onThumbUpGesture: () {
                  _thumbUpKey.currentState?.playAnimation();
                },
                onThumbDownGesture: () {
                  _thumbDownKey.currentState?.playAnimation();
                },
                onEnd: () {
                  context.pop();
                },
                
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_recognizedWords),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: MediaQuery.of(context).size.width * 0.6,
              height: 50,
              decoration: BoxDecoration(
                color: bannerText == "--" 
                ? Color.fromRGBO(203, 203, 203, 0)
                : bannerText == "Correct" ? Color.fromRGBO(105, 240, 174, 0.5) : Color.fromRGBO(255, 81, 81, 0.5),
                border: Border.all(
                  color: bannerText == "--" 
                  ? Color.fromRGBO(71, 71, 71, 0) 
                  : bannerText == "Correct" ? colorScheme.primary : Colors.red,
                  width: 2),
                borderRadius: BorderRadius.circular(8.0),
              ),

              child: Center(
                child: Text(bannerText, style: TextStyle(
                  color: bannerText == "--" 
                  ? Color.fromRGBO(71, 71, 71, 0) 
                  : bannerText == "Correct" ? colorScheme.primary : Colors.red,
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedIconButton(
                icon: _isRecording ? Icons.mic : Icons.mic_off,
                color: _speechEnabled
                    ? (_isRecording ? colorScheme.primary : Colors.red) // 可用時黑色，錄音時主色
                    : Colors.grey, // 不可用時灰色
                onPressed: _speechEnabled && !_isRecording ? _toggleRecording : () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
