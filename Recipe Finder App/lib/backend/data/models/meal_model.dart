class MealModel {
  MealModel({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.thumbnail,
    required this.instructions,
    required this.ingredients,
    this.youtubeUrl,
  });

  final String id;
  final String name;
  final String category;
  final String area;
  final String thumbnail;
  final String instructions;
  final List<IngredientDto> ingredients;
  final String? youtubeUrl;

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final ingredients = <IngredientDto>[];
    for (var index = 1; index <= 20; index++) {
      final ingredientRaw = json['strIngredient$index'] as String?;
      final measureRaw = json['strMeasure$index'] as String?;
      final ingredient = ingredientRaw?.trim() ?? '';
      final measure = measureRaw?.trim() ?? '';
      if (ingredient.isEmpty) continue;
      ingredients.add(IngredientDto(name: ingredient, measure: measure));
    }

    return MealModel(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '',
      category: json['strCategory']?.toString() ?? '',
      area: json['strArea']?.toString() ?? '',
      thumbnail: json['strMealThumb']?.toString() ?? '',
      instructions: json['strInstructions']?.toString() ?? '',
      ingredients: ingredients,
      youtubeUrl: json['strYoutube']?.toString(),
    );
  }
}

class IngredientDto {
  const IngredientDto({required this.name, required this.measure});

  final String name;
  final String measure;
}
