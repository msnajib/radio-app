import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/radio_theme.dart';

// FM/AM pill toggle.
class NeuToggle extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const NeuToggle({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.radioTheme;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.background,
        border: Border.all(color: theme.toggleBorder, width: 1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (i) {
          final isActive = i == selectedIndex;
          return GestureDetector(
            onTap: () {
              if (!isActive) {
                HapticFeedback.selectionClick();
                onChanged(i);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              width: 44,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? theme.toggleSelectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text(
                  labels[i],
                  style: AppTypography.bandLabel.copyWith(
                    color: isActive
                        ? theme.toggleSelectedText
                        : theme.toggleBorder,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
