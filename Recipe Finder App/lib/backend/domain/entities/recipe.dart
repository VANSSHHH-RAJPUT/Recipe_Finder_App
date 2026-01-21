class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.thumbnail,
    required this.description,
    required this.ingredients,
    required this.instructions,
    this.videoUrl,
  });

  final String id;
  final String name;
  final String category;
  final String area;
  final String thumbnail;
  final String description;
  final List<IngredientItem> ingredients;
  final List<String> instructions;
  final String? videoUrl;
}

class IngredientItem {
  const IngredientItem({required this.measure, required this.name});

  final String measure;
  final String name;
}
