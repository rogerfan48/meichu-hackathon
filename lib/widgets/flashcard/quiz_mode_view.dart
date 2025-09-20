import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../models/card_model.dart';
import '../../view_models/cards_page_view_model.dart';
import '../shared/animated_icon_button.dart';
import 'quiz_mode_deck.dart';

class QuizModeView extends StatefulWidget {
  final CardsPageViewModel viewModel;
  const QuizModeView({super.key, required this.viewModel});

  @override
  State<QuizModeView> createState() => _QuizModeViewState();
}

// 在 lib/widgets/flashcard/quiz_mode_view.dart 中

class _QuizModeViewState extends State<QuizModeView> {
  final QuizDeckController _deckController = QuizDeckController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  String _recognizedWords = '';
  bool _speechEnabled = false;
  bool _isRecording = false;
  String _bannerText = '--';
  bool isVisible = false;
  
  late List<StudyCard> _quizDeck;

  @override
  void initState() {
    super.initState();
    _quizDeck = List.from(widget.viewModel.allCards)..shuffle();
    // initState 中只做初始化，不主動請求權限
    _initSpeech();
  }

  // 初始化 speech_to_text，但不請求權限
  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        if (mounted && status == "notListening") {
          setState(() => _isRecording = false);
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('語音辨識錯誤: ${error.errorMsg}')),
          );
        }
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _speech.stop();
    _deckController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    // 不再檢查 _isRecording，因為 startListening 會處理
    _startListening();
  }

  // ** 關鍵修改：將權限請求和語音辨識邏輯結合 **
  void _startListening() async {
    if (!_speechEnabled || _isRecording || _quizDeck.isEmpty) return;

    // 步驟 1: 檢查並請求權限
    var status = await Permission.microphone.request();

    if (!status.isGranted) {
      // 如果用戶拒絕了權限
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('您需要提供麥克風權限才能使用語音測驗。')),
      );
      // 如果用戶永久拒絕，可以提示他們去設定中開啟
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
      return; // 因為沒有權限，所以終止後續操作
    }

    // 步驟 2: 如果權限已授予，則開始錄音
    setState(() {
      _isRecording = true;
      _recognizedWords = '';
      _bannerText = '--';
    });
    
    final currentCard = _quizDeck[_deckController.currentIndex];
    final isChinese = RegExp(r'[\u4E00-\u9FFF]').hasMatch(currentCard.text);

    _speech.listen(
      onResult: (result) {
        if (mounted && result.finalResult) {
          setState(() {
            _recognizedWords = result.recognizedWords;
            _isRecording = false; // 辨識到最終結果後自動停止
            _evaluateAnswer();
          });
        }
      },
      localeId: isChinese ? 'zh-TW' : 'en-US',
    );
  }
  
  // stopListening 保持不變，但在 toggleRecording 中不再需要它
  void _stopListening() async {
    await _speech.stop();
    if (mounted) setState(() => _isRecording = false);
  }

  void _evaluateAnswer() {
    if (_quizDeck.isEmpty) return;
    final currentCard = _quizDeck[_deckController.currentIndex];
    final isCorrect = currentCard.text.trim().toLowerCase() == _recognizedWords.trim().toLowerCase();

    setState(() => _bannerText = isCorrect ? "正確" : "錯誤");

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (isCorrect) {
        _deckController.swipeRight();
      } else {
        _deckController.swipeLeft();
      }
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _bannerText = '--';
            _recognizedWords = '';
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // build 方法保持不變
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("請說出卡片上的文字", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ),
        Expanded(
          child: QuizModeDeck(
            controller: _deckController,
            cards: _quizDeck,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(_recognizedWords, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildBanner(),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedIconButton(
            icon: _isRecording ? Icons.mic : Icons.mic_off,
            color: _speechEnabled
                ? (_isRecording ? Theme.of(context).colorScheme.primary : Colors.grey)
                : Colors.grey.shade300,
            onPressed: _speechEnabled && !_isRecording ? _toggleRecording : null, // 正在錄音時停用按鈕
          ),
        ),
      ],
    );
  }

  Color get _bannerColor {
    switch (_bannerText) {
      case "正確":
        return Colors.green.shade100;
      case "錯誤":
        return Colors.red.shade100;
      default:
        return Colors.transparent;
    }
  }

  Color get _borderColor {
    switch (_bannerText) {
      case "正確":
        return Colors.green;
      case "錯誤":
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  Widget _buildBanner() {
    final theme = Theme.of(context);
    isVisible = _bannerText != '--';

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width * 0.6,
        height: 50,
        decoration: BoxDecoration(
          color: _bannerColor,
          border: Border.all(color: _borderColor, width: 2),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(_bannerText, 
            style: TextStyle(color: _borderColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}