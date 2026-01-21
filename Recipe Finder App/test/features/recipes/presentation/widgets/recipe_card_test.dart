import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipe_finder_app/backend/domain/entities/recipe.dart';
import 'package:recipe_finder_app/features/recipes/presentation/widgets/recipe_card.dart';

void main() {
  Recipe buildRecipe() => const Recipe(
    id: '1',
    name: 'Margherita',
    category: 'Pizza',
    area: 'Italian',
    thumbnail: 'thumb',
    description: 'Classic pizza',
    ingredients: [IngredientItem(name: 'Tomato', measure: '2')],
    instructions: ['Bake'],
    videoUrl: null,
  );

  testWidgets('RecipeCard displays info and toggles favorite', (tester) async {
    var toggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              child: RecipeCard(
                recipe: buildRecipe(),
                isGrid: true,
                isFavorite: false,
                onTap: () {},
                onToggleFavorite: () => toggled = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Margherita'), findsOneWidget);
    expect(find.text('Pizza · Italian'), findsOneWidget);

    final favoriteGesture = tester.widget<GestureDetector>(
      find.descendant(
        of: find.byKey(const Key('favorite-1')),
        matching: find.byType(GestureDetector),
      ),
    );

    favoriteGesture.onTap?.call();
    await tester.pump();
    expect(toggled, isTrue);
  });
}
