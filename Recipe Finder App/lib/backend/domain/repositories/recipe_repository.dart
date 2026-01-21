import '../entities/area.dart';
import '../entities/category.dart';
import '../entities/recipe.dart';
import '../entities/recipe_summary.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getRecipesByName(String name);
  Future<List<Recipe>> getRecipesByFirstLetter(String letter);
  Future<Recipe?> getRecipeById(String id);
  Future<Recipe?> getRandomRecipe();
  bool get lastFetchUsedCache;

  Future<List<Category>> getCategories();
  Future<List<Area>> getAreas();
  Future<List<String>> getIngredients();

  Future<List<Recipe>> getRecipesByCategory(String category);
  Future<List<Recipe>> getRecipesByArea(String area);
  Future<List<Recipe>> getRecipesByIngredient(String ingredient);

  Future<List<RecipeSummary>> getRecipeSummariesByCategory(String category);
  Future<List<RecipeSummary>> getRecipeSummariesByArea(String area);
  Future<List<RecipeSummary>> getRecipeSummariesByIngredient(String ingredient);
}
