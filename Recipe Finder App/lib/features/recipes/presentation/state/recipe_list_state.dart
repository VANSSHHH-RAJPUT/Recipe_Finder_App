import '../../../../backend/domain/entities/recipe.dart';

enum RecipeViewMode { grid, list }

enum RecipeSortDirection { az, za }

class RecipeListState {
  RecipeListState({
    required this.isLoading,
    required this.allRecipes,
    required this.filteredRecipes,
    required this.categories,
    required this.areas,
    required this.viewMode,
    required this.sortDirection,
    required this.searchQuery,
    required this.selectedCategories,
    required this.selectedAreas,
    required this.ingredients,
    required this.selectedIngredients,
    required this.errorMessage,
    required this.usedCacheFallback,
  });

  factory RecipeListState.initial() => RecipeListState(
    isLoading: true,
    allRecipes: const [],
    filteredRecipes: const [],
    categories: const [],
    areas: const [],
    viewMode: RecipeViewMode.grid,
    sortDirection: RecipeSortDirection.az,
    searchQuery: '',
    selectedCategories: const [],
    selectedAreas: const [],
    ingredients: const [],
    selectedIngredients: const [],
    errorMessage: null,
    usedCacheFallback: false,
  );

  final bool isLoading;
  final List<Recipe> allRecipes;
  final List<Recipe> filteredRecipes;
  final List<String> categories;
  final List<String> areas;
  final List<String> ingredients;
  final RecipeViewMode viewMode;
  final RecipeSortDirection sortDirection;
  final String searchQuery;
  final List<String> selectedCategories;
  final List<String> selectedAreas;
  final List<String> selectedIngredients;
  final String? errorMessage;
  final bool usedCacheFallback;

  int get activeFiltersCount {
    int count = 0;
    count += selectedCategories.length;
    count += selectedAreas.length;
    count += selectedIngredients.length;
    return count;
  }

  RecipeListState copyWith({
    bool? isLoading,
    List<Recipe>? allRecipes,
    List<Recipe>? filteredRecipes,
    List<String>? categories,
    List<String>? areas,
    List<String>? ingredients,
    RecipeViewMode? viewMode,
    RecipeSortDirection? sortDirection,
    String? searchQuery,
    List<String>? selectedCategories,
    List<String>? selectedAreas,
    List<String>? selectedIngredients,
    String? errorMessage,
    bool? usedCacheFallback,
  }) {
    return RecipeListState(
      isLoading: isLoading ?? this.isLoading,
      allRecipes: allRecipes ?? this.allRecipes,
      filteredRecipes: filteredRecipes ?? this.filteredRecipes,
      categories: categories ?? this.categories,
      areas: areas ?? this.areas,
      ingredients: ingredients ?? this.ingredients,
      viewMode: viewMode ?? this.viewMode,
      sortDirection: sortDirection ?? this.sortDirection,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedAreas: selectedAreas ?? this.selectedAreas,
      selectedIngredients: selectedIngredients ?? this.selectedIngredients,
      errorMessage: errorMessage ?? this.errorMessage,
      usedCacheFallback: usedCacheFallback ?? this.usedCacheFallback,
    );
  }
}
