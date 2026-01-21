import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/recipe.dart';
import '../models/recipe_cache_dto.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._box);

  final Box<String> _box;

  Map<String, Recipe> loadFavorites() {
    final entries = <String, Recipe>{};
    for (final dynamic key in _box.keys) {
      final stringKey = key as String?;
      if (stringKey == null) continue;
      final value = _box.get(stringKey);
      if (value == null) continue;
      final recipe = RecipeCacheDto.fromJsonString(value).toEntity();
      entries[stringKey] = recipe;
    }
    return entries;
  }

  Future<void> saveFavorite(Recipe recipe) async {
    final dto = RecipeCacheDto.fromEntity(recipe);
    await _box.put(recipe.id, dto.toJsonString());
  }

  Future<void> removeFavorite(String id) => _box.delete(id);
}
