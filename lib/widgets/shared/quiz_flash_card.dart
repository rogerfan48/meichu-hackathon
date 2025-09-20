import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../../models/card_model.dart';
import '../firebase_image.dart';

/// 專門用於測驗模式的單張卡片 Widget
class QuizFlashCard extends StatelessWidget {
  final StudyCard card;
  const QuizFlashCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      front: _buildCardSide(
        context: context,
        child: Text(card.text, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      ),
      back: _buildCardSide(
        context: context,
        child: (card.imgURL != null && card.imgURL!.startsWith('gs://'))
            ? ClipRRect(borderRadius: BorderRadius.circular(16), child: FirebaseImage(gsUri: card.imgURL!, fit: BoxFit.cover))
            : Center(child: Text('此卡片沒有圖片', style: TextStyle(color: Colors.grey[600]))),
      ),
    );
  }

  Widget _buildCardSide({required BuildContext context, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: child,
        ),
      ),
    );
  }
}