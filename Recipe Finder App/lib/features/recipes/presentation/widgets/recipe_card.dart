import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../backend/domain/entities/recipe.dart';
import '../../../../core/widgets/glass_container.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isGrid,
    required this.onTap,
    required this.onToggleFavorite,
    this.isFavorite = false,
  });

  final Recipe recipe;
  final bool isGrid;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    final theme = Theme.of(context);
    final reducedTitleStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: math.max(
        16.0,
        (theme.textTheme.titleMedium?.fontSize ?? 18) - 2,
      ),
      height: 1.15,
      fontWeight: FontWeight.w600,
    );

    final favoriteButton = _FavoriteIconButton(
      key: Key('favorite-${recipe.id}'),
      isFavorite: isFavorite,
      onToggleFavorite: onToggleFavorite,
    );

    final cardContent = isGrid
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageSection(recipe: recipe, radius: radius),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: reducedTitleStyle,
                        ),
                        const SizedBox(height: 6),
                        _CategoryAreaLine(recipe: recipe),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  favoriteButton,
                ],
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                flex: 4,
                child: _ImageSection(recipe: recipe, radius: radius),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: reducedTitleStyle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        favoriteButton,
                      ],
                    ),
                    const SizedBox(height: 6),
                    _CategoryAreaLine(recipe: recipe),
                  ],
                ),
              ),
            ],
          );

    return GlassContainer(
      onTap: onTap,
      padding: EdgeInsets.all(isGrid ? 18 : 16),
      child: cardContent,
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({required this.recipe, required this.radius});

  final Recipe recipe;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'recipe-image-${recipe.id}',
      child: ClipRRect(
        borderRadius: radius,
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: CachedNetworkImage(
            imageUrl: recipe.thumbnail,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
      ),
    );
  }
}

class _CategoryAreaLine extends StatelessWidget {
  const _CategoryAreaLine({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
    );
    return Text(
      '${recipe.category} · ${recipe.area}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );
  }
}

class _FavoriteIconButton extends StatelessWidget {
  const _FavoriteIconButton({
    super.key,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = isFavorite
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return GestureDetector(
      onTap: onToggleFavorite,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
        ),
        child: AnimatedScale(
          scale: isFavorite ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
