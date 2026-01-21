class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnail,
  });

  final String id;
  final String name;
  final String description;
  final String thumbnail;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['idCategory']?.toString() ?? '',
      name: json['strCategory']?.toString() ?? '',
      description: json['strCategoryDescription']?.toString() ?? '',
      thumbnail: json['strCategoryThumb']?.toString() ?? '',
    );
  }
}
