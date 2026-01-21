import 'package:flutter_test/flutter_test.dart';

import 'package:recipe_finder_app/backend/data/models/meal_model.dart';

void main() {
  test('MealModel.fromJson parses fields and ingredients correctly', () {
    final json = {
      'idMeal': '123',
      'strMeal': 'Spaghetti',
      'strCategory': 'Pasta',
      'strArea': 'Italian',
      'strMealThumb': 'thumb.jpg',
      'strInstructions': 'Boil water. Cook pasta.',
      'strYoutube': 'https://youtu.be/demo',
      'strIngredient1': ' Tomato ',
      'strMeasure1': ' 2 ',
      'strIngredient2': '',
      'strMeasure2': '',
    };

    final model = MealModel.fromJson(json);

    expect(model.id, '123');
    expect(model.name, 'Spaghetti');
    expect(model.category, 'Pasta');
    expect(model.area, 'Italian');
    expect(model.thumbnail, 'thumb.jpg');
    expect(model.instructions, 'Boil water. Cook pasta.');
    expect(model.youtubeUrl, 'https://youtu.be/demo');
    expect(model.ingredients, hasLength(1));
    expect(model.ingredients.first.name, 'Tomato');
    expect(model.ingredients.first.measure, '2');
  });
}
