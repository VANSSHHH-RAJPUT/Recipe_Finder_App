import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'core/api_config.dart';
import 'core/storage_keys.dart';
import 'data/datasources/favorites_local_data_source.dart';
import 'data/datasources/local_recipe_cache_data_source.dart';
import 'data/datasources/meal_db_remote_data_source.dart';
import 'data/datasources/settings_local_data_source.dart';
import 'data/repositories/recipe_repository_impl.dart';
import 'domain/repositories/recipe_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: mealDbBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: false,
      responseHeader: false,
      responseBody: true,
      requestBody: true,
      compact: true,
    ),
  );
  return dio;
});

final mealDbRemoteDataSourceProvider = Provider<MealDbRemoteDataSource>(
  (ref) => MealDbRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final recipesCacheBoxProvider = Provider<Box<String>>(
  (ref) => Hive.box<String>(StorageKeys.recipesCacheBox),
);

final favoritesBoxProvider = Provider<Box<String>>(
  (ref) => Hive.box<String>(StorageKeys.favoritesBox),
);

final settingsBoxProvider = Provider<Box<String>>(
  (ref) => Hive.box<String>(StorageKeys.settingsBox),
);

final localRecipeCacheDataSourceProvider = Provider<LocalRecipeCacheDataSource>(
  (ref) => LocalRecipeCacheDataSource(ref.watch(recipesCacheBoxProvider)),
);

final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>(
  (ref) => FavoritesLocalDataSource(ref.watch(favoritesBoxProvider)),
);

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>(
  (ref) => SettingsLocalDataSource(ref.watch(settingsBoxProvider)),
);

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => RecipeRepositoryImpl(
    ref.watch(mealDbRemoteDataSourceProvider),
    ref.watch(localRecipeCacheDataSourceProvider),
  ),
);
