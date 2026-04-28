import 'dart:math' show sqrt;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../bloc/city/city_cubit.dart';
import '../../core/constants/stations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/radio_theme.dart';

class CityPickerOverlay extends StatefulWidget {
  const CityPickerOverlay({super.key});

  static Future<void> show(BuildContext context) {
    final theme = context.radioTheme;
    return showModalBottomSheet(
      context: context,
      backgroundColor: theme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<CityCubit>(),
        child: const CityPickerOverlay(),
      ),
    );
  }

  @override
  State<CityPickerOverlay> createState() => _CityPickerOverlayState();
}

class _CityPickerOverlayState extends State<CityPickerOverlay> {
  bool _detecting = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.radioTheme;
    final selectedCity = context.watch<CityCubit>().state;
    final cities = cityCoordinates.keys.toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.surfaceSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Text(
            'Pilih Kota',
            style: AppTypography.appTitle.copyWith(color: theme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Stasiun radio disesuaikan dengan kota pilihan.',
            style: AppTypography.bodySmall.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: 16),

          // Use my location button
          _LocationButton(
            detecting: _detecting,
            onTap: () => _handleLocationTap(context),
          ),
          const SizedBox(height: 16),

          // City grid — 2 columns
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3.2,
            children: [
              for (final city in cities)
                _CityChip(
                  label: city,
                  selected: selectedCity == city,
                  onTap: () {
                    context.read<CityCubit>().selectCity(city);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),

          // "All cities" — only shown when a city is selected
          if (selectedCity != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                context.read<CityCubit>().selectCity(null);
                Navigator.pop(context);
              },
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Center(
                  child: Text(
                    'SEMUA KOTA',
                    style: AppTypography.buttonLabel.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleLocationTap(BuildContext context) async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return;
      _showDeniedForeverSnack(context);
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      if (context.mounted) await _detectAndApply(context);
      return;
    }

    // Need to request — show context sheet first
    if (!context.mounted) return;
    await _showPermissionContextSheet(context);
  }

  Future<void> _showPermissionContextSheet(BuildContext context) {
    final cityCubit = context.read<CityCubit>();
    final theme = context.radioTheme;
    return showModalBottomSheet(
      context: context,
      backgroundColor: theme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => _LocationPermissionSheet(
        onAllow: () async {
          Navigator.pop(sheetCtx);
          final permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            if (context.mounted) {
              await _detectAndApply(context, cubit: cityCubit);
            }
          }
        },
        onDismiss: () => Navigator.pop(sheetCtx),
      ),
    );
  }

  Future<void> _detectAndApply(BuildContext context, {CityCubit? cubit}) async {
    setState(() => _detecting = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      final city = _nearestCity(position.latitude, position.longitude);
      if (city != null && context.mounted) {
        (cubit ?? context.read<CityCubit>()).selectCity(city);
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  void _showDeniedForeverSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Izin lokasi diblokir. Aktifkan di Pengaturan > Aplikasi.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  String? _nearestCity(double lat, double lng) {
    double minDist = double.infinity;
    String? nearest;
    for (final entry in cityCoordinates.entries) {
      final dlat = entry.value.lat - lat;
      final dlng = entry.value.lng - lng;
      final dist = sqrt(dlat * dlat + dlng * dlng);
      if (dist < minDist) {
        minDist = dist;
        nearest = entry.key;
      }
    }
    // ~200 km radius ≈ 1.8 degrees — avoid snapping to wrong city for rural areas
    return minDist <= 1.8 ? nearest : null;
  }
}

// ── Location button ───────────────────────────────────────────────────────────

class _LocationButton extends StatelessWidget {
  final bool detecting;
  final VoidCallback onTap;

  const _LocationButton({required this.detecting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.radioTheme;
    return GestureDetector(
      onTap: detecting ? null : onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: theme.surfaceSecondary,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            if (detecting)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.textPrimary,
                ),
              )
            else
              Icon(
                Icons.my_location_rounded,
                size: 16,
                color: theme.textPrimary,
              ),
            Text(
              detecting ? 'Mendeteksi lokasi...' : 'Gunakan Lokasi Saat Ini',
              style: AppTypography.bandLabel.copyWith(color: theme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── City chip ─────────────────────────────────────────────────────────────────

class _CityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.radioTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? theme.textPrimary : theme.surfaceSecondary,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bandLabel.copyWith(
              color: selected ? theme.background : theme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Location permission context sheet ─────────────────────────────────────────

class _LocationPermissionSheet extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDismiss;

  const _LocationPermissionSheet({
    required this.onAllow,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.radioTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.surfaceSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.surfaceSecondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: 28,
              color: AppColors.dialNeedle,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Izinkan akses lokasi',
            style: AppTypography.appTitle.copyWith(color: theme.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Body
          Text(
            'Kami gunakan lokasi kamu untuk menampilkan stasiun dari kota terdekat. Lokasi tidak disimpan atau dibagikan.',
            style: AppTypography.bodySmall.copyWith(color: theme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Allow button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: GestureDetector(
              onTap: onAllow,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.textPrimary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    'IZINKAN',
                    style: AppTypography.buttonLabel.copyWith(
                      color: theme.background,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Dismiss button
          GestureDetector(
            onTap: onDismiss,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: Center(
                child: Text(
                  'Nanti saja',
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
