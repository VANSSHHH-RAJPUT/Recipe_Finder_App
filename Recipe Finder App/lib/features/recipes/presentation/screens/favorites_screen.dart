import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../backend/domain/entities/recipe.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/recipe_card.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesControllerProvider);
    final favoriteRecipes = favorites.values.toList();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FavoritesHeader(),
                const SizedBox(height: 18),
                _ViewModeToggle(
                  isGrid: _isGridView,
                  onChanged: (value) => setState(() => _isGridView = value),
                  totalCount: favoriteRecipes.length,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: favoriteRecipes.isEmpty
                      ? const _EmptyState()
                      : _FavoritesFeed(
                          recipes: favoriteRecipes,
                          isGrid: _isGridView,
                          onToggleFavorite: (recipe) => ref
                              .read(favoritesControllerProvider.notifier)
                              .toggleFavorite(recipe),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.favorites, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Your curated collection of saved meals.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({
    required this.isGrid,
    required this.onChanged,
    required this.totalCount,
  });

  final bool isGrid;
  final ValueChanged<bool> onChanged;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          borderRadius: 16,
          child: Text('$totalCount saved', style: theme.textTheme.labelLarge),
        ),
        const Spacer(),
        GlassContainer(
          padding: const EdgeInsets.all(6),
          borderRadius: 18,
          child: Row(
            children: [
              _ToggleIconButton(
                icon: Icons.view_agenda_rounded,
                active: !isGrid,
                onTap: () => onChanged(false),
              ),
              _ToggleIconButton(
                icon: Icons.grid_view_rounded,
                active: isGrid,
                onTap: () => onChanged(true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleIconButton extends StatelessWidget {
  const _ToggleIconButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: active
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 20,
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

class _FavoritesFeed extends StatelessWidget {
  const _FavoritesFeed({
    required this.recipes,
    required this.isGrid,
    required this.onToggleFavorite,
  });

  final List<Recipe> recipes;
  final bool isGrid;
  final ValueChanged<Recipe> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (isGrid)
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final recipe = recipes[index];
                return RecipeCard(
                  recipe: recipe,
                  isGrid: true,
                  isFavorite: true,
                  onTap: () => context.pushNamed(
                    'recipe-detail',
                    pathParameters: {'id': recipe.id},
                    extra: recipe,
                  ),
                  onToggleFavorite: () => onToggleFavorite(recipe),
                );
              }, childCount: recipes.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.74,
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final recipe = recipes[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == recipes.length - 1 ? 0 : 16,
                ),
                child: RecipeCard(
                  recipe: recipe,
                  isGrid: false,
                  isFavorite: true,
                  onTap: () => context.pushNamed(
                    'recipe-detail',
                    pathParameters: {'id': recipe.id},
                    extra: recipe,
                  ),
                  onToggleFavorite: () => onToggleFavorite(recipe),
                ),
              );
            }, childCount: recipes.length),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.noFavoritesTitle,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.noFavoritesSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
