import 'package:flutter/material.dart';
import 'package:foodie/services/ai_chat.dart';
import 'package:provider/provider.dart';

class AiRecommendationButton extends StatelessWidget {
  final String msg, userId;

  const AiRecommendationButton({Key? key, required this.msg, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderSide = Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        side: BorderSide(
          color: borderSide?.color ?? Theme.of(context).colorScheme.outline,
          width: borderSide?.width ?? 1.0,
        ),
      ),
      onPressed: () async {
        await context.read<AiChatService>().addMessage(Message(text: msg), userId);
      },
      child: Text(
        msg,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
