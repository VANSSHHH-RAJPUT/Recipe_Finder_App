import '../../domain/entities/area.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_summary.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/local_recipe_cache_data_source.dart';
import '../datasources/meal_db_remote_data_source.dart';
import '../models/category_model.dart';
import '../models/meal_model.dart';
import '../models/recipe_summary_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  RecipeRepositoryImpl(this._remote, this._cache);

  final MealDbRemoteDataSource _remote;
  final LocalRecipeCacheDataSource _cache;
  bool _lastFetchUsedCache = false;

  @override
  bool get lastFetchUsedCache => _lastFetchUsedCache;

  @override
  Future<List<Recipe>> getRecipesByName(String name) async {
    try {
      final meals = await _remote.searchMealsByName(name);
      final recipes = meals.map(_mapMeal).toList();
      await _cache.cacheRecipes(recipes);
      _lastFetchUsedCache = false;
      return recipes;
    } catch (_) {
      _lastFetchUsedCache = true;
      return _filterCached(
        (recipe) => recipe.name.toLowerCase().contains(name.toLowerCase()),
      );
    }
  }

  @override
  Future<List<Recipe>> getRecipesByFirstLetter(String letter) async {
    try {
      final meals = await _remote.listMealsByLetter(letter);
      final recipes = meals.map(_mapMeal).toList();
      await _cache.cacheRecipes(recipes);
      _lastFetchUsedCache = false;
      return recipes;
    } catch (_) {
      _lastFetchUsedCache = true;
      return _filterCached(
        (recipe) => recipe.name.toLowerCase().startsWith(letter.toLowerCase()),
      );
    }
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    final cached = _cache.getRecipe(id);
    if (cached != null) {
      _lastFetchUsedCache = true;
      return cached;
    }

    final meal = await _remote.getMealDetails(id);
    if (meal == null) return null;
    final recipe = _mapMeal(meal);
    await _cache.cacheRecipe(recipe);
    _lastFetchUsedCache = false;
    return recipe;
  }

  @override
  Future<Recipe?> getRandomRecipe() async {
    final meal = await _remote.getRandomMeal();
    _lastFetchUsedCache = false;
    return meal == null ? null : _mapMeal(meal);
  }

  @override
  Future<List<Category>> getCategories() async {
    final categories = await _remote.getCategories();
    return categories.map(_mapCategory).toList();
  }

  @override
  Future<List<Area>> getAreas() async {
    final areas = await _remote.getAreas();
    return areas.map((name) => Area(name: name)).toList();
  }

  @override
  Future<List<String>> getIngredients() => _remote.getIngredients();

  @override
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final recipes = await _fetchFullRecipesFromSummaries(
        await getRecipeSummariesByCategory(category),
      );
      _lastFetchUsedCache = false;
      return recipes;
    } catch (_) {
      _lastFetchUsedCache = true;
      return _filterCached(
        (recipe) => recipe.category.toLowerCase() == category.toLowerCase(),
      );
    }
  }

  @override
  Future<List<Recipe>> getRecipesByArea(String area) async {
    try {
      final recipes = await _fetchFullRecipesFromSummaries(
        await getRecipeSummariesByArea(area),
      );
      _lastFetchUsedCache = false;
      return recipes;
    } catch (_) {
      _lastFetchUsedCache = true;
      return _filterCached(
        (recipe) => recipe.area.toLowerCase() == area.toLowerCase(),
      );
    }
  }

  @override
  Future<List<Recipe>> getRecipesByIngredient(String ingredient) async {
    try {
      final recipes = await _fetchFullRecipesFromSummaries(
        await getRecipeSummariesByIngredient(ingredient),
      );
      _lastFetchUsedCache = false;
      return recipes;
    } catch (_) {
      final lower = ingredient.toLowerCase();
      _lastFetchUsedCache = true;
      return _filterCached(
        (recipe) => recipe.ingredients.any(
          (item) => item.name.toLowerCase().contains(lower),
        ),
      );
    }
  }

  @override
  Future<List<RecipeSummary>> getRecipeSummariesByCategory(
    String category,
  ) async {
    final summaries = await _remote.filterByCategory(category);
    return summaries.map(_mapSummary).toList();
  }

  @override
  Future<List<RecipeSummary>> getRecipeSummariesByArea(String area) async {
    final summaries = await _remote.filterByArea(area);
    return summaries.map(_mapSummary).toList();
  }

  @override
  Future<List<RecipeSummary>> getRecipeSummariesByIngredient(
    String ingredient,
  ) async {
    final summaries = await _remote.filterByIngredient(ingredient);
    return summaries.map(_mapSummary).toList();
  }

  Future<List<Recipe>> _fetchFullRecipesFromSummaries(
    List<RecipeSummary> summaries,
  ) async {
    final detailFutures = summaries.map(
      (summary) => _remote.getMealDetails(summary.id),
    );
    final results = await Future.wait(detailFutures);
    final recipes = results.whereType<MealModel>().map(_mapMeal).toList();
    await _cache.cacheRecipes(recipes);
    return recipes;
  }

  Recipe _mapMeal(MealModel meal) {
    final ingredients = meal.ingredients
        .where((item) => item.name.isNotEmpty)
        .map((item) => IngredientItem(name: item.name, measure: item.measure))
        .toList();

    final instructions = _splitInstructions(meal.instructions);

    return Recipe(
      id: meal.id,
      name: meal.name,
      category: meal.category,
      area: meal.area,
      thumbnail: meal.thumbnail,
      description: meal.instructions,
      ingredients: ingredients,
      instructions: instructions,
      videoUrl: meal.youtubeUrl,
    );
  }

  Category _mapCategory(CategoryModel model) => Category(
    id: model.id,
    name: model.name,
    description: model.description,
    thumbnail: model.thumbnail,
  );

  RecipeSummary _mapSummary(RecipeSummaryModel model) =>
      RecipeSummary(id: model.id, name: model.name, thumbnail: model.thumbnail);

  List<String> _splitInstructions(String raw) {
    final lines = raw
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isNotEmpty) return lines;
    return raw
        .split('. ')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<Recipe> _filterCached(bool Function(Recipe recipe) predicate) {
    return _cache.getAllRecipes().where(predicate).toList();
  }
}
