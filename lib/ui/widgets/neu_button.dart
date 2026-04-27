import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/core/services/sfx_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

// Shared sphere-style button shell — colors are fixed (physical element).
Widget _sphereShell({
  required Widget child,
  required bool isPrimary,
  required bool pressed,
  double? width,
  required double height,
}) {
  return AnimatedScale(
    scale: pressed ? 0.96 : 1.0,
    duration: const Duration(milliseconds: 60),
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPrimary
              ? const [AppColors.buttonPrimaryRingLight, AppColors.buttonPrimaryRingDark]
              : const [AppColors.buttonSecondaryRingLight, AppColors.buttonSecondaryRingDark],
        ),
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: RadialGradient(
            center: const Alignment(-0.2, -0.5),
            radius: 1.3,
            colors: isPrimary
                ? const [
                    AppColors.buttonPrimaryBodyLight,
                    AppColors.buttonPrimaryBodyMid,
                    AppColors.buttonPrimaryBodyDark,
                  ]
                : const [
                    AppColors.buttonSecondaryBodyLight,
                    AppColors.buttonSecondaryBodyMid,
                    AppColors.buttonSecondaryBodyDark,
                  ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: Center(child: child),
      ),
    ),
  );
}

// ── Primary button ────────────────────────────────────────────────────────────

class NeuButtonPrimary extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const NeuButtonPrimary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<NeuButtonPrimary> createState() => _NeuButtonPrimaryState();
}

class _NeuButtonPrimaryState extends State<NeuButtonPrimary> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        context.read<SfxService>().playTapDown();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        context.read<SfxService>().playTapUp();
        setState(() => _pressed = false);
        HapticFeedback.mediumImpact();
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: _sphereShell(
        isPrimary: true,
        pressed: _pressed,
        height: 52,
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.buttonPrimaryText,
                ),
              )
            : Row(
                spacing: 4,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null)
                    Icon(
                      widget.icon,
                      color: AppColors.buttonPrimaryText,
                      size: 24,
                    ),
                  Text(
                    widget.label,
                    style: AppTypography.buttonLabel,
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Secondary button ──────────────────────────────────────────────────────────

class NeuButtonSecondary extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  const NeuButtonSecondary({
    super.key,
    required this.child,
    this.onPressed,
    this.width = 80,
    this.height = 52,
  });

  @override
  State<NeuButtonSecondary> createState() => _NeuButtonSecondaryState();
}

class _NeuButtonSecondaryState extends State<NeuButtonSecondary> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        context.read<SfxService>().playTapDown();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        context.read<SfxService>().playTapUp();
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: _sphereShell(
        isPrimary: false,
        pressed: _pressed,
        width: widget.width,
        height: widget.height,
        child: widget.child,
      ),
    );
  }
}
