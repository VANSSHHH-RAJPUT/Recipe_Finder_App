import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_container.dart';

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    this.size = 48,
    this.onPressed,
    this.isActive = false,
  });

  final IconData icon;
  final double size;
  final VoidCallback? onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassContainer(
      height: size,
      width: size,
      borderRadius: size,
      padding: const EdgeInsets.all(12),
      onTap: onPressed,
      child: Icon(
        icon,
        color: isActive ? colorScheme.primary : colorScheme.onSurface,
      ),
    );
  }
}
