import 'package:flutter/material.dart';

class RatingSummaryCard extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> distribution;

  const RatingSummaryCard({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(averageRating.toStringAsFixed(1), style: textTheme.displaySmall),
                Text('($totalReviews)', style: textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final count = distribution[star] ?? 0;
                final percentage = totalReviews > 0 ? count / totalReviews : 0.0;
                return Row(
                  children: [
                    Text('$star', style: textTheme.labelMedium!.copyWith(color: colorScheme.onSurfaceVariant)),
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: colorScheme.secondaryContainer,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
