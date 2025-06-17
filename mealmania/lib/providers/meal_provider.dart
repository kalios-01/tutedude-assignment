import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../models/category.dart';
import '../services/meal_api_service.dart';

class MealProvider with ChangeNotifier {
  final MealApiService _apiService = MealApiService();
  
  MealApiService get apiService => _apiService;

  Meal? _randomMeal;
  List<Meal> _searchResults = [];
  List<MealCategory> _categories = [];
  List<Meal> _categoryMeals = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Meal? get randomMeal => _randomMeal;
  List<Meal> get searchResults => _searchResults;
  List<MealCategory> get categories => _categories;
  List<Meal> get categoryMeals => _categoryMeals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get random meal
  Future<void> getRandomMeal() async {
    _setLoading(true);
    _clearError();
    
    try {
      _randomMeal = await _apiService.getRandomMeal();
      if (_randomMeal == null) {
        _setError('Failed to load random meal');
      }
    } catch (e) {
      _setError('Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search meals by name
  Future<void> searchMeals(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();
    
    try {
      _searchResults = await _apiService.searchMealsByName(query);
    } catch (e) {
      _setError('Error searching meals: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get categories
  Future<void> getCategories() async {
    _setLoading(true);
    _clearError();
    
    try {
      _categories = await _apiService.getCategories();
    } catch (e) {
      _setError('Error loading categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get meals by category
  Future<void> getMealsByCategory(String category) async {
    _setLoading(true);
    _clearError();
    
    try {
      _categoryMeals = await _apiService.getMealsByCategory(category);
    } catch (e) {
      _setError('Error loading category meals: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  void clearCategoryMeals() {
    _categoryMeals = [];
    notifyListeners();
  }
} 