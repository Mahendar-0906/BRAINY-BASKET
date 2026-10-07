import 'package:flutter/material.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _refreshShopping();
    _initializeDemoNutrition();
  }

  // ── Preferences ──────────────────────────────────────────────────────────
  final prefs = UserPreferences();

  // ── Inventory ─────────────────────────────────────────────────────────────
  final List<GroceryItem> inventory = [
    GroceryItem(id: '1', name: 'Rice', category: 'Grains', quantity: 4, unit: 'kg', minimumQuantity: 1.5, location: 'Pantry', purchaseDate: DateTime.now().subtract(const Duration(days: 5)), expiryDate: DateTime.now().add(const Duration(days: 180))),
    GroceryItem(id: '2', name: 'Milk', category: 'Dairy', quantity: 0.5, unit: 'L', minimumQuantity: 1, location: 'Refrigerator', purchaseDate: DateTime.now().subtract(const Duration(days: 1)), expiryDate: DateTime.now().add(const Duration(days: 4))),
    GroceryItem(id: '3', name: 'Eggs', category: 'Eggs', quantity: 6, unit: 'pcs', minimumQuantity: 4, location: 'Refrigerator', purchaseDate: DateTime.now().subtract(const Duration(days: 2)), expiryDate: DateTime.now().add(const Duration(days: 14))),
    GroceryItem(id: '4', name: 'Tomato', category: 'Vegetables', quantity: 0, unit: 'pcs', minimumQuantity: 4, location: 'Refrigerator', purchaseDate: DateTime.now().subtract(const Duration(days: 1)), expiryDate: DateTime.now().add(const Duration(days: 5))),
    GroceryItem(id: '5', name: 'Onion', category: 'Vegetables', quantity: 0, unit: 'kg', minimumQuantity: 0.5, location: 'Pantry', purchaseDate: DateTime.now().subtract(const Duration(days: 3)), expiryDate: DateTime.now().add(const Duration(days: 20))),
    GroceryItem(id: '6', name: 'Potato', category: 'Vegetables', quantity: 2, unit: 'kg', minimumQuantity: 1, location: 'Pantry', purchaseDate: DateTime.now().subtract(const Duration(days: 4)), expiryDate: DateTime.now().add(const Duration(days: 30))),
    GroceryItem(id: '7', name: 'Bread', category: 'Snacks', quantity: 0, unit: 'loaf', minimumQuantity: 1, location: 'Counter', purchaseDate: DateTime.now().subtract(const Duration(days: 3)), expiryDate: DateTime.now().subtract(const Duration(days: 1))),
    GroceryItem(id: '8', name: 'Cooking Oil', category: 'Other', quantity: 1, unit: 'L', minimumQuantity: 0.5, location: 'Pantry', purchaseDate: DateTime.now().subtract(const Duration(days: 10)), expiryDate: DateTime.now().add(const Duration(days: 365))),
    GroceryItem(id: '9', name: 'Wheat Flour', category: 'Grains', quantity: 2, unit: 'kg', minimumQuantity: 1, location: 'Pantry', purchaseDate: DateTime.now().subtract(const Duration(days: 7)), expiryDate: DateTime.now().add(const Duration(days: 90))),
    GroceryItem(id: '10', name: 'Garlic', category: 'Vegetables', quantity: 0.2, unit: 'kg', minimumQuantity: 0.1, location: 'Pantry', purchaseDate: DateTime.now().subtract(const Duration(days: 5)), expiryDate: DateTime.now().add(const Duration(days: 25))),
    GroceryItem(id: '11', name: 'Ginger', category: 'Spices', quantity: 0.1, unit: 'kg', minimumQuantity: 0.05, location: 'Refrigerator', purchaseDate: DateTime.now().subtract(const Duration(days: 3)), expiryDate: DateTime.now().add(const Duration(days: 15))),
    GroceryItem(id: '12', name: 'Salt', category: 'Spices', quantity: 0.5, unit: 'kg', minimumQuantity: 0.2, location: 'Pantry', purchaseDate: DateTime.now().subtract(const Duration(days: 30)), expiryDate: DateTime.now().add(const Duration(days: 365))),
  ];

  // ── Recipes ───────────────────────────────────────────────────────────────
  final List<Recipe> recipes = const [
    Recipe(
      id: 'r1', name: 'Vegetable Fried Rice', cookingTime: 25, difficulty: 'Easy', category: 'Quick Meals',
      ingredients: [RecipeIngredient('Rice', 1, 'cup'), RecipeIngredient('Onion', 1, 'pcs'), RecipeIngredient('Tomato', 1, 'pcs'), RecipeIngredient('Eggs', 2, 'pcs'), RecipeIngredient('Cooking Oil', 2, 'tbsp')],
      instructions: ['Cook rice and let it cool.', 'Heat oil in a wok over high heat.', 'Sauté onion and tomato for 2 minutes.', 'Push to side, scramble eggs.', 'Add rice, toss everything together.', 'Season with salt and serve hot.'],
      nutrition: {'Calories': '320 kcal', 'Protein': '9g', 'Carbs': '52g', 'Fat': '8g'},
    ),
    Recipe(
      id: 'r2', name: 'Egg Curry', cookingTime: 35, difficulty: 'Medium', category: 'Comfort Food',
      ingredients: [RecipeIngredient('Eggs', 4, 'pcs'), RecipeIngredient('Tomato', 3, 'pcs'), RecipeIngredient('Onion', 2, 'pcs'), RecipeIngredient('Garlic', 4, 'pcs'), RecipeIngredient('Ginger', 1, 'tbsp'), RecipeIngredient('Cooking Oil', 2, 'tbsp')],
      instructions: ['Hard boil eggs and peel them.', 'Fry onions until golden.', 'Add garlic, ginger, tomatoes.', 'Cook until oil separates.', 'Add eggs, simmer 10 minutes.', 'Garnish and serve with rice.'],
      nutrition: {'Calories': '280 kcal', 'Protein': '14g', 'Carbs': '12g', 'Fat': '18g'},
    ),
    Recipe(
      id: 'r3', name: 'Tomato Soup', cookingTime: 20, difficulty: 'Easy', category: 'Light Meals',
      ingredients: [RecipeIngredient('Tomato', 4, 'pcs'), RecipeIngredient('Onion', 1, 'pcs'), RecipeIngredient('Garlic', 2, 'pcs'), RecipeIngredient('Cooking Oil', 1, 'tbsp')],
      instructions: ['Sauté onion and garlic in oil.', 'Add chopped tomatoes.', 'Cook until soft, then blend.', 'Season with salt and serve hot.'],
      nutrition: {'Calories': '120 kcal', 'Protein': '3g', 'Carbs': '18g', 'Fat': '4g'},
    ),
    Recipe(
      id: 'r4', name: 'Omelette', cookingTime: 10, difficulty: 'Easy', category: 'Breakfast',
      ingredients: [RecipeIngredient('Eggs', 3, 'pcs'), RecipeIngredient('Onion', 0.5, 'pcs'), RecipeIngredient('Tomato', 1, 'pcs'), RecipeIngredient('Cooking Oil', 1, 'tbsp')],
      instructions: ['Beat eggs with salt.', 'Chop onion and tomato finely.', 'Heat oil in pan.', 'Pour eggs, add vegetables.', 'Fold and serve immediately.'],
      nutrition: {'Calories': '210 kcal', 'Protein': '15g', 'Carbs': '5g', 'Fat': '14g'},
    ),
    Recipe(
      id: 'r5', name: 'Dal Rice', cookingTime: 40, difficulty: 'Easy', category: 'Everyday',
      ingredients: [RecipeIngredient('Rice', 1, 'cup'), RecipeIngredient('Onion', 1, 'pcs'), RecipeIngredient('Tomato', 2, 'pcs'), RecipeIngredient('Garlic', 3, 'pcs'), RecipeIngredient('Cooking Oil', 2, 'tbsp')],
      instructions: ['Cook rice separately.', 'Sauté onion, garlic in oil.', 'Add tomatoes, cook until soft.', 'Add lentils and water.', 'Simmer 20 minutes.', 'Serve dal over rice.'],
      nutrition: {'Calories': '380 kcal', 'Protein': '12g', 'Carbs': '68g', 'Fat': '6g'},
    ),
    Recipe(
      id: 'r6', name: 'Vegetable Sandwich', cookingTime: 15, difficulty: 'Easy', category: 'Quick Meals',
      ingredients: [RecipeIngredient('Bread', 2, 'slices'), RecipeIngredient('Tomato', 1, 'pcs'), RecipeIngredient('Onion', 0.5, 'pcs'), RecipeIngredient('Potato', 1, 'pcs')],
      instructions: ['Boil and mash potato.', 'Slice tomato and onion.', 'Spread mash on bread.', 'Layer vegetables.', 'Toast and serve.'],
      nutrition: {'Calories': '240 kcal', 'Protein': '7g', 'Carbs': '44g', 'Fat': '4g'},
    ),
    Recipe(
      id: 'r7', name: 'Tomato Pasta', cookingTime: 20, difficulty: 'Easy', category: 'Quick Meals',
      ingredients: [RecipeIngredient('Tomato', 3, 'pcs'), RecipeIngredient('Garlic', 2, 'pcs'), RecipeIngredient('Cooking Oil', 1, 'tbsp')],
      instructions: ['Boil pasta until al dente.', 'Sauté garlic in oil, add pureed tomatoes.', 'Simmer sauce for 10 minutes.', 'Toss pasta in sauce and serve.'],
      nutrition: {'Calories': '310 kcal', 'Protein': '8g', 'Carbs': '58g', 'Fat': '5g'},
    ),
    Recipe(
      id: 'r8', name: 'Vegetable Biryani', cookingTime: 55, difficulty: 'Hard', category: 'Special',
      ingredients: [RecipeIngredient('Rice', 2, 'cup'), RecipeIngredient('Onion', 2, 'pcs'), RecipeIngredient('Tomato', 2, 'pcs'), RecipeIngredient('Potato', 1, 'pcs'), RecipeIngredient('Garlic', 4, 'pcs'), RecipeIngredient('Ginger', 1, 'tbsp'), RecipeIngredient('Cooking Oil', 3, 'tbsp')],
      instructions: ['Soak rice 30 minutes.', 'Fry onions until crispy.', 'Add garlic, ginger, tomatoes.', 'Add vegetables and spices.', 'Layer rice and vegetable mix.', 'Dum cook 20 minutes.', 'Serve with raita.'],
      nutrition: {'Calories': '420 kcal', 'Protein': '8g', 'Carbs': '72g', 'Fat': '10g'},
    ),
  ];

  // ── Shopping ──────────────────────────────────────────────────────────────
  final List<ShoppingItem> shopping = [];

  // ── Activity ──────────────────────────────────────────────────────────────
  final List<ActivityEntry> activity = [
    ActivityEntry('Vegetable Fried Rice recommended by AI.', Icons.auto_awesome, Color(0xff3677b8)),
    ActivityEntry('IoT inventory update received.', Icons.sensors, Color(0xff176b5c)),
    ActivityEntry('Milk added to shopping list automatically.', Icons.add_shopping_cart, Color(0xffc77b16)),
  ];

  // ── Notifications ─────────────────────────────────────────────────────────
  final List<AppNotification> notifications = [
    AppNotification('Low Stock Alert', 'Milk is below minimum quantity.', Icons.warning_amber_rounded, Color(0xffc77b16)),
    AppNotification('Out of Stock', 'Bread is out of stock.', Icons.error_outline, Color(0xffc44d4d)),
    AppNotification('Recipe Ready', 'You can make Tomato Soup right now!', Icons.restaurant, Color(0xff176b5c)),
  ];

  // ── IoT Devices ───────────────────────────────────────────────────────────
  final List<IoTDevice> iotDevices = [
    IoTDevice(id: 'd1', name: 'Kitchen Monitor 01'),
    IoTDevice(id: 'd2', name: 'Pantry Sensor 02'),
  ];

  // ── Nutrition Tracking ─────────────────────────────────────────────────────
  final List<HouseholdMember> householdMembers = [
    HouseholdMember(
      personId: 'person001',
      name: 'Aanya',
      age: 25,
      gender: 'Female',
      height: 165,
      weight: 62.0,
      activityLevel: 'moderate',
      nutritionGoal: 'maintainWeight',
    ),
    HouseholdMember(
      personId: 'person002',
      name: 'Rohan',
      age: 28,
      gender: 'Male',
      height: 180,
      weight: 75.0,
      activityLevel: 'active',
      nutritionGoal: 'gainWeight',
    ),
  ];

  final List<MealLog> mealLogs = [];
  final List<NutritionRecord> nutritionRecords = [];

  HouseholdMember? currentPerson;

  // Demo nutrition data - sample meals for today
  void _initializeDemoNutrition() {
    if (householdMembers.isEmpty) return;
    if (mealLogs.isNotEmpty) return; // Already initialized

    currentPerson = householdMembers.first;
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Aanya's breakfast: Ragi Dosa
    mealLogs.add(MealLog(
      mealId: 'meal_001',
      personId: 'person001',
      mealType: 'Breakfast',
      date: DateTime.parse(today),
      items: [
        MealItem(foodId: 'MILLET_RAGI', name: 'Ragi Flour', quantity: 50, unit: 'g', nutrition: NutrientInfo(calories: 164, protein: 3.35, carbohydrates: 36.3, fat: 0.65, fiber: 1.8, iron: 14.15, calcium: 172)),
        MealItem(foodId: 'DAIRY_MILK', name: 'Milk', quantity: 150, unit: 'ml', nutrition: NutrientInfo(calories: 91.5, protein: 4.8, carbohydrates: 7.2, fat: 4.95, fiber: 0, calcium: 169.5)),
      ],
      notes: 'Breakfast',
    ));

    // Aanya's lunch: Rice + Toor Dal
    mealLogs.add(MealLog(
      mealId: 'meal_002',
      personId: 'person001',
      mealType: 'Lunch',
      date: DateTime.parse(today),
      items: [
        MealItem(foodId: 'GRAIN_RICE', name: 'Rice', quantity: 150, unit: 'g', nutrition: NutrientInfo(calories: 195, protein: 4.05, carbohydrates: 42, fat: 0.45, fiber: 0.6, iron: 1.2, calcium: 15)),
        MealItem(foodId: 'PULSE_TOOR_DAL', name: 'Toor Dal', quantity: 80, unit: 'g', nutrition: NutrientInfo(calories: 268, protein: 17.6, carbohydrates: 45.6, fat: 1.2, fiber: 11.2, iron: 6, calcium: 129.6)),
      ],
      notes: 'Lunch',
    ));

    // Aanya's dinner: Moong Dal Khichdi
    mealLogs.add(MealLog(
      mealId: 'meal_003',
      personId: 'person001',
      mealType: 'Dinner',
      date: DateTime.parse(today),
      items: [
        MealItem(foodId: 'GRAIN_RICE', name: 'Rice', quantity: 100, unit: 'g', nutrition: NutrientInfo(calories: 130, protein: 2.7, carbohydrates: 28, fat: 0.3, fiber: 0.4, iron: 0.8, calcium: 10)),
        MealItem(foodId: 'PULSE_MOONG_DAL', name: 'Moong Dal', quantity: 70, unit: 'g', nutrition: NutrientInfo(calories: 242.9, protein: 16.8, carbohydrates: 44.1, fat: 0.84, fiber: 11.2, iron: 4.69, calcium: 92.4)),
      ],
      notes: 'Dinner',
    ));

    // Rohan's breakfast: Eggs and toast
    mealLogs.add(MealLog(
      mealId: 'meal_004',
      personId: 'person002',
      mealType: 'Breakfast',
      date: DateTime.parse(today),
      items: [
        MealItem(foodId: 'DAIRY_EGGS', name: 'Eggs', quantity: 150, unit: 'g', nutrition: NutrientInfo(calories: 234, protein: 18.9, carbohydrates: 1.8, fat: 16.5, fiber: 0, calcium: 84)),
      ],
      notes: 'Breakfast',
    ));

    // Rohan's lunch: Chickpea curry
    mealLogs.add(MealLog(
      mealId: 'meal_005',
      personId: 'person002',
      mealType: 'Lunch',
      date: DateTime.parse(today),
      items: [
        MealItem(foodId: 'PULSE_CHICKPEAS', name: 'Chickpeas', quantity: 150, unit: 'g', nutrition: NutrientInfo(calories: 546, protein: 28.5, carbohydrates: 91.5, fat: 9, fiber: 25.5, iron: 9.9, calcium: 192)),
        MealItem(foodId: 'GRAIN_RICE', name: 'Rice', quantity: 150, unit: 'g', nutrition: NutrientInfo(calories: 195, protein: 4.05, carbohydrates: 42, fat: 0.45, fiber: 0.6, iron: 1.2, calcium: 15)),
      ],
      notes: 'Lunch',
    ));

    // Rohan's dinner: Wheat bread with peanuts
    mealLogs.add(MealLog(
      mealId: 'meal_006',
      personId: 'person002',
      mealType: 'Dinner',
      date: DateTime.parse(today),
      items: [
        MealItem(foodId: 'GRAIN_WHEAT', name: 'Wheat Flour Roti', quantity: 100, unit: 'g', nutrition: NutrientInfo(calories: 364, protein: 10.3, carbohydrates: 76.3, fat: 1, fiber: 12.2, iron: 5.3, calcium: 34)),
        MealItem(foodId: 'SEED_PEANUTS', name: 'Peanuts', quantity: 30, unit: 'g', nutrition: NutrientInfo(calories: 170.1, protein: 7.74, carbohydrates: 4.83, fat: 14.76, fiber: 2.58, iron: 0.51, calcium: 27.6)),
      ],
      notes: 'Dinner',
    ));
  }

  bool demoMode = false;
  int _idCounter = 100;
  String _nextId() => '${++_idCounter}';

  // ── Computed ──────────────────────────────────────────────────────────────
  int get lowStockCount => inventory.where((i) => i.status == 'Low Stock').length;
  int get outOfStockCount => inventory.where((i) => i.status == 'Out of Stock').length;
  int get unreadNotifications => notifications.where((n) => !n.read).length;
  List<GroceryItem> get attentionItems => inventory.where((i) => i.status != 'Available').toList();
  Set<String> get availableIngredients => inventory.where((i) => i.quantity > 0).map((i) => i.name).toSet();

  int matchPercent(Recipe recipe) {
    if (recipe.ingredients.isEmpty) return 0;
    final have = recipe.ingredients.where((ing) => availableIngredients.contains(ing.name)).length;
    return ((have / recipe.ingredients.length) * 100).round();
  }

  List<String> missingIngredients(Recipe recipe) =>
      recipe.ingredients.where((ing) => !availableIngredients.contains(ing.name)).map((ing) => ing.name).toList();

  List<Recipe> get sortedRecipes {
    final list = List<Recipe>.from(recipes);
    list.sort((a, b) => matchPercent(b).compareTo(matchPercent(a)));
    return list;
  }

  String get aiInsight {
    final cookable = recipes.where((r) => matchPercent(r) >= 75).length;
    if (attentionItems.isNotEmpty) {
      final first = attentionItems.first;
      return '${first.name} is running low. You can still prepare $cookable meals with current stock.';
    }
    return 'Your pantry is well stocked. You can prepare $cookable meals right now.';
  }

  List<String> get aiInsights {
    final insights = <String>[];
    final cookable = recipes.where((r) => matchPercent(r) == 100).toList();
    if (cookable.isNotEmpty) insights.add('You can make ${cookable.first.name} with 100% of ingredients available.');
    for (final item in attentionItems.take(2)) {
      insights.add('${item.name} is ${item.status.toLowerCase()} — consider restocking soon.');
    }
    final best = sortedRecipes.first;
    insights.add('Best recipe match: ${best.name} at ${matchPercent(best)}%.');
    final expiringSoon = inventory.where((i) => i.expiryDate != null && i.expiryDate!.difference(DateTime.now()).inDays <= 5 && i.quantity > 0).toList();
    if (expiringSoon.isNotEmpty) insights.add('Use ${expiringSoon.first.name} soon — expires in ${expiringSoon.first.expiryDate!.difference(DateTime.now()).inDays} days.');
    return insights;
  }

  // ── Inventory CRUD ────────────────────────────────────────────────────────
  void addGrocery(GroceryItem item) {
    final existing = inventory.where((i) => i.name.toLowerCase() == item.name.toLowerCase()).firstOrNull;
    if (existing != null) {
      existing.quantity += item.quantity;
      _log('${item.name} quantity updated.', Icons.edit, const Color(0xff176b5c));
    } else {
      inventory.add(item);
      _log('${item.name} added to pantry.', Icons.add_circle_outline, const Color(0xff176b5c));
    }
    _refreshShopping();
    notifyListeners();
  }

  void updateGrocery(GroceryItem updated) {
    final idx = inventory.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      inventory[idx] = updated;
      _log('${updated.name} details updated.', Icons.edit, const Color(0xff3677b8));
      _refreshShopping();
      notifyListeners();
    }
  }

  void deleteGrocery(String id) {
    final item = inventory.firstWhere((i) => i.id == id);
    inventory.removeWhere((i) => i.id == id);
    shopping.removeWhere((s) => s.name.toLowerCase() == item.name.toLowerCase());
    _log('${item.name} removed from pantry.', Icons.delete_outline, const Color(0xffc44d4d));
    notifyListeners();
  }

  GroceryItem buildNewItem({
    required String name, required String category, required double quantity,
    required String unit, required double minimumQuantity, required String location,
    DateTime? purchaseDate, DateTime? expiryDate,
  }) => GroceryItem(id: _nextId(), name: name, category: category, quantity: quantity, unit: unit, minimumQuantity: minimumQuantity, location: location, purchaseDate: purchaseDate, expiryDate: expiryDate);

  // ── Shopping ──────────────────────────────────────────────────────────────
  void _refreshShopping() {
    for (final item in attentionItems) {
      if (!shopping.any((s) => s.name.toLowerCase() == item.name.toLowerCase() && !s.completed)) {
        shopping.add(ShoppingItem(
          id: _nextId(), name: item.name,
          quantity: item.minimumQuantity > 0 ? item.minimumQuantity : 1,
          unit: item.unit,
          reason: item.status == 'Out of Stock' ? 'Out of stock' : 'Below minimum quantity',
          priority: item.status == 'Out of Stock' ? 'High' : 'Medium',
        ));
        _addNotification('${item.status}: ${item.name}', '${item.name} has been added to your shopping list.', Icons.add_shopping_cart, const Color(0xffc77b16));
      }
    }
  }

  void addToShoppingList(String name, double qty, String unit, String reason, String priority) {
    final existing = shopping.where((s) => s.name.toLowerCase() == name.toLowerCase() && !s.completed).firstOrNull;
    if (existing != null) {
      if (!existing.reason.contains(reason)) {
        existing.reason = '${existing.reason} & $reason';
      }
      if (existing.quantity < qty) {
        existing.quantity = qty;
        existing.unit = unit;
      }
      notifyListeners();
    } else {
      shopping.add(ShoppingItem(id: _nextId(), name: name, quantity: qty, unit: unit, reason: reason, priority: priority));
      _log('$name added to shopping list.', Icons.add_shopping_cart, const Color(0xffc77b16));
      notifyListeners();
    }
  }

  void addMissingToShopping(Recipe recipe) {
    for (final name in missingIngredients(recipe)) {
      addToShoppingList(name, 1, 'pcs', 'Required for ${recipe.name}', 'Medium');
    }
  }

  void purchaseItem(ShoppingItem item) {
    final grocery = inventory.where((g) => g.name.toLowerCase() == item.name.toLowerCase()).firstOrNull;
    if (grocery != null) {
      grocery.quantity += item.quantity;
    } else {
      inventory.add(GroceryItem(id: _nextId(), name: item.name, category: 'Other', quantity: item.quantity, unit: item.unit, minimumQuantity: 0, location: 'Pantry'));
    }
    item.completed = true;
    _log('${item.name} marked as purchased.', Icons.check_circle_outline, const Color(0xff25805c));
    notifyListeners();
  }

  void deleteShoppingItem(String id) {
    shopping.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void clearCompleted() {
    shopping.removeWhere((s) => s.completed);
    notifyListeners();
  }

  // ── Notifications ─────────────────────────────────────────────────────────
  void _addNotification(String title, String body, IconData icon, Color color) {
    notifications.insert(0, AppNotification(title, body, icon, color));
  }

  void markAllRead() {
    for (final n in notifications) n.read = true;
    notifyListeners();
  }

  void clearNotification(int index) {
    notifications.removeAt(index);
    notifyListeners();
  }

  // ── Activity ──────────────────────────────────────────────────────────────
  void _log(String message, IconData icon, Color color) {
    activity.insert(0, ActivityEntry(message, icon, color));
    if (activity.length > 50) activity.removeLast();
  }

  // ── AI Assistant ──────────────────────────────────────────────────────────
  String ask(String question) {
    final q = question.toLowerCase();
    if (q.contains('cook') || q.contains('make') || q.contains('recipe')) {
      final best = sortedRecipes.take(3).toList();
      return 'Top recipes for you: ${best.map((r) => '${r.name} (${matchPercent(r)}%)').join(', ')}.';
    }
    if (q.contains('ingredient') || q.contains('have') || q.contains('pantry')) {
      return 'You have ${availableIngredients.length} ingredients: ${availableIngredients.take(6).join(', ')}${availableIngredients.length > 6 ? ' and more.' : '.'}';
    }
    if (q.contains('buy') || q.contains('shopping') || q.contains('need')) {
      final pending = shopping.where((s) => !s.completed).toList();
      return pending.isEmpty ? 'Your shopping list is clear!' : 'You need to buy: ${pending.map((s) => s.name).join(', ')}.';
    }
    if (q.contains('low') || q.contains('running') || q.contains('stock')) {
      return attentionItems.isEmpty ? 'Everything is well stocked!' : 'Needs attention: ${attentionItems.map((i) => '${i.name} (${i.status})').join(', ')}.';
    }
    if (q.contains('dinner') || q.contains('lunch') || q.contains('breakfast')) {
      final meal = sortedRecipes.first;
      return 'I suggest ${meal.name} — ${matchPercent(meal)}% ingredient match, ${meal.cookingTime} minutes, ${meal.difficulty}.';
    }
    if (q.contains('rice')) return 'With rice you can make: ${recipes.where((r) => r.ingredientNames.contains('Rice')).map((r) => r.name).join(', ')}.';
    if (q.contains('egg')) return 'With eggs you can make: ${recipes.where((r) => r.ingredientNames.contains('Eggs')).map((r) => r.name).join(', ')}.';
    if (q.contains('tomato')) return 'With tomatoes: ${recipes.where((r) => r.ingredientNames.contains('Tomato')).map((r) => '${r.name} (${matchPercent(r)}%)').join(', ')}.';
    return 'I can help with recipes, pantry status, and shopping. Try "What can I cook?" or "What is running low?"';
  }

  // ── IoT Demo ──────────────────────────────────────────────────────────────
  void simulateGroceryAdded() {
    final item = inventory.firstWhere((i) => i.status != 'Available', orElse: () => inventory.first);
    item.quantity += item.minimumQuantity + 0.5;
    _log('IoT: ${item.name} restocked automatically.', Icons.sensors, const Color(0xff176b5c));
    _refreshShopping();
    notifyListeners();
  }

  void simulateGroceryConsumed() {
    final available = inventory.where((i) => i.quantity > 0).toList();
    if (available.isEmpty) return;
    final item = available[DateTime.now().millisecond % available.length];
    item.quantity = (item.quantity - 1).clamp(0, 999).toDouble();
    _log('IoT: ${item.name} consumed — quantity updated.', Icons.sensors, const Color(0xff3677b8));
    _refreshShopping();
    notifyListeners();
  }

  void simulateLowStock() {
    final item = inventory.firstWhere((i) => i.status == 'Available', orElse: () => inventory.first);
    item.quantity = item.minimumQuantity;
    _log('IoT: ${item.name} reached low stock threshold.', Icons.warning_amber_rounded, const Color(0xffc77b16));
    _addNotification('Low Stock Alert', '${item.name} is now at minimum level.', Icons.warning_amber_rounded, const Color(0xffc77b16));
    _refreshShopping();
    notifyListeners();
  }

  void simulateOutOfStock() {
    final item = inventory.firstWhere((i) => i.status != 'Out of Stock', orElse: () => inventory.first);
    item.quantity = 0;
    _log('IoT: ${item.name} is now out of stock.', Icons.error_outline, const Color(0xffc44d4d));
    _addNotification('Out of Stock', '${item.name} has run out.', Icons.error_outline, const Color(0xffc44d4d));
    _refreshShopping();
    notifyListeners();
  }

  void simulateIoTUpdate() {
    for (final device in iotDevices) {
      device.lastSync = DateTime.now();
    }
    final item = inventory[DateTime.now().second % inventory.length];
    item.quantity = (item.quantity + 0.25).clamp(0, 99).toDouble();
    _log('IoT inventory sync received from ${iotDevices.first.name}.', Icons.sensors, const Color(0xff176b5c));
    notifyListeners();
  }

  void simulateDisconnect() {
    for (final d in iotDevices) d.online = false;
    _log('IoT device disconnected.', Icons.wifi_off, const Color(0xffc44d4d));
    _addNotification('IoT Disconnected', 'Kitchen Monitor went offline.', Icons.wifi_off, const Color(0xffc44d4d));
    notifyListeners();
  }

  void simulateReconnect() {
    for (final d in iotDevices) {
      d.online = true;
      d.lastSync = DateTime.now();
    }
    _log('IoT device reconnected successfully.', Icons.wifi, const Color(0xff25805c));
    notifyListeners();
  }

  // ── Production Integration Boundaries ──────────────────────────────────────
  bool useFirebase = false;
  bool usePythonBackend = false;
  String pythonBackendUrl = 'http://localhost:8081';
  String firebaseUserId = 'user_sih_2026';

  /// Syncs local inventory changes to Firebase Firestore (User-isolated).
  /// In production, this binds to the `users/$firebaseUserId/inventory` collection.
  Future<void> syncWithFirebase() async {
    if (!useFirebase) {
      _log('Firebase: Sync skipped (using mock/local database).', Icons.cloud_queue, const Color(0xff3677b8));
      return;
    }
    try {
      _log('Firebase: Syncing inventory with cloud storage...', Icons.cloud_sync, const Color(0xff176b5c));
      // Production code:
      // final collection = FirebaseFirestore.instance.collection('users').doc(firebaseUserId).collection('inventory');
      // for (final item in inventory) {
      //   await collection.doc(item.id).set(item.toMap());
      // }
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network latency
      _log('Firebase: Synced ${inventory.length} items successfully.', Icons.cloud_done, const Color(0xff25805c));
    } catch (e) {
      _log('Firebase Sync Error: $e', Icons.error_outline, const Color(0xffc44d4d));
    }
    notifyListeners();
  }

  /// Sends inventory state to the Python FastAPI server to get advanced ML recipe recommendations.
  /// Hits POST `/recommendations` on Python backend.
  Future<void> fetchPythonMLRecommendations() async {
    if (!usePythonBackend) {
      _log('AI Recommendation: Local matching engine active.', Icons.auto_awesome, const Color(0xff3677b8));
      return;
    }
    try {
      _log('AI Engine: Requesting recipe recommendations from Python backend...', Icons.auto_awesome, const Color(0xff176b5c));
      // Production code:
      // final response = await http.post(
      //   Uri.parse('$pythonBackendUrl/recommendations'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'inventory': inventory.map((i) => i.toMap()).toList(),
      //     'preferences': prefs.toMap(),
      //   }),
      // );
      // if (response.statusCode == 200) { ... }
      await Future.delayed(const Duration(milliseconds: 600));
      _log('AI Engine: Advanced Python ML recommendations updated.', Icons.check_circle_outline, const Color(0xff25805c));
    } catch (e) {
      _log('AI Backend Error: $e', Icons.error_outline, const Color(0xffc44d4d));
    }
    notifyListeners();
  }

  /// Ingests a new sensor event from IoT hardware and updates the inventory.
  /// Hits POST `/iot/events` on the Python backend if connected.
  Future<void> sendIoTEvent(String deviceId, String eventType, Map<String, dynamic> payload) async {
    if (usePythonBackend) {
      try {
        _log('IoT Gateway: Forwarding hardware event to Python API...', Icons.sensors, const Color(0xff3677b8));
        // Production code:
        // await http.post(
        //   Uri.parse('$pythonBackendUrl/iot/events'),
        //   headers: {'Content-Type': 'application/json'},
        //   body: jsonEncode({'deviceId': deviceId, 'type': eventType, 'payload': payload}),
        // );
      } catch (e) {
        _log('IoT Gateway Error: $e', Icons.error_outline, const Color(0xffc44d4d));
      }
    }
  }

  // ── Nutrition Helpers ──────────────────────────────────────────────────────
  NutritionRecord? getDailyNutritionSummary(String personId, DateTime date) {
    _initializeDemoNutrition();

    final dateStr = date.toIso8601String().split('T')[0];
    final personMeals = mealLogs.where((m) => m.personId == personId && m.date.toIso8601String().split('T')[0] == dateStr).toList();

    if (personMeals.isEmpty) return null;

    double totalCalories = 0,
        totalProtein = 0,
        totalCarbs = 0,
        totalFat = 0,
        totalFiber = 0;
    final mealBreakdown = <String, NutrientInfo>{};

    for (final meal in personMeals) {
      final mealNutrition = meal.calculateTotalNutrition();
      totalCalories += mealNutrition.calories;
      totalProtein += mealNutrition.protein;
      totalCarbs += mealNutrition.carbohydrates;
      totalFat += mealNutrition.fat;
      totalFiber += mealNutrition.fiber;
      mealBreakdown[meal.mealType] = mealNutrition;
    }

    return NutritionRecord(
      personId: personId,
      date: date,
      totalNutrition: NutrientInfo(calories: totalCalories, protein: totalProtein, carbohydrates: totalCarbs, fat: totalFat, fiber: totalFiber),
      mealBreakdown: mealBreakdown,
    );
  }

  NutritionTarget? getNutritionTargets(String personId) {
    final member = householdMembers.firstWhere((m) => m.personId == personId, orElse: () => HouseholdMember(personId: '', name: '', age: 0, gender: 'Other', height: 0, weight: 0, activityLevel: '', nutritionGoal: ''));
    if (member.personId.isEmpty) return null;
    return NutritionTarget.getDefaultTargets(member);
  }

  void logMeal(String personId, String mealType, List<MealItem> items, {String? notes}) {
    _initializeDemoNutrition();

    final today = DateTime.now();
    final mealId = 'meal_${DateTime.now().millisecondsSinceEpoch}';

    mealLogs.add(MealLog(
      mealId: mealId,
      personId: personId,
      mealType: mealType,
      date: today,
      items: items,
      notes: notes,
    ));

    _log('Meal logged: $mealType for ${householdMembers.firstWhere((m) => m.personId == personId, orElse: () => HouseholdMember(personId: '', name: 'Unknown', age: 0, gender: 'Other', height: 0, weight: 0, activityLevel: '', nutritionGoal: '')).name}', Icons.restaurant, const Color(0xff176b5c));

    notifyListeners();
  }

  void changePerson(HouseholdMember member) {
    currentPerson = member;
    notifyListeners();
  }

  List<MealLog> getMealsForPerson(String personId, DateTime date) {
    _initializeDemoNutrition();
    final dateStr = date.toIso8601String().split('T')[0];
    return mealLogs.where((m) => m.personId == personId && m.date.toIso8601String().split('T')[0] == dateStr).toList();
  }

  Map<String, double> getWeeklyAverageNutrition(String personId) {
    _initializeDemoNutrition();

    final today = DateTime.now();
    double totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0, totalFiber = 0;
    int dayCount = 0;

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final record = getDailyNutritionSummary(personId, date);
      if (record != null) {
        totalCalories += record.totalNutrition.calories;
        totalProtein += record.totalNutrition.protein;
        totalCarbs += record.totalNutrition.carbohydrates;
        totalFat += record.totalNutrition.fat;
        totalFiber += record.totalNutrition.fiber;
        dayCount++;
      }
    }

    if (dayCount == 0) {
      return {'calories': 0, 'protein': 0, 'carbohydrates': 0, 'fat': 0, 'fiber': 0};
    }

    return {
      'calories': totalCalories / dayCount,
      'protein': totalProtein / dayCount,
      'carbohydrates': totalCarbs / dayCount,
      'fat': totalFat / dayCount,
      'fiber': totalFiber / dayCount,
    };
  }

  Map<String, dynamic> getMonthlyNutritionSummary(String personId) {
    _initializeDemoNutrition();

    final today = DateTime.now();
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    
    double totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0, totalFiber = 0;
    int dayCount = 0;
    final dailyData = <DateTime, NutrientInfo>{};

    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      if (date.isBefore(firstDayOfMonth)) break;
      
      final record = getDailyNutritionSummary(personId, date);
      if (record != null) {
        totalCalories += record.totalNutrition.calories;
        totalProtein += record.totalNutrition.protein;
        totalCarbs += record.totalNutrition.carbohydrates;
        totalFat += record.totalNutrition.fat;
        totalFiber += record.totalNutrition.fiber;
        dailyData[date] = record.totalNutrition;
        dayCount++;
      }
    }

    return {
      'averageCalories': dayCount > 0 ? totalCalories / dayCount : 0,
      'averageProtein': dayCount > 0 ? totalProtein / dayCount : 0,
      'averageCarbs': dayCount > 0 ? totalCarbs / dayCount : 0,
      'averageFat': dayCount > 0 ? totalFat / dayCount : 0,
      'averageFiber': dayCount > 0 ? totalFiber / dayCount : 0,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalFiber': totalFiber,
      'dayCount': dayCount,
      'dailyData': dailyData,
    };
  }
