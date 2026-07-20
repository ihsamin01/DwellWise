import 'package:flutter/material.dart';

/// Customized loading animation widget.
class LoadingSpinner extends StatelessWidget {
  final Color? color;
  final double size;

  const LoadingSpinner({
    Key? key,
    this.color,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? const Color(0xff1E40AF);
    
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
        ),
      ),
    );
  }
}
