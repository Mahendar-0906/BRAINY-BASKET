import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';

class LogMealDialog extends StatefulWidget {
  const LogMealDialog({
    super.key,
    required this.state,
    required this.personId,
    required this.onMealLogged,
  });

  final AppState state;
  final String personId;
  final VoidCallback onMealLogged;

  @override
  State<LogMealDialog> createState() => _LogMealDialogState();
}

class _LogMealDialogState extends State<LogMealDialog> {
  String _selectedMealType = 'Lunch';
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  final List<MealItem> _selectedItems = [];
  String _notes = '';

  // Nutrition database for common pantry items (estimated values)
  final Map<String, NutrientInfo> _nutritionDatabase = {
    'Rice': NutrientInfo(calories: 130, protein: 2.7, carbohydrates: 28.0, fat: 0.3, fiber: 0.4),
    'Wheat Flour': NutrientInfo(calories: 364, protein: 10.3, carbohydrates: 76.3, fat: 1.0, fiber: 12.2),
    'Toor Dal': NutrientInfo(calories: 335, protein: 22.0, carbohydrates: 57.0, fat: 1.5, fiber: 14.0),
    'Moong Dal': NutrientInfo(calories: 347, protein: 24.0, carbohydrates: 63.0, fat: 1.2, fiber: 16.0),
    'Chickpeas': NutrientInfo(calories: 364, protein: 19.0, carbohydrates: 61.0, fat: 6.0, fiber: 17.0),
    'Ragi': NutrientInfo(calories: 328, protein: 6.7, carbohydrates: 72.6, fat: 1.3, fiber: 3.6),
    'Milk': NutrientInfo(calories: 61, protein: 3.2, carbohydrates: 4.8, fat: 3.3, fiber: 0.0),
    'Eggs': NutrientInfo(calories: 78, protein: 6.3, carbohydrates: 0.6, fat: 5.5, fiber: 0.0),
    'Tomato': NutrientInfo(calories: 18, protein: 0.9, carbohydrates: 3.9, fat: 0.2, fiber: 1.2),
    'Onion': NutrientInfo(calories: 40, protein: 1.1, carbohydrates: 9.3, fat: 0.1, fiber: 1.7),
    'Potato': NutrientInfo(calories: 77, protein: 2.0, carbohydrates: 17.0, fat: 0.1, fiber: 2.2),
    'Peanuts': NutrientInfo(calories: 567, protein: 25.8, carbohydrates: 16.1, fat: 49.2, fiber: 8.6),
    'Cooking Oil': NutrientInfo(calories: 884, protein: 0.0, carbohydrates: 0.0, fat: 100.0, fiber: 0.0),
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Log Meal',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff176b5c)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Meal type selector
            const Text('Meal Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _mealTypes.map((type) {
                  final isSelected = _selectedMealType == type;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMealType = type),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xff176b5c) : const Color(0xfff0f0f0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xff7a8a85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Tab for food selection
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Color(0xff176b5c),
                    unselectedLabelColor: Color(0xff7a8a85),
                    indicatorColor: Color(0xff176b5c),
                    tabs: [
                      Tab(text: 'From Recipes'),
                      Tab(text: 'From Pantry'),
                    ],
                  ),
                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      children: [
                        _buildRecipeList(),
                        _buildPantryList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Selected items
            const Text('Selected Items', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xfff9f9f9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: _selectedItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No items selected',
                        style: TextStyle(color: Color(0xff7a8a85)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _selectedItems.length,
                      itemBuilder: (context, index) {
                        final item = _selectedItems[index];
                        return ListTile(
                          title: Text(item.name),
                          subtitle: Text('${item.quantity} ${item.unit}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Color(0xffc44d4d)),
                            onPressed: () => setState(() => _selectedItems.removeAt(index)),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                hintText: 'e.g., Added extra ghee',
              ),
              onChanged: (value) => _notes = value,
            ),
            const SizedBox(height: 16),

            // Nutrition summary
            if (_selectedItems.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffe5f2eb),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xff176b5c), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated Nutrition',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff176b5c)),
                    ),
                    const SizedBox(height: 8),
                    _buildNutritionSummary(),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ Nutrition values are ESTIMATED',
                style: TextStyle(fontSize: 11, color: Color(0xffc77b16), fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedItems.isEmpty ? null : _logMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff176b5c),
                  ),
                  child: const Text('Log Meal'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeList() {
    return ListView.builder(
      itemCount: widget.state.recipes.length,
      itemBuilder: (context, index) {
        final recipe = widget.state.recipes[index];
        return ListTile(
          title: Text(recipe.name),
          subtitle: Text('${recipe.cookingTime} min • ${recipe.difficulty}'),
          trailing: const Icon(Icons.add_circle_outline, color: Color(0xff176b5c)),
          onTap: () => _addRecipeItems(recipe),
        );
      },
    );
  }

  Widget _buildPantryList() {
    final availableItems = widget.state.inventory.where((i) => i.quantity > 0).toList();
    return ListView.builder(
      itemCount: availableItems.length,
      itemBuilder: (context, index) {
        final item = availableItems[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text('${item.quantity} ${item.unit} available'),
          trailing: const Icon(Icons.add_circle_outline, color: Color(0xff176b5c)),
          onTap: () => _showQuantityDialog(item.name),
        );
      },
    );
  }

  void _addRecipeItems(Recipe recipe) {
    for (final ingredient in recipe.ingredients) {
      final nutrition = _nutritionDatabase[ingredient.name] ?? 
          NutrientInfo(calories: 100, protein: 5, carbohydrates: 15, fat: 2, fiber: 2);
      
      _selectedItems.add(MealItem(
        foodId: ingredient.name,
        name: ingredient.name,
        quantity: ingredient.quantity,
        unit: ingredient.unit,
        nutrition: nutrition,
      ));
    }
    setState(() {});
  }

  void _showQuantityDialog(String foodName) {
    final controller = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $foodName'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantity',
            suffixText: 'serving',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = double.tryParse(controller.text) ?? 1;
              final nutrition = _nutritionDatabase[foodName] ?? 
                  NutrientInfo(calories: 100, protein: 5, carbohydrates: 15, fat: 2, fiber: 2);
              
              _selectedItems.add(MealItem(
                foodId: foodName,
                name: foodName,
                quantity: quantity,
                unit: 'serving',
                nutrition: nutrition,
              ));
              setState(() {});
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff176b5c)),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary() {
    double calories = 0, protein = 0, carbs = 0, fat = 0, fiber = 0;
    
    for (final item in _selectedItems) {
      calories += item.nutrition.calories;
      protein += item.nutrition.protein;
      carbs += item.nutrition.carbohydrates;
      fat += item.nutrition.fat;
      fiber += item.nutrition.fiber;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNutrientChip('Calories', '${calories.toStringAsFixed(0)} kcal', Icons.local_fire_department),
        _buildNutrientChip('Protein', '${protein.toStringAsFixed(1)}g', Icons.restaurant),
        _buildNutrientChip('Carbs', '${carbs.toStringAsFixed(1)}g', Icons.grain),
        _buildNutrientChip('Fat', '${fat.toStringAsFixed(1)}g', Icons.opacity),
        _buildNutrientChip('Fiber', '${fiber.toStringAsFixed(1)}g', Icons.eco),
      ],
    );
  }

  Widget _buildNutrientChip(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xff176b5c)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xff7a8a85))),
      ],
    );
  }

  void _logMeal() {
    widget.state.logMeal(
      widget.personId,
      _selectedMealType,
      _selectedItems,
      notes: _notes.isNotEmpty ? _notes : null,
    );
    widget.onMealLogged();
  }
}
