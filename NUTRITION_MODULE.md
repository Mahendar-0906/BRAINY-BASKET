# Brainy Basket — Personal Nutrition Tracking and Analysis Module

## Overview

This document describes the **Personal Nutrition Tracking and Analysis Module** added to Brainy Basket. This module enables multi-person household nutrition tracking, meal logging, and intelligent nutrition analysis.

## Key Principles

1. **Estimated Nutrition**: All nutrition values are clearly marked as **ESTIMATED** unless sourced from a trusted database
2. **No Medical Claims**: The system does NOT provide medical diagnosis or medical treatment recommendations
3. **Multi-Person Support**: Each household member has independent nutrition tracking
4. **Inventory Independence**: ESP32 pantry weight ≠ personal consumption. The system tracks both separately:
   - **ESP32**: Measures pantry commodity quantity
   - **Meal Log**: Tracks what a specific person consumed
   - **Nutrition Engine**: Calculates that person's estimated nutrient intake

## Architecture

### Frontend (Flutter - Dart)

#### Data Models (`lib/models.dart`)

- **HouseholdMember**: Profile for each person (age, height, weight, activity level, nutrition goal)
- **FoodItem**: Nutrition database entries with estimated values per serving
- **MealLog**: Records what a person consumed (meal type, ingredients, date)
- **MealItem**: Individual food/ingredient in a meal with calculated nutrition
- **NutrientInfo**: Container for all nutrient values (calories, protein, carbs, fat, fiber, micronutrients)
- **NutritionRecord**: Daily summary of a person's nutrition
- **NutritionTarget**: Recommended daily nutrition goals based on member profile

#### UI Screen (`lib/screen_nutrition.dart`)

**Main Features:**

1. **Person Selector**: Switch between household members
2. **Daily Nutrition Tab**:
   - Displays today's nutrition breakdown
   - Shows macronutrient progress vs targets
   - Displays meal-by-meal breakdown
   - Date picker to view historical data
3. **Weekly Analysis Tab**:
   - 7-day average nutrition values
   - Trend indicators (above/on-track/below target)
   - Pattern identification
4. **Food Source Analysis Tab**:
   - Shows which foods contributed most to nutrient intake
   - Separates by macronutrient
   - AI-generated insights

#### State Management (`lib/state.dart`)

AppState extensions:

- `householdMembers`: List of all household members
- `mealLogs`: All logged meals
- `currentPerson`: Currently selected person
- `getDailyNutritionSummary()`: Get nutrition for a specific date
- `getNutritionTargets()`: Calculate recommended targets
- `logMeal()`: Record a new meal
- `getMealsForPerson()`: Get meals for a person on a date
- `getWeeklyAveragNutrition()`: Calculate 7-day averages

#### Navigation (`lib/main.dart`)

- Added "Nutrition" tab to main navigation (position: 4, between Shopping and Assistant)
- Icon: Icons.nutrition (health/nutrition icon)
- Imported screen_nutrition.dart

### Backend (Python FastAPI)

#### Nutrition Service (`backend/nutrition_service.py`)

**Key Functions:**

1. **Food Database Management**
   - `ensure_nutrition_seed_data()`: Initialize sample food database
   - `get_food_item(food_id)`: Retrieve nutrition for a food
   - `list_food_items()`: Get all food items

2. **Household Member Management**
   - `get_household_members(user_id)`: List all members for a user
   - `create_household_member()`: Add new household member

3. **Meal Logging**
   - `log_meal()`: Record a meal with ingredients
   - `calculate_nutrition_from_ingredients()`: Calculate total nutrition

4. **Nutrition Analysis**
   - `get_daily_nutrition()`: Get daily summary
   - `get_weekly_nutrition()`: Get weekly analysis
   - `get_nutrition_progress()`: Progress vs targets
   - `get_food_source_analysis()`: Which foods contributed most
   - `get_nutrition_targets()`: Recommended targets

#### API Endpoints (`backend/main.py`)

**Nutrition Routes:**

```
GET  /api/nutrition/foods              # List all food items
GET  /api/nutrition/foods/{food_id}    # Get specific food
GET  /api/nutrition/household/{user_id} # Get household members
POST /api/nutrition/household/{user_id} # Create new member

POST /api/nutrition/meal-logs/{person_id}         # Log a meal
GET  /api/nutrition/daily/{person_id}/{date}      # Daily nutrition summary
GET  /api/nutrition/weekly/{person_id}/{date}     # Weekly analysis
GET  /api/nutrition/progress/{person_id}/{date}   # Progress vs targets
GET  /api/nutrition/food-sources/{person_id}/{date} # Food source analysis
```

#### Sample Food Database

The system includes ~15 sample foods with estimated nutrition values:

**Pulses:**
- Toor Dal
- Moong Dal
- Chickpeas

**Grains:**
- Rice (White)
- Wheat Flour

**Millets:**
- Ragi (Finger Millet)

**Vegetables:**
- Tomato
- Onion

**Nuts & Seeds:**
- Peanuts

**Dairy:**
- Milk
- Eggs

All values are **marked as ESTIMATED** in the source.

### Firebase Collections

#### New Collections Added

```
household_members/
├── personId
│   ├── userId: string
│   ├── personId: string
│   ├── name: string
│   ├── age: integer
│   ├── height: float (cm)
│   ├── weight: float (kg)
│   ├── activityLevel: string (sedentary|light|moderate|active|veryActive)
│   ├── nutritionGoal: string (balanced|highProtein|weightManagement|wellness)
│   └── createdAt: timestamp

food_items/
├── foodId
│   ├── foodId: string
│   ├── name: string
│   ├── category: string
│   ├── servingSize: float
│   ├── servingUnit: string (g|ml|pcs|cup)
│   ├── nutrition: object
│   │   ├── calories: float
│   │   ├── protein: float (g)
│   │   ├── carbohydrates: float (g)
│   │   ├── fat: float (g)
│   │   ├── fiber: float (g)
│   │   ├── iron: float (mg, optional)
│   │   ├── calcium: float (mg, optional)
│   │   ├── sodium: float (mg, optional)
│   │   └── potassium: float (mg, optional)
│   └── description: string

meal_logs/
├── mealId
│   ├── mealId: string
│   ├── personId: string
│   ├── mealType: string (Breakfast|Lunch|Dinner|Snack)
│   ├── date: string (YYYY-MM-DD)
│   ├── ingredients: array
│   │   ├── foodId: string
│   │   ├── quantity: float
│   │   └── unit: string
│   ├── nutrition: object (calculated)
│   ├── recipeId: string (optional)
│   ├── notes: string (optional)
│   └── timestamp: timestamp

nutrition_records/
├── recordId
│   ├── personId: string
│   ├── date: string (YYYY-MM-DD)
│   ├── totalNutrition: object
│   │   ├── calories: float
│   │   ├── protein: float (g)
│   │   ├── carbohydrates: float (g)
│   │   ├── fat: float (g)
│   │   └── fiber: float (g)
│   ├── mealBreakdown: object
│   │   ├── Breakfast: nutrition object
│   │   ├── Lunch: nutrition object
│   │   ├── Dinner: nutrition object
│   │   └── Snack: nutrition object
│   └── recordedAt: timestamp

nutrition_targets/
├── personId
│   ├── personId: string
│   ├── calorieTarget: float
│   ├── proteinTarget: float (g)
│   ├── carbsTarget: float (g)
│   ├── fatTarget: float (g)
│   └── fiberTarget: float (g)
```

## Nutrition Calculation

### Macronutrient Distribution (by Goal)

**Balanced (Default):**
- Protein: 25% of calories
- Carbs: 50% of calories
- Fat: 25% of calories

**High Protein:**
- Protein: 35% of calories
- Carbs: 45% of calories
- Fat: 20% of calories

**Weight Management:**
- Protein: 30% of calories
- Carbs: 45% of calories
- Fat: 25% of calories

### Daily Calorie Calculation

Uses Mifflin-St Jeor formula:
```
BMR = (weight * 10) + (height * 6.25) - (age * 5)
Daily Calories = BMR * Activity Multiplier

Activity Multipliers:
- Sedentary: 1.2
- Light: 1.375
- Moderate: 1.55
- Active: 1.725
- Very Active: 1.9
```

### Serving-Based Calculation

```
If food contains: nutrients per serving (e.g., per 100g)
User consumes: X quantity

Then: consumed_nutrient = (nutrient_per_serving * X) / serving_size
```

## Demo Data

The system includes pre-populated demo meals:

**Aanya (Person 1):**
- Breakfast: Ragi Dosa (Ragi + Milk)
- Lunch: Rice + Toor Dal
- Dinner: Moong Dal Khichdi

**Rohan (Person 2):**
- Breakfast: Eggs (3 pcs)
- Lunch: Chickpea Curry + Rice
- Dinner: Wheat Roti + Peanuts

## Integration with Existing Systems

### With Recipes
- Recipes now have nutrition profiles in the `nutrition` field
- Users can log recipes as consumed meals
- System calculates nutrition for recipe servings

### With Inventory
- Nutrition module operates independently from inventory
- ESP32 measures pantry quantity (not consumption)
- Meal logs track personal consumption separately
- Users can reference available inventory when logging meals

### With AI Assistant
Extended assistant can answer:
- "What did I eat today?"
- "How much protein did I consume?"
- "Which meals gave me the most protein?"
- "What are my main carbohydrate sources?"
- "Show my nutrition summary for this week"
- "Suggest a meal using available groceries"

## Important Disclaimers

```
⚠️ ESTIMATED NUTRITION
All nutrition values in this system are ESTIMATED based on food database entries.
These values are NOT medically verified and should not be used for medical purposes.

This system is NOT a medical device.
Do NOT use for medical diagnosis, treatment, or medical nutrition therapy.

Targets are SUGGESTED estimates based on standard formulas.
Consult a healthcare professional for personalized nutrition advice.
```

## Usage Workflow

### For End Users

1. **Setup Household**
   - Create profiles for each household member
   - Set their age, height, weight, activity level, nutrition goal

2. **Log Meals**
   - Select meal type (Breakfast/Lunch/Dinner/Snack)
   - Add ingredients (select from database or search)
   - Specify quantities
   - System calculates nutrition automatically

3. **View Progress**
   - Daily: See macro breakdown and meal contribution
   - Weekly: Identify patterns and trends
   - Analysis: Find top nutrient sources

### For Developers

#### To Add New Foods

Edit `backend/nutrition_service.py`, add to `SAMPLE_FOOD_DATABASE`:

```python
{
    "foodId": "UNIQUE_ID",
    "name": "Food Name",
    "category": "Category",
    "servingSize": 100,
    "servingUnit": "g",
    "nutrition": {
        "calories": 0,
        "protein": 0,
        "carbohydrates": 0,
        "fat": 0,
        "fiber": 0,
    },
    "description": "Notes",
}
```

#### To Extend Nutrition Analysis

Add methods to `AppState` in `lib/state.dart`:

```dart
// Example: Get protein intake by source
Map<String, double> getProteinSources(String personId, DateTime date) {
  // Implementation
}
```

## Testing

### Acceptance Test

```
Given: Aanya logged breakfast, lunch, dinner
When: User views "Daily Nutrition" for today
Then: System shows:
  - Total calories, protein, carbs, fat, fiber
  - Meal-by-meal breakdown
  - Progress bars for each nutrient vs targets

Given: Rohan logged different meals
When: User switches to Rohan's profile
Then: System shows Rohan's nutrition (NOT Aanya's)

When: User changes serving size
Then: Nutrient totals update proportionally

When: ESP32 updates inventory weight
Then: Nutrition dashboard is unaffected
(inventory and nutrition are independent)
```

## Future Enhancements

1. **Barcode Scanner**: Scan food barcodes to log meals faster
2. **Recipe Nutrition**: Auto-calculate nutrition for recipes
3. **Meal Plans**: Suggest meal plans to meet targets
4. **Grocery Optimization**: Recommend grocery purchases based on nutrition goals
5. **Real Nutrition Database**: Integrate with USDA FoodData Central API
6. **Macro Cycling**: Support advanced nutrition strategies
7. **Shopping List Integration**: Add nutrient targets to shopping recommendations
8. **Wearable Integration**: Connect with fitness trackers
9. **Allergen Warnings**: Track and warn about allergens
10. **Portion Size Templates**: Quick-log common meal portions

## API Example Usage

### Log a Meal (cURL)

```bash
curl -X POST http://localhost:8082/api/nutrition/meal-logs/person001 \
  -H "Content-Type: application/json" \
  -d '{
    "mealType": "Lunch",
    "date": "2026-08-29",
    "ingredients": [
      {
        "foodId": "GRAIN_RICE",
        "quantity": 150,
        "unit": "g"
      },
      {
        "foodId": "PULSE_TOOR_DAL",
        "quantity": 80,
        "unit": "g"
      }
    ],
    "notes": "Rice and toor dal lunch"
  }'
```

### Get Daily Nutrition Summary

```bash
curl http://localhost:8082/api/nutrition/daily/person001/2026-08-29
```

### Get Nutrition Targets

```bash
curl http://localhost:8082/api/nutrition/household/user_sih_2026 | jq '.members[0]'
```

## File Structure

```
app/
├── lib/
│   ├── models.dart                 # (UPDATED) Added nutrition models
│   ├── state.dart                  # (UPDATED) Added nutrition state
│   ├── main.dart                   # (UPDATED) Added nutrition route
│   ├── screen_nutrition.dart       # (NEW) Nutrition UI
│   ├── screen_*.dart               # Existing screens
│   └── ...
├── backend/
│   ├── nutrition_service.py        # (NEW) Nutrition backend service
│   ├── main.py                     # (UPDATED) Added nutrition API routes
│   ├── firebase_service.py         # (UPDATED) Added nutrition collections
│   ├── inventory_service.py
│   └── ...
└── ...
```

## Dependencies

### Python
- fastapi >= 0.115.0
- firebase-admin >= 6.5.0

### Dart/Flutter
- flutter (existing)

## Notes on Design

### Why Separate Inventory from Nutrition?

- **Inventory (ESP32)**: Tracks pantry stock for shopping/recipe recommendations
- **Nutrition (Meal Logs)**: Tracks personal consumption for health insights
- These are conceptually different and should be independent
- A meal log entry is a deliberate user action, not automatic

### Why Estimated Values?

- The system uses a simplified food database for demo/MVP
- Real deployment should integrate with USDA FoodData Central
- Clearly labeling as "estimated" sets user expectations

### Why Local Nutrition Targets?

- Uses Mifflin-St Jeor formula (well-established, evidence-based)
- Does NOT claim medical accuracy
- Targets serve as "suggested guidelines" only
- Users should consult healthcare professionals for personalized advice

## Support & Maintenance

This module integrates seamlessly with existing Brainy Basket systems:
- ✅ Does NOT break ESP32 functionality
- ✅ Does NOT modify Firebase inventory structure
- ✅ Does NOT affect recipe engine (only extends it)
- ✅ Can be enabled/disabled independently
- ✅ Demo mode works without backend connection

For production deployment, enable `useFirebase` and `usePythonBackend` flags in AppState.

---

**Status**: ✅ MVP Complete - Ready for testing and production deployment

**Created**: 2026-08-29
**Version**: 1.0.0
