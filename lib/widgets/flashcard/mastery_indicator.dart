import 'package:flutter/material.dart';

/// 一個視覺化顯示單字卡熟練度的 Widget
class MasteryIndicator extends StatelessWidget {
  final int masteryLevel;
  final int maxLevel;

  const MasteryIndicator({
    super.key,
    required this.masteryLevel,
    this.maxLevel = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLevel, (index) {
        return Icon(
          index < masteryLevel ? Icons.circle : Icons.circle_outlined,
          size: 12,
          color: index < masteryLevel ? Colors.amber.shade700 : Colors.grey,
        );
      }),
    );
  }
}