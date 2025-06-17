import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/meal_provider.dart';
import '../models/category.dart';
import '../models/meal.dart';
import 'meal_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? _selectedCategory;
  bool _showMeals = false;

  @override
  void initState() {
    super.initState();
    // Load categories when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _selectedCategory != null ? _selectedCategory! : 'Categories',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF6B35),
                      Color(0xFFFF8E53),
                    ],
                  ),
                ),
              ),
            ),
            leading: _selectedCategory != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                        _showMeals = false;
                      });
                      context.read<MealProvider>().clearCategoryMeals();
                    },
                  )
                : null,
          ),
          
          // Content
          Consumer<MealProvider>(
            builder: (context, provider, child) {
              if (_selectedCategory != null) {
                return _buildMealsList(provider);
              }
              return _buildCategoriesGrid(provider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(MealProvider provider) {
    if (provider.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.all(16.0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildLoadingCategoryCard(),
            childCount: 6,
          ),
        ),
      );
    }

    if (provider.error != null) {
      return SliverToBoxAdapter(
        child: _buildErrorCard(provider.error!, () {
          provider.getCategories();
        }),
      );
    }

    if (provider.categories.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyCard(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = provider.categories[index];
            return _buildCategoryCard(category);
          },
          childCount: provider.categories.length,
        ),
      ),
    );
  }

  Widget _buildMealsList(MealProvider provider) {
    if (!_showMeals) {
      // Load meals for the selected category
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.getMealsByCategory(_selectedCategory!);
        setState(() {
          _showMeals = true;
        });
      });
      
      return SliverPadding(
        padding: const EdgeInsets.all(16.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildLoadingMealCard(),
            childCount: 3,
          ),
        ),
      );
    }

    if (provider.isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.all(16.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildLoadingMealCard(),
            childCount: 3,
          ),
        ),
      );
    }

    if (provider.error != null) {
      return SliverToBoxAdapter(
        child: _buildErrorCard(provider.error!, () {
          provider.getMealsByCategory(_selectedCategory!);
        }),
      );
    }

    if (provider.categoryMeals.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildNoMealsCard(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final meal = provider.categoryMeals[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildMealCard(meal),
            );
          },
          childCount: provider.categoryMeals.length,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'beef':
        return Icons.restaurant;
      case 'chicken':
        return Icons.pets;
      case 'lamb':
        return Icons.agriculture;
      case 'pasta':
        return Icons.ramen_dining;
      case 'pork':
        return Icons.agriculture;
      case 'seafood':
        return Icons.set_meal;
      case 'vegetarian':
        return Icons.eco;
      case 'vegan':
        return Icons.spa;
      case 'dessert':
        return Icons.cake;
      case 'miscellaneous':
        return Icons.more_horiz;
      case 'goat':
        return Icons.agriculture;
      case 'breakfast':
        return Icons.wb_sunny;
      case 'starter':
        return Icons.apps;
      case 'side':
        return Icons.dinner_dining;
      case 'soup':
        return Icons.soup_kitchen;
      case 'salad':
        return Icons.eco;
      case 'snack':
        return Icons.fastfood;
      case 'drink':
        return Icons.local_cafe;
      case 'cocktail':
        return Icons.local_bar;
      case 'shake':
        return Icons.local_cafe;
      case 'cocoa':
        return Icons.coffee;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.restaurant;
    }
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'beef':
        return Colors.brown;
      case 'chicken':
        return Colors.orange;
      case 'lamb':
        return Colors.deepOrange;
      case 'pasta':
        return Colors.amber;
      case 'pork':
        return Colors.pink;
      case 'seafood':
        return Colors.blue;
      case 'vegetarian':
        return Colors.green;
      case 'vegan':
        return Colors.lightGreen;
      case 'dessert':
        return Colors.purple;
      case 'miscellaneous':
        return Colors.grey;
      case 'goat':
        return Colors.brown;
      case 'breakfast':
        return Colors.yellow;
      case 'starter':
        return Colors.cyan;
      case 'side':
        return Colors.teal;
      case 'soup':
        return Colors.orange;
      case 'salad':
        return Colors.lightGreen;
      case 'snack':
        return Colors.amber;
      case 'drink':
        return Colors.blue;
      case 'cocktail':
        return Colors.purple;
      case 'shake':
        return Colors.pink;
      case 'cocoa':
        return Colors.brown;
      case 'other':
        return Colors.grey;
      default:
        return const Color(0xFFFF6B35);
    }
  }

  Widget _buildCategoryCard(MealCategory category) {
    final icon = _getCategoryIcon(category.name);
    final color = _getCategoryColor(category.name);
    
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category.name;
            _showMeals = false;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Category Icon and Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: category.image != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: category.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => Center(
                                child: Icon(
                                  icon,
                                  size: 48,
                                  color: color,
                                ),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Icon(
                                  icon,
                                  size: 48,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                          // Icon overlay
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Icon(
                          icon,
                          size: 48,
                          color: color,
                        ),
                      ),
              ),
            ),
            
            // Category Name
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Card(
      child: InkWell(
        onTap: () {
          _navigateToMealDetail(meal.id);
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: meal.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            meal.category,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFFF6B35),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          meal.area,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (meal.tags.isNotEmpty)
                      Text(
                        meal.tags.take(2).join(', '),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
            
            // Arrow
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCategoryCard() {
    return Card(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 120,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMealCard() {
    return Card(
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 16,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 12,
                      width: 100,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              const Text(
                'Failed to load',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.category,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              const Text(
                'No categories found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unable to load meal categories',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoMealsCard() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.restaurant,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              const Text(
                'No meals found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No meals available in this category',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToMealDetail(String mealId) async {
    final provider = context.read<MealProvider>();
    Meal? fullMeal = await provider.apiService.getMealById(mealId);
    if (fullMeal != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MealDetailScreen(meal: fullMeal),
        ),
      );
    } else {
      // Handle error: show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load meal details. Please try again.'),
        ),
      );
    }
  }
} 