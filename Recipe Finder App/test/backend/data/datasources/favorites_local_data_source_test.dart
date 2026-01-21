import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:recipe_finder_app/backend/data/datasources/favorites_local_data_source.dart';
import 'package:recipe_finder_app/backend/domain/entities/recipe.dart';

void main() {
  const recipe = Recipe(
    id: 'fav1',
    name: 'Favorite Meal',
    category: 'Dessert',
    area: 'French',
    thumbnail: 'thumb',
    description: 'Sweet treat',
    ingredients: [IngredientItem(name: 'Sugar', measure: '1 cup')],
    instructions: ['Mix', 'Serve'],
    videoUrl: null,
  );

  late Directory tempDir;
  late Box<String> box;
  late FavoritesLocalDataSource dataSource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('favorites_cache_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<String>('favorites_box_test');
    dataSource = FavoritesLocalDataSource(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('favorites_box_test');
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('saveFavorite stores recipe and loadFavorites returns it', () async {
    await dataSource.saveFavorite(recipe);

    final favorites = dataSource.loadFavorites();

    expect(favorites.length, 1);
    expect(favorites['fav1']?.name, 'Favorite Meal');
  });

  test('removeFavorite deletes entry', () async {
    await dataSource.saveFavorite(recipe);
    await dataSource.removeFavorite('fav1');

    final favorites = dataSource.loadFavorites();
    expect(favorites, isEmpty);
  });
}
