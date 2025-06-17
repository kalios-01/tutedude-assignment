class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String image;
  final String? youtubeLink;
  final String? source;
  final List<String> ingredients;
  final List<String> measurements;
  final List<String> tags;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.image,
    this.youtubeLink,
    this.source,
    required this.ingredients,
    required this.measurements,
    required this.tags,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measurements = [];
    List<String> tags = [];

    // Extract ingredients and measurements
    for (int i = 1; i <= 20; i++) {
      String? ingredient = json['strIngredient$i'];
      String? measurement = json['strMeasure$i'];
      
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredients.add(ingredient.trim());
        measurements.add(measurement?.trim() ?? '');
      }
    }

    // Extract tags
    String? tagsStr = json['strTags'];
    if (tagsStr != null && tagsStr.isNotEmpty) {
      tags = tagsStr.split(',').map((tag) => tag.trim()).toList();
    }

    return Meal(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      image: json['strMealThumb'] ?? '',
      youtubeLink: json['strYoutube'],
      source: json['strSource'],
      ingredients: ingredients,
      measurements: measurements,
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': image,
      'strYoutube': youtubeLink,
      'strSource': source,
      'ingredients': ingredients,
      'measurements': measurements,
      'tags': tags,
    };
  }
} 