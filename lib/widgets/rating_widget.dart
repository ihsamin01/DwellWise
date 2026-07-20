import 'package:flutter/material.dart';

/// Reusable star rating visualization widget.
class RatingWidget extends StatelessWidget {
  final double rating;
  final double iconSize;

  const RatingWidget({
    Key? key,
    required this.rating,
    this.iconSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: const Color(0xffF59E0B), size: iconSize),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
