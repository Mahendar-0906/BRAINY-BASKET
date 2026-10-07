import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';

// ── Colors ────────────────────────────────────────────────────────────────
const kGreen = Color(0xff176b5c);
const kGreenLight = Color(0xffe5f2eb);
const kGreenMid = Color(0xffdcefe5);
const kOrange = Color(0xffc77b16);
const kOrangeLight = Color(0xffffefd5);
const kRed = Color(0xffc44d4d);
const kRedLight = Color(0xffffe1e1);
const kBlue = Color(0xff3677b8);
const kBlueLight = Color(0xffe2effb);
const kBg = Color(0xfff7faf7);
const kCard = Colors.white;

// ── Section Header ────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xff173e37))),
          if (trailing != null) trailing!,
        ],
      );
}

// ── Stat Card ─────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value, required this.icon, required this.color, this.onTap});
  final String label, value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xff7a8a85), fontWeight: FontWeight.w500)),
          ]),
        ),
      );
}

// ── Grocery Card ──────────────────────────────────────────────────────────
class GroceryCard extends StatelessWidget {
  const GroceryCard({super.key, required this.item, this.onTap, this.onEdit, this.onDelete});
  final GroceryItem item;
  final VoidCallback? onTap, onEdit, onDelete;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: item.statusBg, borderRadius: BorderRadius.circular(12)), child: Icon(_categoryIcon(item.category), color: item.statusColor, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 2),
              Text('${item.quantity} ${item.unit}  •  ${item.category}  •  ${item.location}', style: const TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: item.statusBg, borderRadius: BorderRadius.circular(20)), child: Text(item.status, style: TextStyle(color: item.statusColor, fontSize: 11, fontWeight: FontWeight.w700))),
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: Color(0xff7a8a85)),
                onSelected: (v) { if (v == 'edit') onEdit?.call(); if (v == 'delete') onDelete?.call(); },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Edit')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: kRed), SizedBox(width: 8), Text('Delete', style: TextStyle(color: kRed))])),
                ],
              ),
            ],
          ]),
        ),
      );
}

IconData _categoryIcon(String category) => switch (category) {
  'Dairy' => Icons.local_drink_outlined,
  'Eggs' => Icons.egg_outlined,
  'Vegetables' => Icons.eco_outlined,
  'Grains' => Icons.grain,
  'Fruits' => Icons.local_florist_outlined,
  'Meat' => Icons.lunch_dining_outlined,
  'Spices' => Icons.spa_outlined,
  'Beverages' => Icons.local_cafe_outlined,
  'Snacks' => Icons.bakery_dining_outlined,
  _ => Icons.kitchen_outlined,
};

// ── Recipe Card ───────────────────────────────────────────────────────────
class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe, required this.matchPct, required this.missing, this.onTap, this.onAddMissing});
  final Recipe recipe;
  final int matchPct;
  final List<String> missing;
  final VoidCallback? onTap, onAddMissing;

  @override
  Widget build(BuildContext context) {
    final matchColor = matchPct >= 90 ? kGreen : matchPct >= 70 ? kOrange : kRed;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: kGreenMid, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.restaurant, color: kGreen, size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text('${recipe.cookingTime} min  •  ${recipe.difficulty}  •  ${recipe.category}', style: const TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: matchColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)), child: Text('$matchPct%', style: TextStyle(color: matchColor, fontWeight: FontWeight.w800, fontSize: 13))),
          ]),
          if (missing.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: kOrangeLight, borderRadius: BorderRadius.circular(10)), child: Row(children: [
              const Icon(Icons.info_outline, size: 14, color: kOrange),
              const SizedBox(width: 6),
              Expanded(child: Text('Missing: ${missing.join(', ')}', style: const TextStyle(fontSize: 12, color: kOrange, fontWeight: FontWeight.w600))),
              if (onAddMissing != null) GestureDetector(onTap: onAddMissing, child: const Text('Add', style: TextStyle(fontSize: 12, color: kOrange, fontWeight: FontWeight.w800, decoration: TextDecoration.underline))),
            ])),
          ],
        ]),
      ),
    );
  }
}

// ── Shopping Item Tile ────────────────────────────────────────────────────
class ShoppingTile extends StatelessWidget {
  const ShoppingTile({super.key, required this.item, required this.onPurchase, required this.onDelete});
  final ShoppingItem item;
  final VoidCallback onPurchase, onDelete;

  @override
  Widget build(BuildContext context) {
    final priorityColor = item.priority == 'High' ? kRed : item.priority == 'Medium' ? kOrange : kGreen;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: item.completed ? const Color(0xfff5f5f5) : kCard, borderRadius: BorderRadius.circular(16), boxShadow: item.completed ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        GestureDetector(onTap: item.completed ? null : onPurchase, child: Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: item.completed ? kGreen : Colors.transparent, border: Border.all(color: item.completed ? kGreen : const Color(0xffcccccc), width: 2)), child: item.completed ? const Icon(Icons.check, size: 14, color: Colors.white) : null)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, decoration: item.completed ? TextDecoration.lineThrough : null, color: item.completed ? Colors.grey : Colors.black87)),
          Text('${item.quantity} ${item.unit}  •  ${item.reason}', style: const TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: priorityColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Text(item.priority, style: TextStyle(color: priorityColor, fontSize: 11, fontWeight: FontWeight.w700))),
        const SizedBox(width: 4),
        IconButton(icon: const Icon(Icons.close, size: 16, color: Color(0xffaaaaaa)), onPressed: onDelete, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
      ]),
    );
  }
}

// ── AI Insight Card ───────────────────────────────────────────────────────
class AIInsightCard extends StatelessWidget {
  const AIInsightCard({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: kBlueLight, borderRadius: BorderRadius.circular(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.auto_awesome, color: kBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xff1a3a5c), fontWeight: FontWeight.w600, height: 1.4))),
        ]),
      );
}

// ── Alert Card ────────────────────────────────────────────────────────────
class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.item, required this.onAddToList});
  final GroceryItem item;
  final VoidCallback onAddToList;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: item.statusColor.withOpacity(0.3)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: item.statusBg, borderRadius: BorderRadius.circular(10)), child: Icon(item.status == 'Out of Stock' ? Icons.remove_shopping_cart : Icons.priority_high, color: item.statusColor, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            Text('Current: ${item.quantity} ${item.unit}  •  Min: ${item.minimumQuantity} ${item.unit}', style: const TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
          ])),
          TextButton(onPressed: onAddToList, style: TextButton.styleFrom(foregroundColor: kGreen, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)), child: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
        ]),
      );
}

// ── Page Scaffold ─────────────────────────────────────────────────────────
class PageScaffold extends StatelessWidget {
  const PageScaffold({super.key, required this.title, required this.subtitle, required this.child, this.action, this.padding});
  final String title, subtitle;
  final Widget child;
  final Widget? action;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        SliverPadding(
          padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 32),
          sliver: SliverList(delegate: SliverChildListDelegate([
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xff173e37))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xff7a8a85))),
              ])),
              if (action != null) action!,
            ]),
            const SizedBox(height: 24),
            child,
          ])),
        ),
      ]);
}

// ── Confirm Delete Dialog ─────────────────────────────────────────────────
Future<bool> confirmDelete(BuildContext context, String name) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Remove item?'),
      content: Text('Remove "$name" from your pantry?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: kRed), child: const Text('Remove')),
      ],
    ),
  );
  return result ?? false;
}

// ── Grocery Form ──────────────────────────────────────────────────────────
class GroceryForm extends StatefulWidget {
  const GroceryForm({super.key, this.initial, required this.state});
  final GroceryItem? initial;
  final AppState state;

  @override
  State<GroceryForm> createState() => _GroceryFormState();
}

class _GroceryFormState extends State<GroceryForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late final _qty = TextEditingController(text: widget.initial?.quantity.toString() ?? '');
  late final _min = TextEditingController(text: widget.initial?.minimumQuantity.toString() ?? '');
  late String _category = widget.initial?.category ?? kCategories.first;
  late String _unit = widget.initial?.unit ?? kUnits.first;
  late String _location = widget.initial?.location ?? kLocations.first;
  DateTime? _purchaseDate = widget.initial?.purchaseDate;
  DateTime? _expiryDate = widget.initial?.expiryDate;

  @override
  void dispose() { _name.dispose(); _qty.dispose(); _min.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(backgroundColor: kBg, elevation: 0, title: Text(widget.initial == null ? 'Add Grocery' : 'Edit Grocery', style: const TextStyle(fontWeight: FontWeight.w800)), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))),
        body: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            _field('Item Name', _name, hint: 'e.g. Carrot', validator: (v) => v!.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _field('Quantity', _qty, hint: '0', keyboard: TextInputType.number, validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null)),
              const SizedBox(width: 12),
              Expanded(child: _dropdown('Unit', _unit, kUnits, (v) => setState(() => _unit = v!))),
            ]),
            const SizedBox(height: 14),
            _field('Minimum Required', _min, hint: '0', keyboard: TextInputType.number, validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null),
            const SizedBox(height: 14),
            _dropdown('Category', _category, kCategories, (v) => setState(() => _category = v!)),
            const SizedBox(height: 14),
            _dropdown('Storage Location', _location, kLocations, (v) => setState(() => _location = v!)),
            const SizedBox(height: 14),
            _datePicker('Purchase Date', _purchaseDate, (d) => setState(() => _purchaseDate = d)),
            const SizedBox(height: 14),
            _datePicker('Expiry Date', _expiryDate, (d) => setState(() => _expiryDate = d)),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(backgroundColor: kGreen, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(widget.initial == null ? 'Add to Pantry' : 'Save Changes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );

  Widget _field(String label, TextEditingController ctrl, {String? hint, TextInputType? keyboard, String? Function(String?)? validator}) => TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        validator: validator,
        decoration: InputDecoration(labelText: label, hintText: hint, filled: true, fillColor: kCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kGreen, width: 2))),
      );

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, filled: true, fillColor: kCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      );

  Widget _datePicker(String label, DateTime? date, ValueChanged<DateTime?> onPicked) => GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
          onPicked(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xff7a8a85)),
            const SizedBox(width: 10),
            Expanded(child: Text(date == null ? label : '$label: ${date.day}/${date.month}/${date.year}', style: TextStyle(color: date == null ? const Color(0xff7a8a85) : Colors.black87))),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xff7a8a85)),
          ]),
        ),
      );

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final item = widget.state.buildNewItem(
      name: _name.text.trim(),
      category: _category,
      quantity: double.parse(_qty.text),
      unit: _unit,
      minimumQuantity: double.parse(_min.text),
      location: _location,
      purchaseDate: _purchaseDate,
      expiryDate: _expiryDate,
    );
    if (widget.initial == null) {
      widget.state.addGrocery(item);
    } else {
      final updated = GroceryItem(id: widget.initial!.id, name: item.name, category: item.category, quantity: item.quantity, unit: item.unit, minimumQuantity: item.minimumQuantity, location: item.location, purchaseDate: item.purchaseDate, expiryDate: item.expiryDate);
      widget.state.updateGrocery(updated);
    }
    Navigator.pop(context);
  }
}
