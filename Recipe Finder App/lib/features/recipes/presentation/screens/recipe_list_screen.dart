import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../backend/domain/entities/recipe.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/connectivity_notifier.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/recipe_list_controller.dart';
import '../state/recipe_list_state.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_list_skeleton.dart';
import '../widgets/recipe_search_bar.dart';

class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  late final TextEditingController _searchController;
  ProviderSubscription<RecipeListState>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _stateSubscription = ref.listenManual<RecipeListState>(
      recipeListControllerProvider,
      (previous, next) {
        if (_searchController.text != next.searchQuery) {
          _searchController.value = TextEditingValue(
            text: next.searchQuery,
            selection: TextSelection.collapsed(offset: next.searchQuery.length),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _stateSubscription?.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeState = ref.watch(recipeListControllerProvider);
    final favorites = ref.watch(favoritesControllerProvider);
    final isOffline = ref.watch(connectivityNotifierProvider);
    final isGridView = recipeState.viewMode == RecipeViewMode.grid;
    final showOfflineBanner = isOffline || recipeState.usedCacheFallback;
    final recipeController = ref.read(recipeListControllerProvider.notifier);

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
                const _IdentityHeader(),
                const SizedBox(height: 20),
                RecipeSearchBar(
                  controller: _searchController,
                  onChanged: recipeController.setSearchQuery,
                ),
                const SizedBox(height: 14),
                _IntentControls(
                  isGrid: isGridView,
                  activeFilters: recipeState.activeFiltersCount,
                  onSelectMode: recipeController.setViewMode,
                  onOpenFilters: () => _openFilters(context),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: recipeState.isLoading
                        ? RecipeListSkeleton(isGrid: isGridView)
                        : _RecipeFeed(
                            recipes: recipeState.filteredRecipes,
                            isGrid: isGridView,
                            favorites: favorites,
                            onRecipeTap: (recipe) {
                              context.pushNamed(
                                'recipe-detail',
                                pathParameters: {'id': recipe.id},
                                extra: recipe,
                              );
                            },
                            onToggleFavorite: (recipe) => ref
                                .read(favoritesControllerProvider.notifier)
                                .toggleFavorite(recipe),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: showOfflineBanner
                      ? _OfflineBanner(onRetry: recipeController.clearFilters)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openFilters(BuildContext context) async {
    final notifier = ref.read(recipeListControllerProvider.notifier);
    final state = ref.read(recipeListControllerProvider);
    if (state.categories.isEmpty &&
        state.areas.isEmpty &&
        state.ingredients.isEmpty) {
      notifier.refreshFilters();
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(initialState: state),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.initialState});

  final RecipeListState initialState;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late Set<String> _tempCategories;
  late Set<String> _tempAreas;
  late Set<String> _tempIngredients;
  late RecipeSortDirection _tempSort;

  bool _showSort = false;
  bool _showCategories = false;
  bool _showAreas = false;
  bool _showIngredients = false;

  @override
  void initState() {
    super.initState();
    _tempCategories = widget.initialState.selectedCategories.toSet();
    _tempAreas = widget.initialState.selectedAreas.toSet();
    _tempIngredients = widget.initialState.selectedIngredients.toSet();
    _tempSort = widget.initialState.sortDirection;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(recipeListControllerProvider.notifier);
    final filters = ref.watch(recipeListControllerProvider);

    final categories = filters.categories.isNotEmpty
        ? filters.categories
        : widget.initialState.categories;
    final areas = filters.areas.isNotEmpty
        ? filters.areas
        : widget.initialState.areas;
    final ingredients = filters.ingredients.isNotEmpty
        ? filters.ingredients
        : widget.initialState.ingredients;

    final filtersReady =
        categories.isNotEmpty && areas.isNotEmpty && ingredients.isNotEmpty;

    String formatSelection(Set<String> values, String fallback) {
      if (values.isEmpty) return fallback;
      if (values.length == 1) return values.first;
      return '${values.length} selected';
    }

    void clearAll() {
      setState(() {
        _tempCategories.clear();
        _tempAreas.clear();
        _tempIngredients.clear();
        _tempSort = RecipeSortDirection.az;
      });
      notifier.applyFilterSelection(
        categories: const [],
        areas: const [],
        ingredients: const [],
        sortDirection: RecipeSortDirection.az,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = MediaQuery.of(context).size.height * 0.8;
          return GlassContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: 28,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: filtersReady
                        ? SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Container(
                                    width: 48,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppStrings.filter,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    TextButton(
                                      onPressed: clearAll,
                                      child: Text(AppStrings.clearAll),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _FilterSection(
                                  label: AppStrings.sort,
                                  valueLabel:
                                      _tempSort == RecipeSortDirection.az
                                      ? AppStrings.sortAZ
                                      : AppStrings.sortZA,
                                  isExpanded: _showSort,
                                  onToggle: () {
                                    setState(() => _showSort = !_showSort);
                                  },
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: RecipeSortDirection.values.map((
                                      direction,
                                    ) {
                                      final isSelected = _tempSort == direction;
                                      final label =
                                          direction == RecipeSortDirection.az
                                          ? AppStrings.sortAZ
                                          : AppStrings.sortZA;
                                      return ChoiceChip(
                                        label: Text(label),
                                        selected: isSelected,
                                        onSelected: (_) {
                                          setState(() => _tempSort = direction);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _FilterSection(
                                  label: AppStrings.categories,
                                  valueLabel: formatSelection(
                                    _tempCategories,
                                    'All categories',
                                  ),
                                  isExpanded: _showCategories,
                                  onToggle: () {
                                    setState(
                                      () => _showCategories = !_showCategories,
                                    );
                                  },
                                  child: _FilterOptionsList(
                                    options: categories,
                                    selectedValues: _tempCategories,
                                    onToggle: (value) {
                                      setState(() {
                                        if (_tempCategories.contains(value)) {
                                          _tempCategories.remove(value);
                                        } else {
                                          _tempCategories.add(value);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _FilterSection(
                                  label: AppStrings.cuisines,
                                  valueLabel: formatSelection(
                                    _tempAreas,
                                    'All cuisines',
                                  ),
                                  isExpanded: _showAreas,
                                  onToggle: () {
                                    setState(() => _showAreas = !_showAreas);
                                  },
                                  child: _FilterOptionsList(
                                    options: areas,
                                    selectedValues: _tempAreas,
                                    onToggle: (value) {
                                      setState(() {
                                        if (_tempAreas.contains(value)) {
                                          _tempAreas.remove(value);
                                        } else {
                                          _tempAreas.add(value);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _FilterSection(
                                  label: AppStrings.ingredientFilter,
                                  valueLabel: formatSelection(
                                    _tempIngredients,
                                    'All ingredients',
                                  ),
                                  isExpanded: _showIngredients,
                                  onToggle: () {
                                    setState(
                                      () =>
                                          _showIngredients = !_showIngredients,
                                    );
                                  },
                                  child: _FilterOptionsList(
                                    options: ingredients,
                                    selectedValues: _tempIngredients,
                                    onToggle: (value) {
                                      setState(() {
                                        if (_tempIngredients.contains(value)) {
                                          _tempIngredients.remove(value);
                                        } else {
                                          _tempIngredients.add(value);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        notifier.applyFilterSelection(
                          categories: _tempCategories.toList(),
                          areas: _tempAreas.toList(),
                          ingredients: _tempIngredients.toList(),
                          sortDirection: _tempSort,
                        );
                        Navigator.of(context).pop();
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(AppStrings.apply),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: theme.colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.offlineTitle,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.offlineSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: AppStrings.apply,
          ),
        ],
      ),
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 2),
            Text(
              AppStrings.homeSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntentControls extends StatelessWidget {
  const _IntentControls({
    required this.isGrid,
    required this.activeFilters,
    required this.onSelectMode,
    required this.onOpenFilters,
  });

  final bool isGrid;
  final int activeFilters;
  final ValueChanged<RecipeViewMode> onSelectMode;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(6),
          borderRadius: 18,
          child: Row(
            children: [
              _ViewToggleIcon(
                icon: Icons.grid_view_rounded,
                active: isGrid,
                onTap: () => onSelectMode(RecipeViewMode.grid),
              ),
              _ViewToggleIcon(
                icon: Icons.view_agenda_rounded,
                active: !isGrid,
                onTap: () => onSelectMode(RecipeViewMode.list),
              ),
            ],
          ),
        ),
        const Spacer(),
        _FilterButton(
          activeFilters: activeFilters,
          onTap: onOpenFilters,
          label: AppStrings.filter,
          icon: Icons.tune_rounded,
          theme: theme,
        ),
      ],
    );
  }
}

class _ViewToggleIcon extends StatelessWidget {
  const _ViewToggleIcon({
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
          child: AnimatedScale(
            scale: active ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Icon(
              icon,
              size: 20,
              color: active
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.activeFilters,
    required this.onTap,
    required this.label,
    required this.icon,
    required this.theme,
  });

  final int activeFilters;
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GlassContainer(
          borderRadius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label, style: theme.textTheme.labelLarge),
              ],
            ),
          ),
        ),
        if (activeFilters > 0)
          Positioned(
            right: -4,
            top: -4,
            child: GlassContainer(
              padding: const EdgeInsets.all(6),
              borderRadius: 12,
              child: Text(
                activeFilters.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RecipeFeed extends StatelessWidget {
  const _RecipeFeed({
    required this.recipes,
    required this.isGrid,
    required this.favorites,
    required this.onRecipeTap,
    required this.onToggleFavorite,
  });

  final List<Recipe> recipes;
  final bool isGrid;
  final Map<String, Recipe> favorites;
  final ValueChanged<Recipe> onRecipeTap;
  final ValueChanged<Recipe> onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (recipes.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No recipes found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          )
        else if (isGrid)
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final recipe = recipes[index];
                return RecipeCard(
                  recipe: recipe,
                  isGrid: true,
                  isFavorite: favorites.containsKey(recipe.id),
                  onTap: () => onRecipeTap(recipe),
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
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final recipe = recipes[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == recipes.length - 1 ? 0 : 16,
                  ),
                  child: RecipeCard(
                    recipe: recipe,
                    isGrid: false,
                    isFavorite: favorites.containsKey(recipe.id),
                    onTap: () => onRecipeTap(recipe),
                    onToggleFavorite: () => onToggleFavorite(recipe),
                  ),
                );
              }, childCount: recipes.length),
            ),
          ),
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.label,
    required this.valueLabel,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  final String label;
  final String valueLabel;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      valueLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: child,
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class _FilterOptionsList extends StatelessWidget {
  const _FilterOptionsList({
    required this.options,
    required this.selectedValues,
    required this.onToggle,
  });

  final List<String> options;
  final Set<String> selectedValues;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (selectedValues.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                for (final value in selectedValues) {
                  onToggle(value);
                }
              },
              child: const Text('Clear all'),
            ),
          ),
        ...options.map(
          (option) => CheckboxListTile(
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(option),
            value: selectedValues.contains(option),
            onChanged: (isChecked) {
              if (isChecked == true) {
                onToggle(option);
              } else {
                onToggle(option);
              }
            },
            activeColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
