import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/color_palette.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 18,
    this.opacity,
    this.borderOpacity,
    this.gradient,
    this.onTap,
    this.height,
    this.width,
  });

  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blur;
  final double? opacity;
  final double? borderOpacity;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final bgColor = (isLight ? Colors.white : Colors.white).withValues(
      alpha: opacity ?? (isLight ? 0.2 : 0.1),
    );
    final borderColor =
        (isLight ? AppColors.glassBorderLight : AppColors.glassBorderDark)
            .withValues(alpha: borderOpacity ?? 1);

    final content = Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient:
            gradient ??
            LinearGradient(
              colors: [
                bgColor,
                bgColor.withValues(alpha: isLight ? 0.6 : 0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isLight
                ? Colors.black.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              highlightColor: Colors.transparent,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
