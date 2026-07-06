import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class PriceRangeSlider extends StatelessWidget {
  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;
  final double min;
  final double max;

  const PriceRangeSlider({
    Key? key,
    required this.values,
    required this.onChanged,
    required this.min,
    required this.max,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '৳${(values.start / 1000).toStringAsFixed(0)}k',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Text(
              '৳${(values.end / 1000).toStringAsFixed(0)}k${values.end >= max ? '+' : ''}',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: 28,
          labels: RangeLabels(
            '৳${(values.start / 1000).toStringAsFixed(0)}k',
            '৳${(values.end / 1000).toStringAsFixed(0)}k',
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
