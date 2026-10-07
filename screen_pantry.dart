import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';
import 'widgets.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key, required this.state});
  final AppState state;
  @override State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String _search = '';
  String _filterCategory = 'All';
  String _filterStatus = 'All';

  List<GroceryItem> get _filtered {
    return widget.state.inventory.where((item) {
      final matchSearch = item.name.toLowerCase().contains(_search.toLowerCase()) || item.category.toLowerCase().contains(_search.toLowerCase());
      final matchCat = _filterCategory == 'All' || item.category == _filterCategory;
      final matchStatus = _filterStatus == 'All' || item.status == _filterStatus;
      return matchSearch && matchCat && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) => PageScaffold(
        title: 'Pantry Inventory',
        subtitle: '${widget.state.inventory.length} items tracked in your kitchen',
        action: FloatingActionButton.small(
          onPressed: () => _openForm(context, null),
          backgroundColor: kGreen,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Search
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Color(0xff7a8a85)),
              hintText: 'Search pantry items...',
              filled: true, fillColor: kCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _filterChip('All', _filterStatus == 'All', () => setState(() => _filterStatus = 'All')),
              _filterChip('Available', _filterStatus == 'Available', () => setState(() => _filterStatus = 'Available'), color: kGreen),
              _filterChip('Low Stock', _filterStatus == 'Low Stock', () => setState(() => _filterStatus = 'Low Stock'), color: kOrange),
              _filterChip('Out of Stock', _filterStatus == 'Out of Stock', () => setState(() => _filterStatus = 'Out of Stock'), color: kRed),
              const SizedBox(width: 8),
              ...['All', ...kCategories].map((cat) => _filterChip(cat, _filterCategory == cat, () => setState(() => _filterCategory = cat), isCategory: true)),
            ]),
          ),
          const SizedBox(height: 16),
          // Summary row
          Row(children: [
            _summaryBadge('${widget.state.inventory.length}', 'Total', kGreen),
            const SizedBox(width: 8),
            _summaryBadge('${widget.state.lowStockCount}', 'Low', kOrange),
            const SizedBox(width: 8),
            _summaryBadge('${widget.state.outOfStockCount}', 'Out', kRed),
          ]),
          const SizedBox(height: 16),
          if (_filtered.isEmpty)
            _empty()
          else
            ..._filtered.map((item) => GroceryCard(
              item: item,
              onTap: () => _showDetail(context, item),
              onEdit: () => _openForm(context, item),
              onDelete: () async {
                if (await confirmDelete(context, item.name)) {
                  widget.state.deleteGrocery(item.id);
                }
              },
            )),
        ]),
      );

  Widget _filterChip(String label, bool selected, VoidCallback onTap, {Color? color, bool isCategory = false}) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? (color ?? kGreen) : kCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? (color ?? kGreen) : const Color(0xffe0e0e0)),
          ),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : const Color(0xff7a8a85))),
        ),
      );

  Widget _summaryBadge(String value, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Text('$value $label', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      );

  Widget _empty() => Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(children: [
          const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xffcccccc)),
          const SizedBox(height: 12),
          Text(_search.isNotEmpty ? 'No items match "$_search"' : 'Your pantry is empty. Add your first grocery item.', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xff7a8a85))),
        ]),
      );

  void _openForm(BuildContext context, GroceryItem? item) => Navigator.push(context, MaterialPageRoute(builder: (_) => GroceryForm(initial: item, state: widget.state))).then((_) => setState(() {}));

  void _showDetail(BuildContext context, GroceryItem item) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ItemDetailSheet(item: item, state: widget.state, onEdit: () { Navigator.pop(context); _openForm(context, item); }, onDelete: () async { Navigator.pop(context); if (await confirmDelete(context, item.name)) widget.state.deleteGrocery(item.id); }),
      ).then((_) => setState(() {}));
}

class _ItemDetailSheet extends StatelessWidget {
  const _ItemDetailSheet({required this.item, required this.state, required this.onEdit, required this.onDelete});
  final GroceryItem item;
  final AppState state;
  final VoidCallback onEdit, onDelete;

  List<Map<String, String>> _getConsumptionHistory(GroceryItem item) {
    if (item.name == 'Milk') {
      return [
        {'date': 'Today, 8:30 AM', 'qty': '0.5 L consumed (Breakfast)'},
        {'date': 'Yesterday, 4:15 PM', 'qty': '0.5 L consumed (Tea)'},
      ];
    } else if (item.name == 'Tomato') {
      return [
        {'date': 'Yesterday, 7:30 PM', 'qty': '2.0 pcs consumed (Salad)'},
      ];
    } else if (item.name == 'Onion') {
      return [
        {'date': '2 days ago', 'qty': '0.5 kg consumed (Curry)'},
      ];
    }
    return [
      {'date': '2 days ago', 'qty': '1.0 ${item.unit} consumed (Cooking)'},
    ];
  }

  List<Map<String, String>> _getQuantityChanges(GroceryItem item) {
    if (item.name == 'Milk') {
      return [
        {'date': 'Today, 8:30 AM', 'change': 'Reduced to 0.5 L via IoT Refrigerator Scale'},
        {'date': 'Yesterday, 10:00 AM', 'change': 'Restocked to 1.5 L (Manual Purchase)'},
      ];
    } else if (item.name == 'Tomato') {
      return [
        {'date': 'Yesterday, 10:00 AM', 'change': 'Stock set to 0.0 (Empty)'},
      ];
    }
    return [
      {'date': '3 days ago', 'change': 'Initial stock input: ${item.quantity} ${item.unit}'},
    ];
  }

  List<Map<String, String>> _getShoppingHistory(GroceryItem item) {
    if (item.name == 'Milk') {
      return [
        {'date': 'Yesterday, 10:00 AM', 'detail': '1.0 L purchased at Grocery Mart'},
        {'date': '8 days ago', 'detail': '2.0 L purchased at Grocery Mart'},
      ];
    } else if (item.name == 'Onion') {
      return [
        {'date': '5 days ago', 'detail': '1.0 kg purchased at local farmer\'s market'},
      ];
    }
    return [
      {'date': '5 days ago', 'detail': 'Purchased during weekly grocery shopping'},
    ];
  }

  Widget _buildHistoryList(List<Map<String, String>> logs, IconData icon, Color color) {
    if (logs.isEmpty) {
      return const Center(child: Text('No history recorded yet.', style: TextStyle(color: Color(0xff7a8a85), fontSize: 12)));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: logs.length,
      itemBuilder: (context, i) {
        final log = logs[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  log['qty'] ?? log['change'] ?? log['detail'] ?? '',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                log['date'] ?? '',
                style: const TextStyle(fontSize: 11, color: Color(0xff7a8a85)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(color: kBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: item.statusBg, borderRadius: BorderRadius.circular(16)), child: Icon(Icons.kitchen_outlined, color: item.statusColor, size: 28)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                Text(item.category, style: const TextStyle(color: Color(0xff7a8a85))),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: item.statusBg, borderRadius: BorderRadius.circular(20)), child: Text(item.status, style: TextStyle(color: item.statusColor, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 20),
            _row('Current Quantity', '${item.quantity} ${item.unit}'),
            _row('Minimum Required', '${item.minimumQuantity} ${item.unit}'),
            _row('Storage Location', item.location),
            _row('Purchase Date', '${item.purchaseDate.day}/${item.purchaseDate.month}/${item.purchaseDate.year}'),
            if (item.expiryDate != null) _row('Expiry Date', '${item.expiryDate!.day}/${item.expiryDate!.month}/${item.expiryDate!.year}', color: item.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 5))) ? kOrange : null),
            const SizedBox(height: 20),
            const Text('Activity & History', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xff173e37))),
            const SizedBox(height: 8),
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: kGreen,
                    unselectedLabelColor: Color(0xff7a8a85),
                    indicatorColor: kGreen,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    tabs: [
                      Tab(text: 'Consumption'),
                      Tab(text: 'Changes'),
                      Tab(text: 'Shopping'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildHistoryList(_getConsumptionHistory(item), Icons.remove_circle_outline, kOrange),
                        _buildHistoryList(_getQuantityChanges(item), Icons.sensors, kBlue),
                        _buildHistoryList(_getShoppingHistory(item), Icons.shopping_bag_outlined, kGreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), label: const Text('Edit'), style: OutlinedButton.styleFrom(foregroundColor: kGreen, side: const BorderSide(color: kGreen), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size.fromHeight(46)))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton.icon(onPressed: () { state.addToShoppingList(item.name, item.minimumQuantity > 0 ? item.minimumQuantity : 1, item.unit, 'Manually added', 'Medium'); Navigator.pop(context); }, icon: const Icon(Icons.add_shopping_cart_outlined), label: const Text('Add to List'), style: FilledButton.styleFrom(backgroundColor: kGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size.fromHeight(46)))),
            ]),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: TextButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: kRed), label: const Text('Remove from Pantry', style: TextStyle(color: kRed)))),
          ]),
        ),
      );

  Widget _row(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xff7a8a85), fontSize: 13))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
        ]),
      );
}
