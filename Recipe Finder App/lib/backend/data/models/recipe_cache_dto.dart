import 'dart:convert';

import '../../domain/entities/recipe.dart';

class RecipeCacheDto {
  const RecipeCacheDto({
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
  final List<IngredientCacheDto> ingredients;
  final List<String> instructions;
  final String? videoUrl;

  factory RecipeCacheDto.fromEntity(Recipe recipe) => RecipeCacheDto(
    id: recipe.id,
    name: recipe.name,
    category: recipe.category,
    area: recipe.area,
    thumbnail: recipe.thumbnail,
    description: recipe.description,
    ingredients: recipe.ingredients
        .map(
          (item) => IngredientCacheDto(name: item.name, measure: item.measure),
        )
        .toList(),
    instructions: recipe.instructions,
    videoUrl: recipe.videoUrl,
  );

  Recipe toEntity() => Recipe(
    id: id,
    name: name,
    category: category,
    area: area,
    thumbnail: thumbnail,
    description: description,
    ingredients: ingredients
        .map((item) => IngredientItem(name: item.name, measure: item.measure))
        .toList(),
    instructions: instructions,
    videoUrl: videoUrl,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'area': area,
    'thumbnail': thumbnail,
    'description': description,
    'ingredients': ingredients.map((item) => item.toJson()).toList(),
    'instructions': instructions,
    'videoUrl': videoUrl,
  };

  static RecipeCacheDto fromJson(Map<String, dynamic> json) => RecipeCacheDto(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    category: json['category'] as String? ?? '',
    area: json['area'] as String? ?? '',
    thumbnail: json['thumbnail'] as String? ?? '',
    description: json['description'] as String? ?? '',
    ingredients: (json['ingredients'] as List<dynamic>? ?? [])
        .map(
          (item) => IngredientCacheDto.fromJson(item as Map<String, dynamic>),
        )
        .toList(),
    instructions: (json['instructions'] as List<dynamic>? ?? [])
        .map((item) => item.toString())
        .toList(),
    videoUrl: json['videoUrl'] as String?,
  );

  String toJsonString() => jsonEncode(toJson());

  factory RecipeCacheDto.fromJsonString(String source) =>
      RecipeCacheDto.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

class IngredientCacheDto {
  const IngredientCacheDto({required this.name, required this.measure});

  final String name;
  final String measure;

  Map<String, dynamic> toJson() => {'name': name, 'measure': measure};

  factory IngredientCacheDto.fromJson(Map<String, dynamic> json) =>
      IngredientCacheDto(
        name: json['name'] as String? ?? '',
        measure: json['measure'] as String? ?? '',
      );
}
