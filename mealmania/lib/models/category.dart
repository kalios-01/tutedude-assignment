class MealCategory {
  final String name;
  final String? image;
  final String? description;

  MealCategory({
    required this.name,
    this.image,
    this.description,
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      name: json['strCategory'] ?? '',
      image: json['strCategoryThumb'],
      description: json['strCategoryDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strCategory': name,
      'strCategoryThumb': image,
      'strCategoryDescription': description,
    };
  }
} 