import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../backend/backend_providers.dart';
import '../../../../backend/data/datasources/settings_local_data_source.dart';
import '../../../../backend/domain/entities/recipe.dart';
import '../../../../backend/domain/repositories/recipe_repository.dart';
import '../state/recipe_list_state.dart';
import '../../../../core/utils/list_utils.dart';

final recipeListControllerProvider =
    StateNotifierProvider<RecipeListController, RecipeListState>(
      (ref) => RecipeListController(
        repository: ref.watch(recipeRepositoryProvider),
        settingsLocalDataSource: ref.watch(settingsLocalDataSourceProvider),
      ),
    );

class RecipeListController extends StateNotifier<RecipeListState> {
  RecipeListController({
    required RecipeRepository repository,
    required SettingsLocalDataSource settingsLocalDataSource,
    bool loadInitialData = true,
  }) : _repository = repository,
       _settingsLocalDataSource = settingsLocalDataSource,
       super(RecipeListState.initial()) {
    if (loadInitialData) {
      _loadInitial();
    }
  }

  final RecipeRepository _repository;
  final SettingsLocalDataSource _settingsLocalDataSource;
  Timer? _debounce;
  String? _lastRequestKey;
  final Map<String, List<Recipe>> _resultsCache = {};
  static const int _maxCacheEntries = 12;

  Future<void> _loadInitial() async {
    await Future.wait([
      _loadFilters(),
      _loadViewPreference(),
      _fetchRecipes(initial: true),
    ]);
  }

  Future<void> _loadViewPreference() async {
    final saved = _settingsLocalDataSource.getViewModePreference();
    if (saved == null) return;
    final normalized = saved.toLowerCase();
    final mode = RecipeViewMode.values.firstWhere(
      (m) => m.name.toLowerCase() == normalized,
      orElse: () => state.viewMode,
    );
    state = state.copyWith(viewMode: mode);
  }

  Future<void> _loadFilters() async {
    try {
      final categoriesFuture = _repository.getCategories();
      final areasFuture = _repository.getAreas();
      final ingredientsFuture = _repository.getIngredients();

      final categories = await categoriesFuture;
      final areas = await areasFuture;
      final ingredients = await ingredientsFuture;
      state = state.copyWith(
        categories: categories.map((c) => c.name).toList(),
        areas: areas.map((a) => a.name).toList(),
        ingredients: ingredients,
      );
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to load filters');
    }
  }

  void toggleViewMode() {
    state = state.copyWith(
      viewMode: state.viewMode == RecipeViewMode.grid
          ? RecipeViewMode.list
          : RecipeViewMode.grid,
    );
  }

  void toggleSortDirection() {
    state = state.copyWith(
      sortDirection: state.sortDirection == RecipeSortDirection.az
          ? RecipeSortDirection.za
          : RecipeSortDirection.az,
    );
    _sortCurrentRecipesInState();
  }

  void setViewMode(RecipeViewMode mode) {
    if (state.viewMode == mode) return;
    state = state.copyWith(viewMode: mode);
    _settingsLocalDataSource.saveViewModePreference(mode.name);
  }

  void setSortDirection(RecipeSortDirection direction) {
    if (state.sortDirection == direction) return;
    state = state.copyWith(sortDirection: direction);
    _sortCurrentRecipesInState();
  }

  void setSearchQuery(String query) {
    final normalized = query.trim();
    if (normalized == state.searchQuery.trim()) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(searchQuery: normalized);
      _fetchRecipes();
    });
  }

  void applyFilterSelection({
    List<String>? categories,
    List<String>? areas,
    List<String>? ingredients,
    RecipeSortDirection? sortDirection,
  }) {
    final normalizedCategories = normalizeStringList(categories);
    final normalizedAreas = normalizeStringList(areas);
    final normalizedIngredients = normalizeStringList(ingredients);

    final filtersChanged =
        !haveSameItemsIgnoreCase(
          normalizedCategories,
          state.selectedCategories,
        ) ||
        !haveSameItemsIgnoreCase(normalizedAreas, state.selectedAreas) ||
        !haveSameItemsIgnoreCase(
          normalizedIngredients,
          state.selectedIngredients,
        );
    final sortChanged =
        sortDirection != null && sortDirection != state.sortDirection;

    if (!filtersChanged && !sortChanged) {
      return;
    }

    state = state.copyWith(
      selectedCategories: normalizedCategories,
      selectedAreas: normalizedAreas,
      selectedIngredients: normalizedIngredients,
      sortDirection: sortDirection ?? state.sortDirection,
    );

    if (filtersChanged) {
      _fetchRecipes(force: true);
    } else if (sortChanged) {
      _sortCurrentRecipesInState();
    }
  }

  Future<void> refreshFilters() => _loadFilters();

  void clearFilters() {
    if (state.selectedAreas.isEmpty &&
        state.selectedCategories.isEmpty &&
        state.selectedIngredients.isEmpty &&
        state.searchQuery.isEmpty) {
      return;
    }
    state = state.copyWith(
      selectedAreas: const [],
      selectedCategories: const [],
      selectedIngredients: const [],
      searchQuery: '',
    );
    _fetchRecipes(force: true);
  }

  Future<void> _fetchRecipes({bool initial = false, bool force = false}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      usedCacheFallback: false,
    );
    final search = state.searchQuery.trim();
    final categories = state.selectedCategories;
    final areas = state.selectedAreas;
    final ingredients = state.selectedIngredients;
    final requestKey = _buildRequestKey(
      search: search,
      categories: categories,
      areas: areas,
      ingredients: ingredients,
    );

    if (!force) {
      final cached = _resultsCache[requestKey];
      if (cached != null) {
        state = state.copyWith(
          isLoading: false,
          allRecipes: cached,
          filteredRecipes: cached,
          errorMessage: cached.isEmpty ? 'No recipes found' : null,
          usedCacheFallback: false,
        );
        _lastRequestKey = requestKey;
        return;
      }
      if (!initial &&
          _lastRequestKey == requestKey &&
          state.filteredRecipes.isNotEmpty) {
        state = state.copyWith(isLoading: false);
        _sortCurrentRecipesInState();
        return;
      }
    }

    try {
      List<Recipe> recipes;
      if (search.isNotEmpty) {
        recipes = await _repository.getRecipesByName(search);
      } else if (categories.isNotEmpty) {
        recipes = await _fetchByCategories(categories);
      } else if (areas.isNotEmpty) {
        recipes = await _fetchByAreas(areas);
      } else if (ingredients.isNotEmpty) {
        recipes = await _fetchByIngredients(ingredients);
      } else {
        recipes = await _repository.getRecipesByFirstLetter('a');
      }

      recipes = _applyFilters(
        recipes,
        search: search,
        categories: categories,
        areas: areas,
        ingredients: ingredients,
      );
      recipes = _sortRecipes(recipes);
      _lastRequestKey = requestKey;
      _storeInCache(requestKey, recipes);

      state = state.copyWith(
        isLoading: false,
        allRecipes: recipes,
        filteredRecipes: recipes,
        errorMessage: recipes.isEmpty ? 'No recipes found' : null,
        usedCacheFallback: _repository.lastFetchUsedCache,
      );
    } catch (error) {
      _lastRequestKey = null;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load recipes. Please try again.',
        usedCacheFallback: false,
      );
    }
  }

  List<Recipe> _applyFilters(
    List<Recipe> recipes, {
    required String search,
    required List<String> categories,
    required List<String> areas,
    required List<String> ingredients,
  }) {
    final searchLower = search.toLowerCase();
    final categorySet = categories.map((e) => e.toLowerCase()).toSet();
    final areaSet = areas.map((e) => e.toLowerCase()).toSet();
    final ingredientSet = ingredients.map((e) => e.toLowerCase()).toSet();

    return recipes.where((recipe) {
      if (search.isNotEmpty &&
          !recipe.name.toLowerCase().contains(searchLower)) {
        return false;
      }

      if (categorySet.isNotEmpty &&
          !categorySet.contains(recipe.category.toLowerCase())) {
        return false;
      }

      if (areaSet.isNotEmpty && !areaSet.contains(recipe.area.toLowerCase())) {
        return false;
      }

      if (ingredientSet.isNotEmpty &&
          !_recipeContainsAnyIngredient(recipe, ingredientSet)) {
        return false;
      }
      return true;
    }).toList();
  }

  bool _recipeContainsAnyIngredient(Recipe recipe, Set<String> ingredientSet) {
    for (final item in recipe.ingredients) {
      final name = item.name.toLowerCase();
      if (ingredientSet.any((needle) => name.contains(needle))) {
        return true;
      }
    }
    return false;
  }

  List<Recipe> _sortRecipes(List<Recipe> recipes) {
    final sorted = List<Recipe>.from(recipes);
    sorted.sort(
      (a, b) => state.sortDirection == RecipeSortDirection.az
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name),
    );
    return sorted;
  }

  void _sortCurrentRecipesInState() {
    final sorted = _sortRecipes(state.filteredRecipes);
    state = state.copyWith(filteredRecipes: sorted);
  }

  Future<List<Recipe>> _fetchByCategories(List<String> categories) async {
    final requests = categories.map(_repository.getRecipesByCategory);
    final results = await Future.wait(requests);
    return _mergeResults(results);
  }

  Future<List<Recipe>> _fetchByAreas(List<String> areas) async {
    final requests = areas.map(_repository.getRecipesByArea);
    final results = await Future.wait(requests);
    return _mergeResults(results);
  }

  Future<List<Recipe>> _fetchByIngredients(List<String> ingredients) async {
    final requests = ingredients.map(_repository.getRecipesByIngredient);
    final results = await Future.wait(requests);
    return _mergeResults(results);
  }

  List<Recipe> _mergeResults(List<List<Recipe>> resultLists) {
    final map = <String, Recipe>{};
    for (final list in resultLists) {
      for (final recipe in list) {
        map[recipe.id] = recipe;
      }
    }
    return map.values.toList();
  }

  String _buildRequestKey({
    required String search,
    required List<String> categories,
    required List<String> areas,
    required List<String> ingredients,
  }) =>
      '${search.toLowerCase()}|'
      '${categories.join(',').toLowerCase()}|'
      '${areas.join(',').toLowerCase()}|'
      '${ingredients.join(',').toLowerCase()}';

  void _storeInCache(String key, List<Recipe> recipes) {
    _resultsCache[key] = List.unmodifiable(recipes);
    if (_resultsCache.length > _maxCacheEntries) {
      final oldestKey = _resultsCache.keys.first;
      _resultsCache.remove(oldestKey);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
