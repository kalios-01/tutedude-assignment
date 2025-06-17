import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';
import '../models/category.dart';

class MealApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Get a random meal
  Future<Meal?> getRandomMeal() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/random.php'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return Meal.fromJson(data['meals'][0]);
        }
      }
    } catch (e) {
      print('Error fetching random meal: $e');
    }
    return null;
  }

  // Search meals by name
  Future<List<Meal>> searchMealsByName(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search.php?s=${Uri.encodeComponent(query)}'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          return (data['meals'] as List)
              .map((meal) => Meal.fromJson(meal))
              .toList();
        }
      }
    } catch (e) {
      print('Error searching meals: $e');
    }
    return [];
  }

  // Get all categories
  Future<List<MealCategory>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/list.php?c=list'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          return (data['meals'] as List)
              .map((category) => MealCategory.fromJson(category))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
    return [];
  }

  // Get meals by category
  Future<List<Meal>> getMealsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=${Uri.encodeComponent(category)}'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          return (data['meals'] as List)
              .map((meal) => Meal.fromJson(meal))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching meals by category: $e');
    }
    return [];
  }

  // Get meal by ID
  Future<Meal?> getMealById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return Meal.fromJson(data['meals'][0]);
        }
      }
    } catch (e) {
      print('Error fetching meal by ID: $e');
    }
    return null;
  }
} 