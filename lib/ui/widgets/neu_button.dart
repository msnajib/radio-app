import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/core/services/sfx_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/radio_theme.dart';

class _SphereColors {
  final Color ringLight;
  final Color ringDark;
  final Color bodyLight;
  final Color bodyMid;
  final Color bodyDark;

  const _SphereColors({
    required this.ringLight,
    required this.ringDark,
    required this.bodyLight,
    required this.bodyMid,
    required this.bodyDark,
  });
}

Widget _sphereShell({
  required Widget child,
  required _SphereColors colors,
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
          colors: [colors.ringLight, colors.ringDark],
        ),
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: RadialGradient(
            center: const Alignment(-0.2, -0.5),
            radius: 1.3,
            colors: [colors.bodyLight, colors.bodyMid, colors.bodyDark],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: Center(child: child),
      ),
    ),
  );
}

// Fixed secondary sphere colors — prev/next are physical elements, never themed.
const _SphereColors _secondaryColors = _SphereColors(
  ringLight: AppColors.buttonSecondaryRingLight,
  ringDark: AppColors.buttonSecondaryRingDark,
  bodyLight: AppColors.buttonSecondaryBodyLight,
  bodyMid: AppColors.buttonSecondaryBodyMid,
  bodyDark: AppColors.buttonSecondaryBodyDark,
);

// ── Primary button (Play/Pause) — follows theme ───────────────────────────────

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
    final theme = context.radioTheme;
    final colors = _SphereColors(
      ringLight: theme.btnPriRingLight,
      ringDark: theme.btnPriRingDark,
      bodyLight: theme.btnPriBodyLight,
      bodyMid: theme.btnPriBodyMid,
      bodyDark: theme.btnPriBodyDark,
    );
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
        colors: colors,
        pressed: _pressed,
        height: 52,
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.btnPriText,
                ),
              )
            : Row(
                spacing: 4,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null)
                    Icon(widget.icon, color: theme.btnPriText, size: 24),
                  Text(
                    widget.label,
                    style: AppTypography.buttonLabel.copyWith(
                      color: theme.btnPriText,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Secondary button (Prev/Next) — fixed, physical element ────────────────────

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
        colors: _secondaryColors,
        pressed: _pressed,
        width: widget.width,
        height: widget.height,
        child: widget.child,
      ),
    );
  }
}
