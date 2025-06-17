# 🍽️ MealMania

**Your daily dose of delicious!** Explore random recipes, search your cravings, or filter by category — all in one tastefully designed Flutter app.

## ✨ Features

### 🎲 Random Meal Recipe
- Tap a button to discover a surprise meal
- Beautiful card layout with meal image, name, category, and origin
- One-tap access to detailed recipe information

### 🔍 Search Meals by Name
- Real-time search functionality
- Search for meals by keywords (e.g., "Chicken", "Pizza", "Pasta")
- Popular search suggestions for quick access
- Elegant search results with meal previews

### 📁 Browse Meals by Category
- Browse through different meal categories (Beef, Chicken, Seafood, etc.)
- Grid layout for easy category selection
- Tap any category to see all meals in that category
- Smooth navigation between categories and meals

### 📱 Beautiful UI/UX
- Modern, foodie-themed design with orange color scheme
- Smooth animations and transitions
- Loading states with shimmer effects
- Error handling with user-friendly messages
- Responsive design for different screen sizes

### 🍳 Detailed Meal Information
- Complete recipe details including ingredients and measurements
- Step-by-step cooking instructions
- Meal tags and categories
- YouTube video links (when available)
- Source links to original recipes

## 🛠️ Technical Features

- **State Management**: Provider pattern for efficient state management
- **HTTP Requests**: RESTful API integration with TheMealDB
- **Image Caching**: Optimized image loading with cached network images
- **URL Launching**: External link support for YouTube and recipe sources
- **Error Handling**: Comprehensive error handling and user feedback
- **Loading States**: Beautiful shimmer loading effects

## 📱 Screenshots

The app features three main screens:

1. **Home Screen**: Welcome message, random meal display, and quick action buttons
2. **Search Screen**: Search bar with popular suggestions and search results
3. **Categories Screen**: Grid of meal categories with category-specific meal lists
4. **Meal Detail Screen**: Comprehensive meal information with ingredients, instructions, and links

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd mealmania
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📚 API Integration

The app integrates with [TheMealDB API](https://www.themealdb.com/api.php) and uses the following endpoints:

- **Random Meal**: `https://www.themealdb.com/api/json/v1/1/random.php`
- **Search by Name**: `https://www.themealdb.com/api/json/v1/1/search.php?s=MealName`
- **Get Categories**: `https://www.themealdb.com/api/json/v1/1/list.php?c=list`
- **Filter by Category**: `https://www.themealdb.com/api/json/v1/1/filter.php?c=CategoryName`
- **Get Meal by ID**: `https://www.themealdb.com/api/json/v1/1/lookup.php?i=MealID`

## 🎨 Design System

### Color Palette
- **Primary**: `#FF6B35` (Orange)
- **Secondary**: `#FF8E53` (Light Orange)
- **Background**: White
- **Text**: Dark gray and black
- **Accent**: Various colors for different meal categories

### Typography
- **Font Family**: Poppins (system fallback)
- **Headings**: Bold, 18-24px
- **Body Text**: Regular, 14-16px
- **Captions**: Regular, 12px

### Components
- **Cards**: Rounded corners (16px), subtle shadows
- **Buttons**: Rounded corners (12px), consistent padding
- **Icons**: Material Design icons with consistent sizing

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0
  provider: ^6.1.1
  cached_network_image: ^3.3.0
  url_launcher: ^6.2.1
  shimmer: ^3.0.0
```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── meal.dart            # Meal data model
│   └── category.dart        # Category data model
├── providers/
│   └── meal_provider.dart   # State management
├── services/
│   └── meal_api_service.dart # API service
└── screens/
    ├── home_screen.dart      # Home screen with random meal
    ├── search_screen.dart    # Search functionality
    ├── categories_screen.dart # Category browsing
    └── meal_detail_screen.dart # Detailed meal view
```

## 🎯 Key Features Implementation

### Random Meal Feature
- Automatic loading on app start
- Refresh button for new random meals
- Beautiful card layout with meal information

### Search Functionality
- Real-time search with debouncing
- Popular search suggestions
- Clear search functionality
- Loading states and error handling

### Category Browsing
- Grid layout for categories
- Nested navigation (categories → meals)
- Back navigation support
- Loading states for category meals

### Meal Details
- Comprehensive meal information
- Ingredients with measurements
- Step-by-step instructions
- External links (YouTube, source)
- Tags and categories display

## 🔧 Future Enhancements

- [ ] Favorite meals functionality
- [ ] Offline support with local storage
- [ ] Meal filtering by dietary restrictions
- [ ] Recipe sharing functionality
- [ ] Dark mode support
- [ ] Multi-language support
- [ ] Push notifications for daily meal suggestions

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

If you have any questions or need support, please open an issue in the repository.

---

**Made with ❤️ and Flutter**
