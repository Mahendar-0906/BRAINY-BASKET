import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';
import 'widgets.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key, required this.state});
  final AppState state;
  @override State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  String _filter = 'All';

  List<ShoppingItem> get _filtered {
    if (_filter == 'Pending') return widget.state.shopping.where((s) => !s.completed).toList();
    if (_filter == 'Purchased') return widget.state.shopping.where((s) => s.completed).toList();
    if (_filter == 'High') return widget.state.shopping.where((s) => s.priority == 'High' && !s.completed).toList();
    return widget.state.shopping;
  }

  int get _pendingCount => widget.state.shopping.where((s) => !s.completed).length;

  @override
  Widget build(BuildContext context) => PageScaffold(
        title: 'Smart Shopping List',
        subtitle: '$_pendingCount items to pick up',
        action: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.cleaning_services_outlined), tooltip: 'Clear completed', onPressed: () { widget.state.clearCompleted(); setState(() {}); }),
          FloatingActionButton.small(onPressed: () => _addManual(context), backgroundColor: kGreen, child: const Icon(Icons.add, color: Colors.white)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Filter tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: ['All', 'Pending', 'High', 'Purchased'].map((f) => GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: _filter == f ? kGreen : kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: _filter == f ? kGreen : const Color(0xffe0e0e0))),
                child: Text(f, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _filter == f ? Colors.white : const Color(0xff7a8a85))),
              ),
            )).toList()),
          ),
          const SizedBox(height: 16),
          // Summary
          if (widget.state.shopping.isNotEmpty) ...[
            Row(children: [
              _badge('${widget.state.shopping.where((s) => !s.completed).length}', 'Pending', kOrange),
              const SizedBox(width: 8),
              _badge('${widget.state.shopping.where((s) => s.priority == 'High' && !s.completed).length}', 'High Priority', kRed),
              const SizedBox(width: 8),
              _badge('${widget.state.shopping.where((s) => s.completed).length}', 'Purchased', kGreen),
            ]),
            const SizedBox(height: 16),
          ],
          if (_filtered.isEmpty)
            _empty()
          else
            ..._filtered.map((item) => ShoppingTile(
              item: item,
              onPurchase: () { widget.state.purchaseItem(item); setState(() {}); },
              onDelete: () { widget.state.deleteShoppingItem(item.id); setState(() {}); },
            )),
          if (widget.state.shopping.any((s) => s.completed)) ...[
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () { widget.state.clearCompleted(); setState(() {}); },
              icon: const Icon(Icons.cleaning_services_outlined, size: 16),
              label: const Text('Clear purchased items'),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xff7a8a85), side: const BorderSide(color: Color(0xffe0e0e0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )),
          ],
        ]),
      );

  Widget _badge(String value, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Text('$value $label', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      );

  Widget _empty() => Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(children: [
          const Icon(Icons.check_circle_outline, size: 48, color: kGreen),
          const SizedBox(height: 12),
          Text(_filter == 'Purchased' ? 'No purchased items yet.' : 'Your shopping list is complete! 🎉', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xff7a8a85))),
        ]),
      );

  void _addManual(BuildContext context) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    String unit = kUnits.first;
    String priority = 'Medium';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: kBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Add Shopping Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, autofocus: true, decoration: InputDecoration(labelText: 'Item name', filled: true, fillColor: kCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Quantity', filled: true, fillColor: kCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(value: unit, onChanged: (v) => setSheet(() => unit = v!), decoration: InputDecoration(labelText: 'Unit', filled: true, fillColor: kCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: kUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList())),
            ]),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: priority, onChanged: (v) => setSheet(() => priority = v!), decoration: InputDecoration(labelText: 'Priority', filled: true, fillColor: kCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: kPriorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList()),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                widget.state.addToShoppingList(nameCtrl.text.trim(), double.tryParse(qtyCtrl.text) ?? 1, unit, 'Manually added', priority);
                setState(() {});
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(backgroundColor: kGreen, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Add to List', style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ),
      )),
    );
  }
}
