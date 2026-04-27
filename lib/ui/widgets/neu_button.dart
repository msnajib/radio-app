import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/core/services/sfx_service.dart';
import '../../core/theme/app_theme.dart';
import 'inner_shadow_box.dart';

// Primary pill button — flex-grow, height 52px, bg #333333, rounded 100px, inset shadow.
// Figma: inset 12 12 24 #3E3E3E, inset -12 -12 24 #1E1E1E
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
      child: AnimatedOpacity(
        opacity: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 60),
        child: InnerShadowBox(
          color: AppColors.buttonPrimaryBg,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A4A4A),            // light dark edge
              AppColors.buttonPrimaryBg,    // #333333 mid
              AppColors.buttonPrimaryInset2, // #1E1E1E deep shadow
            ],
            stops: [0.0, 0.45, 1.0],
          ),
          shadows: AppInsetShadows.buttonPrimary,
          borderRadius: 100,
          height: 52,
          child: Center(
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: AppColors.buttonPrimaryText,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(widget.label, style: AppTypography.buttonLabel),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// Secondary pill button — 80x52px, bg #DEE4E6, rounded 100px, inset shadow.
// Figma: inset 12 12 24 #DEE4E6, inset -12 -12 24 #B7C1C5
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
      child: AnimatedOpacity(
        opacity: _pressed ? 0.80 : 1.0,
        duration: const Duration(milliseconds: 60),
        child: InnerShadowBox(
          color: AppColors.buttonSecondaryBg,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),   // bright highlight
              Color(0xFFE2E2E2),   // neutral gray mid
              Color(0xFFABABAB),   // neutral gray shadow
            ],
            stops: [0.0, 0.4, 1.0],
          ),
          shadows: AppInsetShadows.buttonSecondary,
          borderRadius: 100,
          width: widget.width,
          height: widget.height,
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
