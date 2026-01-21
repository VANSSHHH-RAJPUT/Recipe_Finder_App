import 'package:dio/dio.dart';

import '../../core/api_config.dart';
import '../models/category_model.dart';
import '../models/meal_model.dart';
import '../models/recipe_summary_model.dart';

abstract class MealDbRemoteDataSource {
  Future<List<MealModel>> searchMealsByName(String query);
  Future<List<MealModel>> listMealsByLetter(String letter);
  Future<MealModel?> getMealDetails(String id);
  Future<MealModel?> getRandomMeal();

  Future<List<CategoryModel>> getCategories();
  Future<List<String>> getAreas();
  Future<List<String>> getIngredients();

  Future<List<RecipeSummaryModel>> filterByCategory(String category);
  Future<List<RecipeSummaryModel>> filterByArea(String area);
  Future<List<RecipeSummaryModel>> filterByIngredient(String ingredient);
}

class MealDbRemoteDataSourceImpl implements MealDbRemoteDataSource {
  MealDbRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<MealModel>> searchMealsByName(String query) async {
    if (query.trim().isEmpty) return const [];
    final response = await _dio.get(
      '$mealDbBaseUrl/search.php',
      queryParameters: {'s': query},
    );
    return _mapMeals(response.data);
  }

  @override
  Future<List<MealModel>> listMealsByLetter(String letter) async {
    if (letter.isEmpty) return const [];
    final response = await _dio.get(
      '$mealDbBaseUrl/search.php',
      queryParameters: {'f': letter},
    );
    return _mapMeals(response.data);
  }

  @override
  Future<MealModel?> getMealDetails(String id) async {
    if (id.isEmpty) return null;
    final response = await _dio.get(
      '$mealDbBaseUrl/lookup.php',
      queryParameters: {'i': id},
    );
    final meals = _mapMeals(response.data);
    return meals.isNotEmpty ? meals.first : null;
  }

  @override
  Future<MealModel?> getRandomMeal() async {
    final response = await _dio.get('$mealDbBaseUrl/random.php');
    final meals = _mapMeals(response.data);
    return meals.isNotEmpty ? meals.first : null;
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get('$mealDbBaseUrl/categories.php');
    final list = response.data?['categories'] as List<dynamic>? ?? [];
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<String>> getAreas() async {
    final response = await _dio.get(
      '$mealDbBaseUrl/list.php',
      queryParameters: {'a': 'list'},
    );
    final list = response.data?['meals'] as List<dynamic>? ?? [];
    return list
        .map((e) => (e['strArea'] as String?) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Future<List<String>> getIngredients() async {
    final response = await _dio.get(
      '$mealDbBaseUrl/list.php',
      queryParameters: {'i': 'list'},
    );
    final list = response.data?['meals'] as List<dynamic>? ?? [];
    return list
        .map((e) => (e['strIngredient'] as String?) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Future<List<RecipeSummaryModel>> filterByCategory(String category) =>
      _filter('c', category);

  @override
  Future<List<RecipeSummaryModel>> filterByArea(String area) =>
      _filter('a', area);

  @override
  Future<List<RecipeSummaryModel>> filterByIngredient(String ingredient) =>
      _filter('i', ingredient);

  Future<List<RecipeSummaryModel>> _filter(String key, String value) async {
    if (value.trim().isEmpty) return const [];
    final response = await _dio.get(
      '$mealDbBaseUrl/filter.php',
      queryParameters: {key: value},
    );
    final list = response.data?['meals'] as List<dynamic>? ?? [];
    return list
        .map((e) => RecipeSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<MealModel> _mapMeals(dynamic data) {
    final list = data?['meals'] as List<dynamic>? ?? [];
    return list
        .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
