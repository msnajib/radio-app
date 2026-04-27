import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// Plain flat container — no shadows. Use InnerShadowBox for button-style containers.
class NeuContainer extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final VoidCallback? onTap;

  const NeuContainer({
    super.key,
    this.child,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.background,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }
    return container;
  }
}
