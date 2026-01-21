class RecipeSummaryModel {
  const RecipeSummaryModel({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  final String id;
  final String name;
  final String thumbnail;

  factory RecipeSummaryModel.fromJson(Map<String, dynamic> json) {
    return RecipeSummaryModel(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '',
      thumbnail: json['strMealThumb']?.toString() ?? '',
    );
  }
}
