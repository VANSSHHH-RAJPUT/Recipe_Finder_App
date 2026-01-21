import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:recipe_finder_app/backend/data/datasources/settings_local_data_source.dart';
import 'package:recipe_finder_app/backend/domain/entities/recipe.dart';
import 'package:recipe_finder_app/backend/domain/repositories/recipe_repository.dart';
import 'package:recipe_finder_app/features/recipes/presentation/controllers/recipe_list_controller.dart';
import 'package:recipe_finder_app/features/recipes/presentation/state/recipe_list_state.dart';

class _MockRepository extends Mock implements RecipeRepository {}

class _MockSettings extends Mock implements SettingsLocalDataSource {}

void main() {
  late _MockRepository repository;
  late _MockSettings settings;
  late RecipeListController controller;

  Recipe buildRecipe({String id = '1', String name = 'Arrabiata'}) => Recipe(
    id: id,
    name: name,
    category: 'Pasta',
    area: 'Italian',
    thumbnail: 'thumb',
    description: 'Tasty',
    ingredients: const [IngredientItem(name: 'Tomato', measure: '2')],
    instructions: const ['Cook'],
    videoUrl: null,
  );

  setUp(() {
    repository = _MockRepository();
    settings = _MockSettings();

    when(() => settings.getViewModePreference()).thenReturn(null);
    when(() => repository.lastFetchUsedCache).thenReturn(false);

    controller = RecipeListController(
      repository: repository,
      settingsLocalDataSource: settings,
      loadInitialData: false,
    );
  });

  tearDown(() => controller.dispose());

  test(
    'applyFilterSelection fetches by categories and updates state',
    () async {
      when(
        () => repository.getRecipesByCategory(any()),
      ).thenAnswer((_) async => [buildRecipe()]);

      controller.applyFilterSelection(categories: ['Pasta']);

      await Future.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.filteredRecipes, hasLength(1));
      expect(controller.state.selectedCategories, ['Pasta']);
      verify(() => repository.getRecipesByCategory('Pasta')).called(1);
    },
  );

  test('clearFilters resets selections and fetches default recipes', () async {
    controller.state = controller.state.copyWith(selectedCategories: ['Pasta']);

    when(
      () => repository.getRecipesByFirstLetter(any()),
    ).thenAnswer((_) async => [buildRecipe(name: 'Default')]);

    controller.clearFilters();

    await Future.delayed(Duration.zero);

    expect(controller.state.selectedCategories, isEmpty);
    expect(controller.state.filteredRecipes.first.name, 'Default');
    verify(() => repository.getRecipesByFirstLetter('a')).called(1);
  });

  test('setViewMode persists preference when changed', () {
    when(() => settings.saveViewModePreference(any())).thenAnswer((_) async {});

    controller.setViewMode(RecipeViewMode.list);

    expect(controller.state.viewMode, RecipeViewMode.list);
    verify(() => settings.saveViewModePreference('list')).called(1);
  });
}
