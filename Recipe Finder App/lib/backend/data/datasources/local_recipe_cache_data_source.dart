import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/recipe.dart';
import '../models/recipe_cache_dto.dart';

class LocalRecipeCacheDataSource {
  LocalRecipeCacheDataSource(this._box);

  final Box<String> _box;

  Future<void> cacheRecipe(Recipe recipe) async {
    final dto = RecipeCacheDto.fromEntity(recipe);
    await _box.put(recipe.id, dto.toJsonString());
  }

  Future<void> cacheRecipes(Iterable<Recipe> recipes) async {
    final entries = {
      for (final recipe in recipes)
        recipe.id: RecipeCacheDto.fromEntity(recipe).toJsonString(),
    };
    await _box.putAll(entries);
  }

  Recipe? getRecipe(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return RecipeCacheDto.fromJsonString(data).toEntity();
  }

  List<Recipe> getAllRecipes() {
    return _box.values
        .map((value) => RecipeCacheDto.fromJsonString(value).toEntity())
        .toList();
  }

  Future<void> clear() => _box.clear();
}
