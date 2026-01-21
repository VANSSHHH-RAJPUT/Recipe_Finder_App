import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../backend/backend_providers.dart';
import '../../../../backend/data/datasources/favorites_local_data_source.dart';
import '../../../../backend/domain/entities/recipe.dart';

final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, Map<String, Recipe>>(
      (ref) => FavoritesController(
        localDataSource: ref.watch(favoritesLocalDataSourceProvider),
      ),
    );

class FavoritesController extends StateNotifier<Map<String, Recipe>> {
  FavoritesController({required FavoritesLocalDataSource localDataSource})
    : _localDataSource = localDataSource,
      super(localDataSource.loadFavorites());

  final FavoritesLocalDataSource _localDataSource;

  bool isFavorite(String id) => state.containsKey(id);

  List<Recipe> get favoritesList => state.values.toList();

  Future<void> toggleFavorite(Recipe recipe) async {
    final updated = Map<String, Recipe>.from(state);
    final isRemoving = updated.containsKey(recipe.id);

    if (isRemoving) {
      updated.remove(recipe.id);
      state = updated;
      await _localDataSource.removeFavorite(recipe.id);
    } else {
      updated[recipe.id] = recipe;
      state = updated;
      await _localDataSource.saveFavorite(recipe);
    }
  }

  Future<void> removeFavoriteById(String id) async {
    if (!state.containsKey(id)) return;
    final updated = Map<String, Recipe>.from(state)..remove(id);
    state = updated;
    await _localDataSource.removeFavorite(id);
  }
}
