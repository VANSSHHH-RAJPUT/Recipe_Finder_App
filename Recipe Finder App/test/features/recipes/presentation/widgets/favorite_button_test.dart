import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipe_finder_app/features/recipes/presentation/widgets/favorite_button.dart';

void main() {
  testWidgets('FavoriteButton toggles on tap', (tester) async {
    var toggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: FavoriteButton(isFavorite: false, onToggle: () => toggled = true),
      ),
    );

    await tester.tap(find.byType(FavoriteButton));

    expect(toggled, isTrue);
  });
}
