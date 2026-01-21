import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipe_finder_app/features/recipes/presentation/widgets/recipe_search_bar.dart';

void main() {
  testWidgets('RecipeSearchBar invokes onChanged', (tester) async {
    final controller = TextEditingController();
    var latestQuery = '';

    await tester.pumpWidget(
      MaterialApp(
        home: RecipeSearchBar(
          controller: controller,
          onChanged: (value) => latestQuery = value,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'pasta');

    expect(latestQuery, 'pasta');
  });
}
