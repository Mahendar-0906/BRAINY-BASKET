import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';
import 'widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.state, required this.onNavigate});
  final AppState state;
  final ValueChanged<int> onNavigate;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          sliver: SliverList(delegate: SliverChildListDelegate([
            // ── Header ──────────────────────────────────────────────────
            Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: kGreenMid, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.shopping_basket_outlined, color: kGreen, size: 22)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Brainy Basket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kGreen)),
                Text('${_greeting()} 👋, ${state.prefs.name}', style: const TextStyle(fontSize: 13, color: Color(0xff7a8a85))),
              ])),
              Stack(children: [
                IconButton(icon: const Icon(Icons.notifications_none_rounded, size: 26), onPressed: () => _showNotifications(context)),
                if (state.unreadNotifications > 0) Positioned(right: 8, top: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: kRed, shape: BoxShape.circle))),
              ]),
            ]),
            const SizedBox(height: 6),
            const Text("Here's what's happening in your kitchen today.", style: TextStyle(fontSize: 13, color: Color(0xff7a8a85))),
            const SizedBox(height: 22),

            // ── KPI Cards ────────────────────────────────────────────────
            const SectionHeader('Kitchen at a glance'),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.55,
              children: [
                StatCard(label: 'Pantry Items', value: '${state.inventory.length}', icon: Icons.inventory_2_outlined, color: kGreen, onTap: () => onNavigate(1)),
                StatCard(label: 'Low Stock', value: '${state.lowStockCount}', icon: Icons.warning_amber_rounded, color: kOrange, onTap: () => onNavigate(1)),
                StatCard(label: 'Out of Stock', value: '${state.outOfStockCount}', icon: Icons.error_outline, color: kRed, onTap: () => onNavigate(1)),
                StatCard(label: 'Recipes Ready', value: '${state.recipes.where((r) => state.matchPercent(r) >= 75).length}', icon: Icons.restaurant_outlined, color: kBlue, onTap: () => onNavigate(2)),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: StatCard(label: 'Shopping Items', value: '${state.shopping.where((s) => !s.completed).length}', icon: Icons.checklist_outlined, color: const Color(0xff7b5ea7), onTap: () => onNavigate(3))),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: 'AI Insights', value: '${state.aiInsights.length}', icon: Icons.auto_awesome, color: kBlue, onTap: () => onNavigate(4))),
            ]),
            const SizedBox(height: 26),

            // ── Demo Mode Banner ─────────────────────────────────────────
            if (state.demoMode) Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xfffff3cd), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xffffc107).withOpacity(0.4))),
              child: Row(children: [
                const Icon(Icons.play_circle_outline, color: Color(0xff856404), size: 18),
                const SizedBox(width: 8),
                const Expanded(child: Text('Demo Mode active — try the IoT panel to simulate events.', style: TextStyle(fontSize: 12, color: Color(0xff856404), fontWeight: FontWeight.w600))),
                TextButton(onPressed: () => onNavigate(5), style: TextButton.styleFrom(foregroundColor: const Color(0xff856404), padding: const EdgeInsets.symmetric(horizontal: 8)), child: const Text('Open', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
              ]),
            ),
            if (state.demoMode) const SizedBox(height: 20),

            // ── Needs Attention ──────────────────────────────────────────
            SectionHeader('Needs attention', trailing: TextButton(onPressed: () => onNavigate(3), child: const Text('View list', style: TextStyle(color: kGreen, fontWeight: FontWeight.w700)))),
            const SizedBox(height: 12),
            if (state.attentionItems.isEmpty)
              _emptyCard('Everything is comfortably stocked! 🎉', kGreenLight)
            else
              ...state.attentionItems.take(4).map((item) => AlertCard(
                item: item,
                onAddToList: () => state.addToShoppingList(item.name, item.minimumQuantity > 0 ? item.minimumQuantity : 1, item.unit, item.status == 'Out of Stock' ? 'Out of stock' : 'Below minimum quantity', item.status == 'Out of Stock' ? 'High' : 'Medium'),
              )),
            const SizedBox(height: 26),

            // ── AI Recipe Suggestions ────────────────────────────────────
            SectionHeader('AI recipe suggestions', trailing: TextButton(onPressed: () => onNavigate(2), child: const Text('See all', style: TextStyle(color: kGreen, fontWeight: FontWeight.w700)))),
            const SizedBox(height: 12),
            ...state.sortedRecipes.take(3).map((recipe) => RecipeCard(
              recipe: recipe,
              matchPct: state.matchPercent(recipe),
              missing: state.missingIngredients(recipe),
              onAddMissing: () => state.addMissingToShopping(recipe),
            )),
            const SizedBox(height: 26),

            // ── AI Kitchen Insights ──────────────────────────────────────
            const SectionHeader('AI kitchen insights'),
            const SizedBox(height: 12),
            ...state.aiInsights.map((insight) => Padding(padding: const EdgeInsets.only(bottom: 10), child: AIInsightCard(text: insight))),
            const SizedBox(height: 26),

            // ── Shopping Preview ─────────────────────────────────────────
            SectionHeader('Shopping list preview', trailing: TextButton(onPressed: () => onNavigate(3), child: const Text('View all', style: TextStyle(color: kGreen, fontWeight: FontWeight.w700)))),
            const SizedBox(height: 12),
            if (state.shopping.where((s) => !s.completed).isEmpty)
              _emptyCard('Shopping list is clear! ✅', kGreenLight)
            else
              ...state.shopping.where((s) => !s.completed).take(4).map((item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: item.priority == 'High' ? kRed : item.priority == 'Medium' ? kOrange : kGreen, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                  Text('${item.quantity} ${item.unit}', style: const TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
                ]),
              )),
            const SizedBox(height: 26),

            // ── Recent Activity ──────────────────────────────────────────
            const SectionHeader('Recent activity'),
            const SizedBox(height: 12),
            ...state.activity.take(5).map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Container(width: 32, height: 32, decoration: BoxDecoration(color: entry.color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(entry.icon, size: 16, color: entry.color)),
                const SizedBox(width: 10),
                Expanded(child: Text(entry.message, style: const TextStyle(fontSize: 13))),
                Text('${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11, color: Color(0xff7a8a85))),
              ]),
            )),
          ])),
        ),
      ]);

  Widget _emptyCard(String text, Color bg) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: kGreen)),
      );

  void _showNotifications(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _NotificationsSheet(state: state),
      );
}

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet({required this.state});
  final AppState state;
  @override State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(color: kBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Row(children: [
            const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const Spacer(),
            TextButton(onPressed: () { widget.state.markAllRead(); setState(() {}); }, child: const Text('Mark all read', style: TextStyle(color: kGreen))),
          ]),
          const SizedBox(height: 12),
          if (widget.state.notifications.isEmpty)
            const Padding(padding: EdgeInsets.all(20), child: Text('No notifications'))
          else
            ...widget.state.notifications.take(8).map((n) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: n.read ? kCard : n.color.withOpacity(0.06), borderRadius: BorderRadius.circular(14), border: n.read ? null : Border.all(color: n.color.withOpacity(0.2))),
              child: Row(children: [
                Icon(n.icon, color: n.color, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(n.body, style: const TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
                ])),
              ]),
            )),
          const SizedBox(height: 8),
        ]),
      );
}
