import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:recipe_finder_app/backend/data/datasources/local_recipe_cache_data_source.dart';
import 'package:recipe_finder_app/backend/domain/entities/recipe.dart';

void main() {
  const recipe = Recipe(
    id: '1',
    name: 'Test Meal',
    category: 'Pasta',
    area: 'Italian',
    thumbnail: 'thumb',
    description: 'Tasty meal',
    ingredients: [IngredientItem(name: 'Tomato', measure: '2')],
    instructions: ['Boil water', 'Serve hot'],
    videoUrl: null,
  );

  late Directory tempDir;
  late Box<String> box;
  late LocalRecipeCacheDataSource dataSource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('recipes_cache_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<String>('recipes_cache_test_box');
    dataSource = LocalRecipeCacheDataSource(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('recipes_cache_test_box');
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('cacheRecipe stores and retrieves recipe', () async {
    await dataSource.cacheRecipe(recipe);

    final cached = dataSource.getRecipe(recipe.id);
    expect(cached, isNotNull);
    expect(cached!.name, equals('Test Meal'));
    expect(cached.ingredients.single.name, equals('Tomato'));
  });

  test(
    'cacheRecipes stores multiple recipes and getAll returns them',
    () async {
      const secondRecipe = Recipe(
        id: '2',
        name: 'Second',
        category: 'Pasta',
        area: 'Italian',
        thumbnail: 'thumb2',
        description: 'Another meal',
        ingredients: [IngredientItem(name: 'Basil', measure: '1 tbsp')],
        instructions: ['Mix', 'Serve'],
        videoUrl: null,
      );

      await dataSource.cacheRecipes([recipe, secondRecipe]);

      final all = dataSource.getAllRecipes();
      expect(all, hasLength(2));
      expect(all.map((r) => r.id), containsAll(['1', '2']));
    },
  );
}
