import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/radio_theme.dart';
import '../../data/models/station.dart';

class StationListOverlay extends StatelessWidget {
  final List<Station> stations;
  final ValueChanged<Station> onStationSelected;

  const StationListOverlay({
    super.key,
    required this.stations,
    required this.onStationSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Station> stations,
    required ValueChanged<Station> onStationSelected,
  }) {
    final theme = context.radioTheme;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StationListOverlay(
        stations: stations,
        onStationSelected: onStationSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.radioTheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.surfaceSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Stasiun',
                  style: AppTypography.appTitle.copyWith(
                    color: theme.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: stations.length,
                itemBuilder: (_, i) {
                  final s = stations[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 4,
                    ),
                    title: Text(
                      s.name,
                      style: AppTypography.body.copyWith(
                        color: theme.textPrimary,
                      ),
                    ),
                    subtitle: s.fmFrequency != null
                        ? Text(
                            '${s.fmFrequency!.toStringAsFixed(1)} MHz',
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.textSecondary,
                            ),
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      onStationSelected(s);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
