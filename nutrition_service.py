"""Personal Nutrition Tracking and Analysis Service.

Manages household members, food nutrition database, meal logging, and nutrition calculations.
All nutrition values are clearly marked as ESTIMATED unless from a trusted source.
"""
from __future__ import annotations

from datetime import datetime, timezone
from typing import Any
from .firebase_service import store

# ──────────────────────────────────────────────────────────────────────────
# SAMPLE NUTRITION DATABASE (ESTIMATED VALUES)
# ──────────────────────────────────────────────────────────────────────────

SAMPLE_FOOD_DATABASE = [
    # PULSES - Estimated values per 100g
    {
        "foodId": "PULSE_TOOR_DAL",
        "name": "Toor Dal",
        "category": "Pulses",
        "servingSize": 100,
        "servingUnit": "g",
        "nutrition": {
            "calories": 335,
            "protein": 22.0,
            "carbohydrates": 57.0,
            "fat": 1.5,
            "fiber": 14.0,
            "iron": 7.5,
            "calcium": 162.0,
        },
        "description": "Estimated nutrition per 100g (cooked: ~130 kcal per 100g)",
    },
    {
        "foodId": "PULSE_MOONG_DAL",
        "name": "Moong Dal",
        "category": "Pulses",
        "servingSize": 100,
        "servingUnit": "g",
        "nutrition": {
            "calories": 347,
            "protein": 24.0,
            "carbohydrates": 63.0,
            "fat": 1.2,
            "fiber": 16.0,
            "iron": 6.7,
            "calcium": 132.0,
        },
        "description": "Estimated nutrition per 100g raw",
    },
    {
        "foodId": "PULSE_CHICKPEAS",
        "name": "Chickpeas",
        "category": "Beans / Legumes",
        "servingSize": 100,
        "servingUnit": "g",
        "nutrition": {
            "calories": 364,
            "protein": 19.0,
            "carbohydrates": 61.0,
            "fat": 6.0,
            "fiber": 17.0,
            "iron": 6.6,
            "calcium": 128.0,
        },
        "description": "Estimated nutrition per 100g raw",
    },
    # GRAINS
    {
        "foodId": "GRAIN_RICE",
        "name": "Rice (White)",
        "category": "Grains",
        "servingSize": 100,
        "servingUnit": "g",
        "nutrition": {
            "calories": 130,
            "protein": 2.7,
            "carbohydrates": 28.0,
            "fat": 0.3,
            "fiber": 0.4,
            "iron": 0.8,
            "calcium": 10.0,
        },
        "description": "Estimated nutrition per 100g cooked",
    },
    {
        "foodId": "GRAIN_WHEAT",
        "name": "Wheat Flour",
        "category": "Grains",
        "servingSize": 100,
        "servingUnit": "g",
        "nutrition": {
            "calories": 364,
            "protein": 10.3,
            "carbohydrates": 76.3,
            "fat": 1.0,
            "fiber": 12.2,
            "iron": 5.3,
            "calcium": 34.0,
        },
        "description": "Estimated nutrition per 100g raw flour",
    },
    # MILLETS
    {
        "foodId": "MILLET_RAGI",
        "name": "Ragi (Finger Millet)",
        "category": "Millets",
        "servingSize": 100,
        "servingUnit": "g",
        "nutrition": {
            "calories": 328,
            "protein": 6.7,
            "carbohydrates": 72.6,
            "fat": 1.3,
            "fiber": 3.6,
            "iron": 28.3,
            "calcium": 344.0,
        },
        "description": "Estimated nutrition per 100g raw - high in calcium and iron",
    },
    # VEGETABLES
    {
        "foodId": "VEG_TOMATO",
        "name": "Tomato",
        "category": "Vegetables",
        "servingSize": 100,
        "servingUnit": "g",
        "nutrition": {
            "calories": 18,
            "protein": 0.9,
            "carbohydrates": 3.9,
            "fat": 0.2,
            "fiber": 1.2,
            "iron": 0.3,
            "calcium": 12.0,
        },
        "description": "Estimated nutrition per 100g fresh",
    },
    {
        "foodId": "VEG_ONION",
        "name": "Onion",
        "category": "Vegetables",
        "servingSize": 100,
        "servingUnit": "g",
        "nutrition": {
            "calories": 40,
            "protein": 1.1,
            "carbohydrates": 9.3,
            "fat": 0.1,
            "fiber": 1.7,
            "iron": 0.2,
            "calcium": 23.0,
        },
        "description": "Estimated nutrition per 100g fresh",
    },
    # NUTS & SEEDS
    {
        "foodId": "SEED_PEANUTS",
        "name": "Peanuts",
        "category": "Nuts & Seeds",
        "servingSize": 100,
        "servingUnit": "g",
        "nutrition": {
            "calories": 567,
            "protein": 25.8,
            "carbohydrates": 16.1,
            "fat": 49.2,
            "fiber": 8.6,
            "iron": 1.7,
            "calcium": 92.0,
        },
        "description": "Estimated nutrition per 100g raw",
    },
    # DAIRY (optional)
    {
        "foodId": "DAIRY_MILK",
        "name": "Milk (Regular)",
        "category": "Dairy",
        "servingSize": 100,
        "servingUnit": "ml",
        "nutrition": {
            "calories": 61,
            "protein": 3.2,
            "carbohydrates": 4.8,
            "fat": 3.3,
            "fiber": 0.0,
            "iron": 0.07,
            "calcium": 113.0,
        },
        "description": "Estimated nutrition per 100ml whole milk",
    },
    {
        "foodId": "DAIRY_EGGS",
        "name": "Eggs",
        "category": "Dairy",
        "servingSize": 50,
        "servingUnit": "g",
        "nutrition": {
            "calories": 78,
            "protein": 6.3,
            "carbohydrates": 0.6,
            "fat": 5.5,
            "fiber": 0.0,
            "iron": 1.8,
            "calcium": 28.0,
        },
        "description": "Estimated nutrition per 1 egg (~50g)",
    },
]


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def ensure_nutrition_seed_data() -> None:
    """Initialize nutrition database if empty."""
    if store.list("food_items"):
        return
    for food in SAMPLE_FOOD_DATABASE:
        store.upsert("food_items", food["foodId"], food)


def get_food_item(food_id: str) -> dict[str, Any] | None:
    """Get a food item from the nutrition database."""
    ensure_nutrition_seed_data()
    return store.get("food_items", food_id)


def list_food_items() -> list[dict[str, Any]]:
    """List all food items in the nutrition database."""
    ensure_nutrition_seed_data()
    return store.list("food_items")


def get_household_members(user_id: str) -> list[dict[str, Any]]:
    """Get all household members for a user."""
    members = store.list("household_members")
    return [m for m in members if m.get("userId") == user_id]


def create_household_member(
    user_id: str,
    person_id: str,
    name: str,
    age: int,
    height: float,
    weight: float,
    activity_level: str,
    nutrition_goal: str,
) -> dict[str, Any]:
    """Create a new household member profile."""
    member = {
        "userId": user_id,
        "personId": person_id,
        "name": name,
        "age": age,
        "height": height,  # cm
        "weight": weight,  # kg
        "activityLevel": activity_level,
        "nutritionGoal": nutrition_goal,
        "createdAt": now(),
    }
    return store.upsert("household_members", person_id, member)


def calculate_nutrition_from_ingredients(
    ingredients: list[dict[str, Any]],
) -> dict[str, float]:
    """Calculate total nutrition from a list of ingredients.
    
    Each ingredient should have:
    - foodId: str
    - quantity: float
    - unit: str
    """
    ensure_nutrition_seed_data()
    
    total_nutrition = {
        "calories": 0.0,
        "protein": 0.0,
        "carbohydrates": 0.0,
        "fat": 0.0,
        "fiber": 0.0,
        "iron": 0.0,
        "calcium": 0.0,
        "sodium": 0.0,
        "potassium": 0.0,
    }
    
    for ingredient in ingredients:
        food = get_food_item(ingredient["foodId"])
        if not food:
            continue
        
        serving_size = food["servingSize"]
        nutrition = food["nutrition"]
        quantity = ingredient["quantity"]
        
        # Calculate multiplier based on serving size
        multiplier = quantity / serving_size
        
        # Add to totals
        total_nutrition["calories"] += nutrition.get("calories", 0) * multiplier
        total_nutrition["protein"] += nutrition.get("protein", 0) * multiplier
        total_nutrition["carbohydrates"] += nutrition.get("carbohydrates", 0) * multiplier
        total_nutrition["fat"] += nutrition.get("fat", 0) * multiplier
        total_nutrition["fiber"] += nutrition.get("fiber", 0) * multiplier
        total_nutrition["iron"] += nutrition.get("iron", 0) * multiplier
        total_nutrition["calcium"] += nutrition.get("calcium", 0) * multiplier
        total_nutrition["sodium"] += nutrition.get("sodium", 0) * multiplier
        total_nutrition["potassium"] += nutrition.get("potassium", 0) * multiplier
    
    return total_nutrition


def log_meal(
    person_id: str,
    meal_type: str,  # 'Breakfast', 'Lunch', 'Dinner', 'Snack'
    date: str,  # ISO format date
    ingredients: list[dict[str, Any]],
    recipe_id: str | None = None,
    notes: str | None = None,
) -> dict[str, Any]:
    """Log a meal for a person."""
    meal_id = f"{person_id}_{date}_{meal_type}_{now()}"
    
    # Calculate nutrition
    nutrition = calculate_nutrition_from_ingredients(ingredients)
    
    meal_log = {
        "mealId": meal_id,
        "personId": person_id,
        "mealType": meal_type,
        "date": date,
        "ingredients": ingredients,
        "nutrition": nutrition,
        "recipeId": recipe_id,
        "notes": notes,
        "timestamp": now(),
    }
    
    return store.upsert("meal_logs", meal_id, meal_log)


def get_daily_nutrition(person_id: str, date: str) -> dict[str, Any]:
    """Get daily nutrition summary for a person on a specific date."""
    ensure_nutrition_seed_data()
    
    meal_logs = store.list("meal_logs")
    person_meals = [m for m in meal_logs if m.get("personId") == person_id and m.get("date") == date]
    
    total_nutrition = {
        "calories": 0.0,
        "protein": 0.0,
        "carbohydrates": 0.0,
        "fat": 0.0,
        "fiber": 0.0,
        "iron": 0.0,
        "calcium": 0.0,
        "sodium": 0.0,
        "potassium": 0.0,
    }
    
    meal_breakdown = {}
    
    for meal in person_meals:
        meal_nutrition = meal.get("nutrition", {})
        meal_type = meal.get("mealType", "")
        
        # Add to meal breakdown
        if meal_type not in meal_breakdown:
            meal_breakdown[meal_type] = {
                "calories": 0.0,
                "protein": 0.0,
                "carbohydrates": 0.0,
                "fat": 0.0,
                "fiber": 0.0,
            }
        
        for key in ["calories", "protein", "carbohydrates", "fat", "fiber"]:
            total_nutrition[key] += meal_nutrition.get(key, 0)
            meal_breakdown[meal_type][key] += meal_nutrition.get(key, 0)
    
    return {
        "personId": person_id,
        "date": date,
        "totalNutrition": total_nutrition,
        "mealBreakdown": meal_breakdown,
        "mealCount": len(person_meals),
        "meals": person_meals,
    }


def get_weekly_nutrition(person_id: str, date_str: str) -> dict[str, Any]:
    """Get weekly nutrition analysis starting from date_str."""
    from datetime import datetime as dt, timedelta
    
    start_date = dt.fromisoformat(date_str).date()
    days = 7
    
    daily_summaries = []
    aggregate = {
        "calories": 0.0,
        "protein": 0.0,
        "carbohydrates": 0.0,
        "fat": 0.0,
        "fiber": 0.0,
    }
    
    for i in range(days):
        current_date = (start_date + timedelta(days=i)).isoformat()
        daily = get_daily_nutrition(person_id, current_date)
        daily_summaries.append(daily)
        
        for key in aggregate:
            aggregate[key] += daily["totalNutrition"].get(key, 0)
    
    # Calculate averages
    averages = {k: v / days for k, v in aggregate.items()}
    
    return {
        "personId": person_id,
        "startDate": start_date.isoformat(),
        "days": days,
        "dailySummaries": daily_summaries,
        "totalNutrition": aggregate,
        "averageNutrition": averages,
    }


def get_nutrition_targets(member: dict[str, Any]) -> dict[str, float]:
    """Calculate recommended nutrition targets based on member profile.
    
    Uses Mifflin-St Jeor formula (gender-aware):
    - Male: (weight*10 + height*6.25 - age*5)
    - Female: (weight*9.563 + height*1.85 - age*4.676)
    
    Goal-based calorie adjustment:
    - maintainWeight: ±0 kcal
    - gainWeight: +500 kcal
    - loseWeight: -500 kcal
    
    Macro distribution: 25% protein, 50% carbs, 25% fat
    """
    weight = member.get("weight", 70)
    height = member.get("height", 170)
    age = member.get("age", 30)
    gender = member.get("gender", "Other")
    
    # Gender-aware BMR (Mifflin-St Jeor formula)
    if gender == "Male":
        bmr = weight * 10 + height * 6.25 - age * 5
    elif gender == "Female":
        bmr = weight * 9.563 + height * 1.85 - age * 4.676
    else:  # Other or unspecified
        bmr = weight * 9.8 + height * 6.05 - age * 4.8
    
    # Activity multiplier
    activity_multiplier = {
        "sedentary": 1.2,
        "light": 1.375,
        "moderate": 1.55,
        "active": 1.725,
        "veryActive": 1.9,
    }.get(member.get("activityLevel", "moderate"), 1.55)
    
    daily_calories = bmr * activity_multiplier
    
    # Goal-based calorie adjustment (±500 kcal)
    goal = member.get("nutritionGoal", "maintainWeight")
    if goal == "gainWeight":
        daily_calories += 500
    elif goal == "loseWeight":
        daily_calories -= 500
    # maintainWeight: no adjustment
    
    # Fixed macro distribution (25% protein, 50% carbs, 25% fat)
    protein_percent = 0.25
    carb_percent = 0.50
    fat_percent = 0.25
    
    return {
        "calorieTarget": daily_calories,
        "proteinTarget": (daily_calories * protein_percent) / 4,  # 4 kcal/g
        "carbsTarget": (daily_calories * carb_percent) / 4,  # 4 kcal/g
        "fatTarget": (daily_calories * fat_percent) / 9,  # 9 kcal/g
        "fiberTarget": 25.0,  # general recommendation
    }


def get_nutrition_progress(person_id: str, date_str: str) -> dict[str, Any]:
    """Get nutrition progress vs targets for a specific date."""
    member_data = store.list("household_members")
    member = next((m for m in member_data if m.get("personId") == person_id), None)
    
    if not member:
        return {"error": "Member not found"}
    
    daily = get_daily_nutrition(person_id, date_str)
    targets = get_nutrition_targets(member)
    
    # Calculate progress percentages
    progress = {}
    for key in ["calorieTarget", "proteinTarget", "carbsTarget", "fatTarget", "fiberTarget"]:
        target_key = key.replace("Target", "")
        if key == "calorieTarget":
            target_key = "calories"
        elif key == "carbsTarget":
            target_key = "carbohydrates"
        elif key == "fatTarget":
            target_key = "fat"
        elif key == "fiberTarget":
            target_key = "fiber"
        
        actual = daily["totalNutrition"].get(target_key, 0)
        target = targets[key]
        progress[key] = {
            "actual": actual,
            "target": target,
            "percentage": (actual / target * 100) if target > 0 else 0,
        }
    
    return {
        "personId": person_id,
        "date": date_str,
        "member": member,
        "daily": daily,
        "targets": targets,
        "progress": progress,
    }


def get_food_source_analysis(person_id: str, date_str: str) -> dict[str, Any]:
    """Analyze which foods contributed most to nutrient intake."""
    daily = get_daily_nutrition(person_id, date_str)
    meal_logs = daily.get("meals", [])
    
    food_contributions = {}
    
    for meal in meal_logs:
        ingredients = meal.get("ingredients", [])
        for ingredient in ingredients:
            food_id = ingredient["foodId"]
            food = get_food_item(food_id)
            
            if not food:
                continue
            
            food_name = food.get("name", food_id)
            quantity = ingredient["quantity"]
            
            if food_name not in food_contributions:
                food_contributions[food_name] = {
                    "quantity": 0,
                    "unit": ingredient.get("unit", "g"),
                    "category": food.get("category", ""),
                    "nutrition": {k: 0 for k in ["calories", "protein", "carbohydrates", "fat", "fiber"]},
                }
            
            # Calculate contribution
            nutrition = food["nutrition"]
            multiplier = quantity / food["servingSize"]
            
            food_contributions[food_name]["quantity"] += quantity
            for key in ["calories", "protein", "carbohydrates", "fat", "fiber"]:
                food_contributions[food_name]["nutrition"][key] += nutrition.get(key, 0) * multiplier
    
    # Sort by protein, carbs, fiber
    sources = {
        "protein": [],
        "carbohydrates": [],
        "fiber": [],
    }
    
    for food_name, data in food_contributions.items():
        sources["protein"].append((food_name, data["nutrition"]["protein"]))
        sources["carbohydrates"].append((food_name, data["nutrition"]["carbohydrates"]))
        sources["fiber"].append((food_name, data["nutrition"]["fiber"]))
    
    # Sort and get top contributors
    for key in sources:
        sources[key] = sorted(sources[key], key=lambda x: x[1], reverse=True)[:5]
    
    return {
        "personId": person_id,
        "date": date_str,
        "foodContributions": food_contributions,
        "topSources": sources,
    }
