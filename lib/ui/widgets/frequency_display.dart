import 'package:flutter/material.dart';
import '../../core/constants/frequencies.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';

// Figma: width 192px, centered. Frequency: Geist Mono ExtraBold 64px.
// Station name: Geist Regular 12px, uppercase, #4E4E4E.
class FrequencyDisplay extends StatelessWidget {
  final double dialPosition;
  final Band band;
  final String? stationName;

  const FrequencyDisplay({
    super.key,
    required this.dialPosition,
    required this.band,
    this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    final freqStr = Formatters.frequencyFromPosition(dialPosition, band);

    return SizedBox(
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            freqStr,
            style: AppTypography.frequencyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: stationName != null
                ? Text(
                    stationName!.toUpperCase(),
                    key: ValueKey(stationName),
                    style: AppTypography.stationName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    '– – –',
                    key: const ValueKey('no_station'),
                    style: AppTypography.stationName,
                  ),
          ),
        ],
      ),
    );
  }
}
