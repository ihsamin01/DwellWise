import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class StepIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const StepIndicator({
    Key? key,
    required this.count,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isSelected = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isSelected ? 24 : 8,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.high,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
