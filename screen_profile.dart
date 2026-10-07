import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';
import 'widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.state});
  final AppState state;
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final prefs = widget.state.prefs;
    return PageScaffold(
      title: 'Profile',
      subtitle: 'Your kitchen preferences',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Avatar card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: kGreenMid, borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            CircleAvatar(radius: 32, backgroundColor: kGreen, child: Text(prefs.name.isNotEmpty ? prefs.name[0].toUpperCase() : 'A', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(prefs.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xff173e37))),
              const Text('Smart Kitchen User', style: TextStyle(color: Color(0xff4a7a6e))),
              const SizedBox(height: 4),
              const Text('Firebase sync ready', style: TextStyle(fontSize: 12, color: Color(0xff4a7a6e))),
            ])),
            IconButton(icon: const Icon(Icons.edit_outlined, color: kGreen), onPressed: () => _editName(context)),
          ]),
        ),
        const SizedBox(height: 20),

        // Stats
        const SectionHeader('Your Kitchen Stats'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _statTile('${widget.state.inventory.length}', 'Pantry Items', kGreen)),
          const SizedBox(width: 10),
          Expanded(child: _statTile('${widget.state.recipes.length}', 'Recipes', kBlue)),
          const SizedBox(width: 10),
          Expanded(child: _statTile('${widget.state.activity.length}', 'Activities', kOrange)),
        ]),
        const SizedBox(height: 20),

        // Preferences
        const SectionHeader('Food Preferences'),
        const SizedBox(height: 12),
        _prefCard('Favorite Categories', prefs.favoriteCategories.join(', '), Icons.favorite_outline, () => _editCategories(context)),
        _prefCard('Preferred Cooking Time', '≤ ${prefs.preferredCookingTime} minutes', Icons.timer_outlined, () => _editCookingTime(context)),
        _prefCard('Preferred Difficulty', prefs.preferredDifficulty, Icons.bar_chart, () => _editDifficulty(context)),
        const SizedBox(height: 20),

        // Firebase info
        const SectionHeader('Data & Sync'),
        const SizedBox(height: 12),
        _infoTile(Icons.cloud_outlined, 'Firebase Sync', 'Ready to connect — data isolated by user ID'),
        _infoTile(Icons.security_outlined, 'Privacy', 'Your data is scoped to your account only'),
        _infoTile(Icons.history, 'Activity Log', '${widget.state.activity.length} events recorded'),
      ]),
    );
  }

  Widget _statTile(String value, String label, Color color) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xff7a8a85))),
        ]),
      );

  Widget _prefCard(String label, String value, IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: kGreen, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(value, style: const TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
            ])),
            const Icon(Icons.chevron_right, color: Color(0xff7a8a85)),
          ]),
        ),
      );

  Widget _infoTile(IconData icon, String title, String subtitle) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(icon, color: kGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
          ])),
        ]),
      );

  void _editName(BuildContext context) {
    final ctrl = TextEditingController(text: widget.state.prefs.name);
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Edit Name'),
      content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(labelText: 'Your name')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () { if (ctrl.text.trim().isNotEmpty) { widget.state.prefs.name = ctrl.text.trim(); setState(() {}); widget.state.notifyListeners(); } Navigator.pop(context); }, style: FilledButton.styleFrom(backgroundColor: kGreen), child: const Text('Save')),
      ],
    ));
  }

  void _editCategories(BuildContext context) {
    final selected = List<String>.from(widget.state.prefs.favoriteCategories);
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setDialog) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Favorite Categories'),
      content: Wrap(spacing: 8, runSpacing: 8, children: kCategories.map((cat) {
        final isSelected = selected.contains(cat);
        return GestureDetector(
          onTap: () => setDialog(() { isSelected ? selected.remove(cat) : selected.add(cat); }),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: isSelected ? kGreen : kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? kGreen : const Color(0xffe0e0e0))), child: Text(cat, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600))),
        );
      }).toList()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () { widget.state.prefs.favoriteCategories = selected; setState(() {}); Navigator.pop(context); }, style: FilledButton.styleFrom(backgroundColor: kGreen), child: const Text('Save')),
      ],
    )));
  }

  void _editCookingTime(BuildContext context) {
    int time = widget.state.prefs.preferredCookingTime;
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setDialog) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Max Cooking Time'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('$time minutes', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kGreen)),
        Slider(value: time.toDouble(), min: 10, max: 90, divisions: 8, activeColor: kGreen, onChanged: (v) => setDialog(() => time = v.round())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () { widget.state.prefs.preferredCookingTime = time; setState(() {}); Navigator.pop(context); }, style: FilledButton.styleFrom(backgroundColor: kGreen), child: const Text('Save')),
      ],
    )));
  }

  void _editDifficulty(BuildContext context) {
    String diff = widget.state.prefs.preferredDifficulty;
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setDialog) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Preferred Difficulty'),
      content: Column(mainAxisSize: MainAxisSize.min, children: ['Easy', 'Medium', 'Hard'].map((d) => RadioListTile<String>(value: d, groupValue: diff, onChanged: (v) => setDialog(() => diff = v!), title: Text(d), activeColor: kGreen)).toList()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () { widget.state.prefs.preferredDifficulty = diff; setState(() {}); Navigator.pop(context); }, style: FilledButton.styleFrom(backgroundColor: kGreen), child: const Text('Save')),
      ],
    )));
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.state});
  final AppState state;
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _lowStockNotif = true;
  bool _recipeNotif = true;
  bool _iotNotif = true;
  bool _shoppingReminder = true;

  @override
  Widget build(BuildContext context) => PageScaffold(
        title: 'Settings',
        subtitle: 'Notifications, data, and preferences',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader('Notifications'),
          const SizedBox(height: 12),
          _toggle('Low Stock Alerts', 'Notify when items run low', _lowStockNotif, (v) => setState(() => _lowStockNotif = v)),
          _toggle('Recipe Recommendations', 'Notify about new recipe matches', _recipeNotif, (v) => setState(() => _recipeNotif = v)),
          _toggle('IoT Events', 'Notify on device updates', _iotNotif, (v) => setState(() => _iotNotif = v)),
          _toggle('Shopping Reminders', 'Remind to complete shopping list', _shoppingReminder, (v) => setState(() => _shoppingReminder = v)),
          const SizedBox(height: 20),
          const SectionHeader('Demo Mode'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.play_circle_outline, color: kGreen, size: 20),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Demo Mode', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text('Enable simulation controls for presentation', style: TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
              ])),
              Switch(value: widget.state.demoMode, onChanged: (v) { widget.state.demoMode = v; widget.state.notifyListeners(); setState(() {}); }, activeColor: kGreen),
            ]),
          ),
          const SizedBox(height: 20),
          const SectionHeader('About'),
          const SizedBox(height: 12),
          _infoRow('App Version', '1.0.0'),
          _infoRow('Architecture', 'Flutter + Python + Firebase'),
          _infoRow('AI Engine', 'ML Recommendation (mock)'),
          _infoRow('IoT Protocol', 'MQTT-ready'),
          _infoRow('Data Isolation', 'Per-user Firebase rules'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kBlueLight, borderRadius: BorderRadius.circular(16)),
            child: const Row(children: [
              Icon(Icons.info_outline, color: kBlue, size: 18),
              SizedBox(width: 10),
              Expanded(child: Text('Brainy Basket is a Smart India Hackathon prototype. Firebase, Python ML, and IoT integrations are ready to connect.', style: TextStyle(fontSize: 12, color: Color(0xff1a3a5c), height: 1.4))),
            ]),
          ),
        ]),
      );

  Widget _toggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
        child: SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)), value: value, onChanged: onChanged, activeColor: kGreen),
      );

  Widget _infoRow(String label, String value) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xff7a8a85)))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      );
}
