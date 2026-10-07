import 'package:flutter/material.dart';

class GroceryItem {
  GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minimumQuantity,
    required this.location,
    this.deviceId,
    this.itemId,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  final String id;
  String name;
  String category;
  double quantity;
  String unit;
  double minimumQuantity;
  String location;
  String? deviceId;
  String? itemId;
  DateTime lastUpdated;

  String get status {
    if (quantity == 0) return 'Out of Stock';
    if (quantity <= minimumQuantity) return 'Low Stock';
    return 'Available';
  }

  Color get statusColor {
    if (status == 'Out of Stock') return const Color(0xffc44d4d);
    if (status == 'Low Stock') return const Color(0xffc77b16);
    return const Color(0xff25805c);
  }

  Color get statusBg {
    if (status == 'Out of Stock') return const Color(0xffffe1e1);
    if (status == 'Low Stock') return const Color(0xffffefd5);
    return const Color(0xffe5f2eb);
  }

  GroceryItem copyWith({
    String? name,
    String? category,
    double? quantity,
    String? unit,
    double? minimumQuantity,
    String? location,
    String? deviceId,
    String? itemId,
    DateTime? lastUpdated,
  }) =>
      GroceryItem(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        minimumQuantity: minimumQuantity ?? this.minimumQuantity,
        location: location ?? this.location,
        deviceId: deviceId ?? this.deviceId,
        itemId: itemId ?? this.itemId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'itemId': itemId ?? id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'minimumQuantity': minimumQuantity,
        'location': location,
        'deviceId': deviceId,
        'status': status,
        'lastUpdated': lastUpdated.toIso8601String(),
      };
}

class SensorReading {
  SensorReading({
    required this.deviceId,
    required this.itemId,
    required this.value,
    required this.unit,
    required this.timestamp,
  });
  final String deviceId;
  final String itemId;
  final double value;
  final String unit;
  final DateTime timestamp;
}

class RecipeIngredient {
  const RecipeIngredient(this.name, this.quantity, this.unit);
  final String name;
  final double quantity;
  final String unit;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.difficulty,
    required this.category,
    this.nutrition,
  });
  final String id;
  final String name;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final int cookingTime;
  final String difficulty;
  final String category;
  final Map<String, String>? nutrition;

  List<String> get ingredientNames => ingredients.map((i) => i.name).toList();
}

class ShoppingItem {
  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.reason,
    required this.priority,
    this.completed = false,
  });
  final String id;
  String name;
  double quantity;
  String unit;
  String reason;
  String priority;
  bool completed;
}

class ActivityEntry {
  ActivityEntry(this.message, this.icon, this.color) : time = DateTime.now();
  final String message;
  final IconData icon;
  final Color color;
  final DateTime time;
}

class AppNotification {
  AppNotification(this.title, this.body, this.icon, this.color)
      : time = DateTime.now(),
        read = false;
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final DateTime time;
  bool read;
}

class IoTDevice {
  IoTDevice({
    required this.id,
    required this.name,
    required this.assignedItemId,
    required this.assignedCommodity,
    this.online = true,
    this.latestValue,
    this.latestUnit = 'kg',
  }) : lastSync = DateTime.now();
  final String id;
  final String name;
  final String assignedItemId;
  final String assignedCommodity;
  bool online;
  DateTime lastSync;
  double? latestValue;
  String latestUnit;
}

class UserPreferences {
  UserPreferences({
    this.name = 'Aanya',
    this.favoriteCategories = const ['Pulses', 'Grains', 'Millets'],
    this.preferredCookingTime = 30,
    this.preferredDifficulty = 'Easy',
  });
  String name;
  List<String> favoriteCategories;
  int preferredCookingTime;
  String preferredDifficulty;
}

const kCategories = [
  'Pulses',
  'Grains',
  'Cereals',
  'Lentils',
  'Beans / Legumes',
  'Millets',
  'Nuts & Seeds',
  'Dry Pantry',
  'Spices',
  'Other Dry Grocery',
];

const kUnits = ['kg', 'g', 'L', 'mL', 'pcs', 'pack'];
const kLocations = ['Pantry', 'Storage Room', 'Cabinet', 'Shelf', 'Counter'];
const kPriorities = ['High', 'Medium', 'Low'];

// ──────────────────────────────────────────────────────────────────────────
// NUTRITION TRACKING MODELS
// ──────────────────────────────────────────────────────────────────────────

/// Household member profile for multi-person nutrition tracking
class HouseholdMember {
  HouseholdMember({
    required this.personId,
    required this.name,
    required this.age,
    required this.gender, // 'Male', 'Female', 'Other'
    required this.height, // cm
    required this.weight, // kg
    required this.activityLevel, // 'sedentary', 'light', 'moderate', 'active', 'veryActive'
    required this.nutritionGoal, // 'maintainWeight', 'gainWeight', 'loseWeight'
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String personId;
  String name;
  int age;
  String gender; // Male, Female, Other
  double height; // centimeters
  double weight; // kilograms
  String activityLevel;
  String nutritionGoal; // maintainWeight, gainWeight, loseWeight
  DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'personId': personId,
        'name': name,
        'age': age,
        'gender': gender,
        'height': height,
        'weight': weight,
        'activityLevel': activityLevel,
        'nutritionGoal': nutritionGoal,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Nutrient information storage (estimated values - APPROXIMATIONS ONLY)
class NutrientInfo {
  const NutrientInfo({
    required this.calories, // kcal per serving
    required this.protein, // grams
    required this.carbohydrates, // grams
    required this.fat, // grams
    required this.fiber, // grams
    this.iron, // mg
    this.calcium, // mg
    this.sodium, // mg
    this.potassium, // mg
  });

  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final double? iron;
  final double? calcium;
  final double? sodium;
  final double? potassium;

  Map<String, dynamic> toMap() => {
        'calories': calories,
        'protein': protein,
        'carbohydrates': carbohydrates,
        'fat': fat,
        'fiber': fiber,
        if (iron != null) 'iron': iron,
        if (calcium != null) 'calcium': calcium,
        if (sodium != null) 'sodium': sodium,
        if (potassium != null) 'potassium': potassium,
      };
}

/// Food item in the nutrition database (estimated values)
class FoodItem {
  FoodItem({
    required this.foodId,
    required this.name,
    required this.category, // 'Pulses', 'Grains', 'Vegetables', etc.
    required this.servingSize, // numeric value
    required this.servingUnit, // 'g', 'ml', 'pcs', 'cup'
    required this.nutrition,
    this.description,
  });

  final String foodId;
  final String name;
  final String category;
  final double servingSize;
  final String servingUnit;
  final NutrientInfo nutrition; // per serving
  final String? description;

  /// Calculate nutrients for a given quantity
  NutrientInfo calculateNutrients(double quantity) {
    final multiplier = quantity / servingSize;
    return NutrientInfo(
      calories: nutrition.calories * multiplier,
      protein: nutrition.protein * multiplier,
      carbohydrates: nutrition.carbohydrates * multiplier,
      fat: nutrition.fat * multiplier,
      fiber: nutrition.fiber * multiplier,
      iron: nutrition.iron != null ? nutrition.iron! * multiplier : null,
      calcium: nutrition.calcium != null ? nutrition.calcium! * multiplier : null,
      sodium: nutrition.sodium != null ? nutrition.sodium! * multiplier : null,
      potassium: nutrition.potassium != null ? nutrition.potassium! * multiplier : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'foodId': foodId,
        'name': name,
        'category': category,
        'servingSize': servingSize,
        'servingUnit': servingUnit,
        'nutrition': nutrition.toMap(),
        if (description != null) 'description': description,
      };
}

/// Meal log entry - what a person consumed
class MealLog {
  MealLog({
    required this.mealId,
    required this.personId,
    required this.mealType, // 'Breakfast', 'Lunch', 'Dinner', 'Snack'
    required this.date,
    required this.items, // List of meal items (recipes or foods)
    this.recipeId,
    this.notes,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String mealId;
  final String personId;
  final String mealType;
  final DateTime date;
  final List<MealItem> items;
  final String? recipeId; // if logging a recipe
  final String? notes;
  final DateTime timestamp;

  /// Calculate total nutrition for this meal
  NutrientInfo calculateTotalNutrition() {
    double calories = 0, protein = 0, carbs = 0, fat = 0, fiber = 0;
    double? iron, calcium, sodium, potassium;

    for (final item in items) {
      final nutrients = item.nutrition;
      calories += nutrients.calories;
      protein += nutrients.protein;
      carbs += nutrients.carbohydrates;
      fat += nutrients.fat;
      fiber += nutrients.fiber;
    }

    return NutrientInfo(
      calories: calories,
      protein: protein,
      carbohydrates: carbs,
      fat: fat,
      fiber: fiber,
    );
  }

  Map<String, dynamic> toMap() => {
        'mealId': mealId,
        'personId': personId,
        'mealType': mealType,
        'date': date.toIso8601String(),
        'items': items.map((i) => i.toMap()).toList(),
        if (recipeId != null) 'recipeId': recipeId,
        if (notes != null) 'notes': notes,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Individual item in a meal (food or recipe component)
class MealItem {
  MealItem({
    required this.foodId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.nutrition,
  });

  final String foodId;
  final String name;
  final double quantity;
  final String unit;
  final NutrientInfo nutrition; // already calculated for this quantity

  Map<String, dynamic> toMap() => {
        'foodId': foodId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'nutrition': nutrition.toMap(),
      };
}

/// Daily nutrition summary record
class NutritionRecord {
  NutritionRecord({
    required this.personId,
    required this.date,
    required this.totalNutrition,
    required this.mealBreakdown, // Map<mealType, nutrition>
    DateTime? recordedAt,
  }) : recordedAt = recordedAt ?? DateTime.now();

  final String personId;
  final DateTime date;
  final NutrientInfo totalNutrition;
  final Map<String, NutrientInfo> mealBreakdown; // 'Breakfast' -> NutrientInfo
  DateTime recordedAt;

  Map<String, dynamic> toMap() => {
        'personId': personId,
        'date': date.toIso8601String(),
        'totalNutrition': totalNutrition.toMap(),
        'mealBreakdown': mealBreakdown.map(
          (key, value) => MapEntry(key, value.toMap()),
        ),
        'recordedAt': recordedAt.toIso8601String(),
      };
}

/// Nutrition target/goal for a person
class NutritionTarget {
  NutritionTarget({
    required this.personId,
    required this.calorieTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.fiberTarget,
  });

  final String personId;
  double calorieTarget; // kcal per day
  double proteinTarget; // grams per day
  double carbsTarget; // grams per day
  double fatTarget; // grams per day
  double fiberTarget; // grams per day

  Map<String, dynamic> toMap() => {
        'personId': personId,
        'calorieTarget': calorieTarget,
        'proteinTarget': proteinTarget,
        'carbsTarget': carbsTarget,
        'fatTarget': fatTarget,
        'fiberTarget': fiberTarget,
      };

  /// Get default targets based on activity level and nutrition goal
  static NutritionTarget getDefaultTargets(HouseholdMember member) {
    // Mifflin-St Jeor calculation for BMR (gender-aware)
    final bmr = member.gender == 'Male'
        ? (member.weight * 10 + member.height * 6.25 - member.age * 5)
        : (member.weight * 9.563 + member.height * 1.85 - member.age * 4.676);

    // Activity multiplier
    final activityMultiplier = switch (member.activityLevel) {
      'sedentary' => 1.2,
      'light' => 1.375,
      'moderate' => 1.55,
      'active' => 1.725,
      'veryActive' => 1.9,
      _ => 1.55,
    };

    var dailyCalories = bmr * activityMultiplier;

    // Adjust for nutrition goal
    switch (member.nutritionGoal) {
      case 'gainWeight':
        dailyCalories += 500; // Surplus for weight gain
      case 'loseWeight':
        dailyCalories -= 500; // Deficit for weight loss
      case 'maintainWeight':
        break; // No adjustment
    }

    // Macro distribution - balanced for all goals
    const proteinPercent = 0.25; // Protein helps with both gain and loss
    const carbPercent = 0.50;
    const fatPercent = 0.25;

    return NutritionTarget(
      personId: member.personId,
      calorieTarget: dailyCalories,
      proteinTarget: (dailyCalories * proteinPercent) / 4, // 4 kcal per gram
      carbsTarget: (dailyCalories * carbPercent) / 4,
      fatTarget: (dailyCalories * fatPercent) / 9, // 9 kcal per gram
      fiberTarget: 25.0, // general recommendation
    );
  }
}
