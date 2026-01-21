import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:recipe_finder_app/backend/data/datasources/local_recipe_cache_data_source.dart';
import 'package:recipe_finder_app/backend/data/datasources/meal_db_remote_data_source.dart';
import 'package:recipe_finder_app/backend/data/models/meal_model.dart';
import 'package:recipe_finder_app/backend/data/repositories/recipe_repository_impl.dart';
import 'package:recipe_finder_app/backend/domain/entities/recipe.dart';

class FakeRecipe extends Fake implements Recipe {}

class MockRemote extends Mock implements MealDbRemoteDataSource {}

class MockCache extends Mock implements LocalRecipeCacheDataSource {}

void main() {
  late MealDbRemoteDataSource remote;
  late LocalRecipeCacheDataSource cache;
  late RecipeRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(<Recipe>[]);
    registerFallbackValue(FakeRecipe());
  });

  setUp(() {
    remote = MockRemote();
    cache = MockCache();
    repository = RecipeRepositoryImpl(remote, cache);

    when(() => cache.cacheRecipes(any())).thenAnswer((_) async {});
    when(() => cache.cacheRecipe(any())).thenAnswer((_) async {});
  });

  MealModel buildMeal({
    String id = '1',
    String name = 'Arrabiata',
    String category = 'Pasta',
    String area = 'Italian',
  }) {
    return MealModel(
      id: id,
      name: name,
      category: category,
      area: area,
      thumbnail: 'thumb',
      instructions: 'Boil.\nServe.',
      ingredients: const [IngredientDto(name: 'Tomato', measure: '2')],
      youtubeUrl: 'https://youtu.be/demo',
    );
  }

  Recipe buildRecipe({
    String id = '1',
    String name = 'Cached',
    String category = 'Pasta',
    String area = 'Italian',
  }) {
    return Recipe(
      id: id,
      name: name,
      category: category,
      area: area,
      thumbnail: 'thumb',
      description: 'Tasty',
      ingredients: const [IngredientItem(name: 'Tomato', measure: '2')],
      instructions: const ['Step'],
      videoUrl: null,
    );
  }

  group('getRecipesByName', () {
    test('returns recipes and caches them on success', () async {
      when(
        () => remote.searchMealsByName('aria'),
      ).thenAnswer((_) async => [buildMeal()]);

      final result = await repository.getRecipesByName('aria');

      expect(result, hasLength(1));
      expect(result.first.name, 'Arrabiata');

      final captured =
          verify(() => cache.cacheRecipes(captureAny())).captured.single
              as Iterable<Recipe>;
      expect(captured.single.name, 'Arrabiata');
    });

    test('falls back to cached recipes when remote fails', () async {
      when(
        () => remote.searchMealsByName('veg'),
      ).thenThrow(Exception('network'));
      when(
        () => cache.getAllRecipes(),
      ).thenReturn([buildRecipe(name: 'Veg Delight')]);

      final result = await repository.getRecipesByName('veg');

      expect(result, hasLength(1));
      expect(result.first.name, 'Veg Delight');
      verifyNever(() => cache.cacheRecipes(any()));
    });
  });

  group('getRecipeById', () {
    test('returns cached recipe when available', () async {
      when(() => cache.getRecipe('42')).thenReturn(buildRecipe(id: '42'));

      final result = await repository.getRecipeById('42');

      expect(result, isNotNull);
      expect(result!.id, '42');
      verifyNever(() => remote.getMealDetails(any()));
    });

    test('fetches from remote and caches when not in cache', () async {
      when(() => cache.getRecipe('5')).thenReturn(null);
      when(
        () => remote.getMealDetails('5'),
      ).thenAnswer((_) async => buildMeal(id: '5'));

      final result = await repository.getRecipeById('5');

      expect(result, isNotNull);
      expect(result!.id, '5');
      verify(() => cache.cacheRecipe(any())).called(1);
    });
  });
}
