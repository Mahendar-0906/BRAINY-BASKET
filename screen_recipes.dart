import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';
import 'widgets.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key, required this.state});
  final AppState state;
  @override State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String _filter = 'All';
  final _categories = ['All', 'Quick Meals', 'Breakfast', 'Comfort Food', 'Light Meals', 'Everyday', 'Special'];

  List<Recipe> get _filtered {
    final sorted = widget.state.sortedRecipes;
    if (_filter == 'All') return sorted;
    return sorted.where((r) => r.category == _filter).toList();
  }

  @override
  Widget build(BuildContext context) => PageScaffold(
        title: 'Recipes for You',
        subtitle: 'Matched to what is already in your pantry',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _categories.map((cat) => GestureDetector(
              onTap: () => setState(() => _filter = cat),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: _filter == cat ? kGreen : kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: _filter == cat ? kGreen : const Color(0xffe0e0e0))),
                child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _filter == cat ? Colors.white : const Color(0xff7a8a85))),
              ),
            )).toList()),
          ),
          const SizedBox(height: 16),
          // Match legend
          Row(children: [
            _legend(kGreen, '≥90% Ready'),
            const SizedBox(width: 12),
            _legend(kOrange, '70–89% Close'),
            const SizedBox(width: 12),
            _legend(kRed, '<70% Missing'),
          ]),
          const SizedBox(height: 16),
          if (_filtered.isEmpty)
            const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Add more ingredients to discover recipes.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xff7a8a85)))))
          else
            ..._filtered.map((recipe) => RecipeCard(
              recipe: recipe,
              matchPct: widget.state.matchPercent(recipe),
              missing: widget.state.missingIngredients(recipe),
              onTap: () => _showDetail(context, recipe),
              onAddMissing: () {
                widget.state.addMissingToShopping(recipe);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Missing ingredients for ${recipe.name} added to shopping list.'), backgroundColor: kGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
              },
            )),
        ]),
      );

  Widget _legend(Color color, String label) => Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xff7a8a85))),
      ]);

  void _showDetail(BuildContext context, Recipe recipe) => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe, state: widget.state)));
}

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipe, required this.state});
  final Recipe recipe;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final matchPct = state.matchPercent(recipe);
    final missing = state.missingIngredients(recipe);
    final matchColor = matchPct >= 90 ? kGreen : matchPct >= 70 ? kOrange : kRed;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(backgroundColor: kBg, elevation: 0, title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.w800)), leading: const BackButton()),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: kGreenMid, borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: kGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.restaurant, color: kGreen, size: 28)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(recipe.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xff173e37))),
                Text('${recipe.category}  •  ${recipe.difficulty}', style: const TextStyle(color: Color(0xff4a7a6e))),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: matchColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: Text('$matchPct%', style: TextStyle(color: matchColor, fontWeight: FontWeight.w900, fontSize: 18))),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              _infoChip(Icons.timer_outlined, '${recipe.cookingTime} min'),
              const SizedBox(width: 10),
              _infoChip(Icons.bar_chart, recipe.difficulty),
              const SizedBox(width: 10),
              _infoChip(Icons.people_outline, '2–3 servings'),
            ]),
          ]),
        ),
        const SizedBox(height: 20),

        // Nutrition
        if (recipe.nutrition != null) ...[
          const SectionHeader('Nutrition (per serving)'),
          const SizedBox(height: 10),
          Row(children: recipe.nutrition!.entries.map((e) => Expanded(child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [Text(e.value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), Text(e.key, style: const TextStyle(fontSize: 11, color: Color(0xff7a8a85)))]),
          ))).toList()),
          const SizedBox(height: 20),
        ],

        // Ingredients
        const SectionHeader('Ingredients'),
        const SizedBox(height: 10),
        ...recipe.ingredients.map((ing) {
          final have = state.availableIngredients.contains(ing.name);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(have ? Icons.check_circle : Icons.radio_button_unchecked, color: have ? kGreen : kOrange, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(ing.name, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text('${ing.quantity} ${ing.unit}', style: const TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
            ]),
          );
        }),

        if (missing.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kOrangeLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: kOrange.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.shopping_cart_outlined, color: kOrange, size: 18), SizedBox(width: 8), Text('Missing ingredients', style: TextStyle(fontWeight: FontWeight.w800, color: kOrange))]),
              const SizedBox(height: 8),
              Text(missing.join(', '), style: const TextStyle(color: kOrange)),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: FilledButton.icon(
                onPressed: () { state.addMissingToShopping(recipe); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${missing.length} items added to shopping list.'), backgroundColor: kGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))); },
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Add Missing to Shopping List'),
                style: FilledButton.styleFrom(backgroundColor: kOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              )),
            ]),
          ),
        ],
        const SizedBox(height: 20),

        // Instructions
        const SectionHeader('Instructions'),
        const SizedBox(height: 10),
        ...recipe.instructions.asMap().entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 26, height: 26, decoration: BoxDecoration(color: kGreenMid, borderRadius: BorderRadius.circular(8)), child: Center(child: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.w800, color: kGreen, fontSize: 12)))),
            const SizedBox(width: 12),
            Expanded(child: Text(e.value, style: const TextStyle(height: 1.4))),
          ]),
        )),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: kGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: kGreen), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 12, color: kGreen, fontWeight: FontWeight.w600))]),
      );
}
