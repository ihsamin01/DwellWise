import 'package:flutter/material.dart';
import '../constants/colors.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  final bool showText;

  const VerifiedBadge({
    Key? key,
    this.size = 18,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showText ? 8 : 4,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: size,
            color: AppColors.success,
          ),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              'Verified',
              style: TextStyle(
                color: AppColors.success,
                fontSize: size * 0.75,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
