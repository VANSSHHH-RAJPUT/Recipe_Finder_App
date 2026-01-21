import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/color_palette.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final gradient = isLight
        ? AppGradients.lightBackground
        : AppGradients.darkBackground;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          // soft blobs
          Positioned(
            top: -120,
            left: -80,
            child: _BlurredBlob(
              size: 260,
              color: isLight
                  ? AppColors.accentFresh.withValues(alpha: 0.25)
                  : Colors.white10,
            ),
          ),
          Positioned(
            bottom: -140,
            right: -60,
            child: _BlurredBlob(
              size: 320,
              color: isLight
                  ? AppColors.accentWarm.withValues(alpha: 0.25)
                  : Colors.white10,
            ),
          ),
          // subtle noise overlay using gradients
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: isLight ? 0.04 : 0.02),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _BlurredBlob extends StatelessWidget {
  const _BlurredBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
          child: const SizedBox(),
        ),
      ),
    );
  }
}
