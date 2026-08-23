import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../providers/locale_provider.dart';

/// Compact two-state language switch, sized to sit in the home app bar.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  /// Overall pill width, sized so 'English' — the wider label.
  static const double _width = 108;
  static const double _height = 30;
  static const double _inset = 3;

  static const Duration _slide = Duration(milliseconds: 220);
  static const Curve _slideCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final isBangla = localeProvider.language == AppLanguage.bangla;

    return Semantics(
      container: true,
      label: 'Language',
      value: isBangla ? 'বাংলা' : 'English',
      child: Container(
        height: _height,
        width: _width,
        padding: const EdgeInsets.all(_inset),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(_height / 2),
          border: Border.all(color: colors.border),
        ),
        child: Stack(
          children: [
            // The thumb slides across to sit under whichever label is active.
            AnimatedAlign(
              alignment:
                  isBangla ? Alignment.centerRight : Alignment.centerLeft,
              duration: _slide,
              curve: _slideCurve,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(_height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Positioned.fill gives the row tight constraints.
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: _Segment(
                      label: 'English',
                      selected: !isBangla,
                      onTap: () =>
                          localeProvider.setLanguage(AppLanguage.english),
                    ),
                  ),
                  Expanded(
                    child: _Segment(
                      label: 'বাংলা',
                      selected: isBangla,
                      onTap: () =>
                          localeProvider.setLanguage(AppLanguage.bangla),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One half of the pill.
class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        // The label colour crossfades on the same curve as the thumb.
        child: AnimatedDefaultTextStyle(
          duration: LanguageToggle._slide,
          curve: LanguageToggle._slideCurve,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : colors.textSecondary,
          ),
          child: Text(label, maxLines: 1),
        ),
      ),
    );
  }
}
