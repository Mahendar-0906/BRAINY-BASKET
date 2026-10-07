import 'package:flutter/material.dart';
import 'state.dart';
import 'screen_dashboard.dart';
import 'screen_pantry.dart';
import 'screen_recipes.dart';
import 'screen_shopping.dart';
import 'screen_nutrition.dart';
import 'screen_assistant.dart';
import 'screen_iot.dart';
import 'screen_profile.dart';

void main() => runApp(const BrainyBasketApp());

class BrainyBasketApp extends StatelessWidget {
  const BrainyBasketApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Brainy Basket',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff176b5c), brightness: Brightness.light),
          scaffoldBackgroundColor: const Color(0xfff7faf7),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: Color(0xffe5f2eb),
          ),
          cardTheme: CardTheme(elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xfff7faf7), elevation: 0, centerTitle: false),
        ),
        home: const AppShell(),
      );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _state = AppState();
  int _tab = 0;

  @override
  void dispose() { _state.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _state,
        builder: (context, _) => Scaffold(
          body: SafeArea(child: _buildPage()),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Pantry'),
              NavigationDestination(icon: Icon(Icons.restaurant_menu_outlined), selectedIcon: Icon(Icons.restaurant_menu), label: 'Recipes'),
              NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Shopping'),
              NavigationDestination(icon: Icon(Icons.nutrition_outlined), selectedIcon: Icon(Icons.nutrition), label: 'Nutrition'),
              NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'Assistant'),
              NavigationDestination(icon: Icon(Icons.sensors_outlined), selectedIcon: Icon(Icons.sensors), label: 'IoT'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      );

  Widget _buildPage() => switch (_tab) {
        0 => DashboardScreen(state: _state, onNavigate: (i) => setState(() => _tab = i)),
        1 => PantryScreen(state: _state),
        2 => RecipesScreen(state: _state),
        3 => ShoppingScreen(state: _state),
        4 => NutritionScreen(state: _state),
        5 => AssistantScreen(state: _state),
        6 => IoTScreen(state: _state),
        7 => _ProfileAndSettings(state: _state),
        _ => DashboardScreen(state: _state, onNavigate: (i) => setState(() => _tab = i)),
      };
}

// Combined Profile + Settings tab with inner tab bar
class _ProfileAndSettings extends StatefulWidget {
  const _ProfileAndSettings({required this.state});
  final AppState state;
  @override State<_ProfileAndSettings> createState() => _ProfileAndSettingsState();
}

class _ProfileAndSettingsState extends State<_ProfileAndSettings> with SingleTickerProviderStateMixin {
  late final _tabCtrl = TabController(length: 2, vsync: this);

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabCtrl,
            labelColor: const Color(0xff176b5c),
            unselectedLabelColor: const Color(0xff7a8a85),
            indicatorColor: const Color(0xff176b5c),
            tabs: const [Tab(text: 'Profile'), Tab(text: 'Settings')],
          ),
        ),
        Expanded(child: TabBarView(controller: _tabCtrl, children: [
          ProfileScreen(state: widget.state),
          SettingsScreen(state: widget.state),
        ])),
      ]);
}
