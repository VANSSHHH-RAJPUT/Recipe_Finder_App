import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:recipe_finder_app/backend/data/datasources/meal_db_remote_data_source.dart';
import 'package:recipe_finder_app/backend/data/datasources/settings_local_data_source.dart';
import 'package:recipe_finder_app/backend/domain/repositories/recipe_repository.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockSettingsLocalDataSource extends Mock
    implements SettingsLocalDataSource {}

class MockMealDbRemoteDataSource extends Mock
    implements MealDbRemoteDataSource {}

class MockDio extends Mock implements Dio {}
