import 'package:flutter/material.dart';

class StarRatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double size;

  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => onRatingChanged(index + 1),
          icon: Icon(
            index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.amber,
            size: size,
          ),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      }),
    );
  }
}
