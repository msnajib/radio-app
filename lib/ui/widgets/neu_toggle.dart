import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

// FM/AM pill toggle.
// Figma: border 1px #1C1C1C, rounded 999px, padding 2px, bg #EFF1F2.
// Each item: 44 x 32 px; selected: rounded 100px, bg #333333, text #EFF1F2.
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
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.toggleBorder, width: 1),
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
                color: isActive ? AppColors.toggleSelectedBg : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text(
                  labels[i],
                  style: AppTypography.bandLabel.copyWith(
                    color: isActive
                        ? AppColors.toggleSelectedText
                        : AppColors.toggleUnselectedText,
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
