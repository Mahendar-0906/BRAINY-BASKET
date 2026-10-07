import 'package:flutter/material.dart';
import 'state.dart';
import 'models.dart';
import 'screen_nutrition_meal_log.dart';
import 'screen_nutrition_profile.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({required this.state, super.key});
  final AppState state;
  @override State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDate = DateTime.now();
    widget.state.currentPerson ??= widget.state.householdMembers.firstOrNull;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7faf7),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogMealDialog,
        backgroundColor: const Color(0xff176b5c),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Meal', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Person selector header
          _buildPersonSelector(),
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xff176b5c),
              unselectedLabelColor: const Color(0xff7a8a85),
              indicatorColor: const Color(0xff176b5c),
              tabs: const [
                Tab(text: 'Daily'),
                Tab(text: 'Weekly'),
                Tab(text: 'Monthly'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDailyTab(),
                _buildWeeklyTab(),
                _buildMonthlyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Person Selector ────────────────────────────────────────────────────────

  Widget _buildPersonSelector() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$_greeting, ${widget.state.currentPerson?.name ?? 'User'} 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff176b5c),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.manage_accounts_outlined,
                      color: Color(0xff176b5c)),
                  tooltip: 'Manage Profiles',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NutritionProfileScreen(state: widget.state),
                    ),
                  ).then((_) => setState(() {})),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.state.householdMembers.isEmpty)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        NutritionProfileScreen(state: widget.state),
                  ),
                ).then((_) => setState(() {})),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xffe5f2eb),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xff176b5c), width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.person_add, color: Color(0xff176b5c), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Tap here to add a household member',
                        style: TextStyle(
                            color: Color(0xff176b5c),
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.state.householdMembers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final member = widget.state.householdMembers[i];
                    final isSelected =
                        widget.state.currentPerson?.personId == member.personId;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => widget.state.currentPerson = member),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xff176b5c)
                              : const Color(0xfff0f0f0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xff7a8a85),
                                size: 16),
                            const SizedBox(width: 6),
                            Text(
                              member.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xff7a8a85),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );

  // ── DAILY TAB ─────────────────────────────────────────────────────────────

  Widget _buildDailyTab() {
    final person = widget.state.currentPerson;
    if (person == null) return _buildNoPersonSelected();

    final daily =
        widget.state.getDailyNutritionSummary(person.personId, _selectedDate);
    final targets = widget.state.getNutritionTargets(person.personId);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date picker row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Nutrition',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 90)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xff176b5c)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Color(0xff176b5c)),
                      const SizedBox(width: 6),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                            color: Color(0xff176b5c),
                            fontWeight: FontWeight.w500,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nutrition goal badge
          if (targets != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xffe5f2eb),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xff176b5c)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag_outlined,
                      size: 16, color: Color(0xff176b5c)),
                  const SizedBox(width: 6),
                  Text(
                    'Goal: ${_formatNutritionGoal(person.nutritionGoal)}  •  Target: ${targets.calorieTarget.toStringAsFixed(0)} kcal/day',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff176b5c),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

          // Nutrition cards
          if (daily != null) ...[
            _buildNutrientCard('Calories',
                daily.totalNutrition.calories.toStringAsFixed(0),
                'kcal', Icons.local_fire_department,
                const Color(0xffc77b16), targets?.calorieTarget ?? 2000),
            const SizedBox(height: 12),
            _buildNutrientCard('Protein',
                daily.totalNutrition.protein.toStringAsFixed(1),
                'g', Icons.restaurant,
                const Color(0xffc44d4d), targets?.proteinTarget ?? 70),
            const SizedBox(height: 12),
            _buildNutrientCard('Carbohydrates',
                daily.totalNutrition.carbohydrates.toStringAsFixed(1),
                'g', Icons.grain,
                const Color(0xff3677b8), targets?.carbsTarget ?? 300),
            const SizedBox(height: 12),
            _buildNutrientCard('Fat',
                daily.totalNutrition.fat.toStringAsFixed(1),
                'g', Icons.opacity,
                const Color(0xff7a8a85), targets?.fatTarget ?? 65),
            const SizedBox(height: 12),
            _buildNutrientCard('Fiber',
                daily.totalNutrition.fiber.toStringAsFixed(1),
                'g', Icons.eco,
                const Color(0xff25805c), targets?.fiberTarget ?? 25),
            const SizedBox(height: 20),

            // Today's summary box
            _buildSummaryBox(daily),
            const SizedBox(height: 20),

            // Meal history
            _buildSectionTitle('Meal History', Icons.history),
            const SizedBox(height: 12),
            ..._buildDetailedMealHistory(person.personId, _selectedDate),
            const SizedBox(height: 20),

            // AI Insights
            _buildSectionTitle('AI Nutrition Insights', Icons.auto_awesome),
            const SizedBox(height: 12),
            ..._generateAIInsights(person, daily, targets).map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAIInsightCard(insight),
              ),
            ),
          ] else
            _buildNoMealsLogged(),

          // Disclaimer
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xfffff3cd),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffc77b16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xffc77b16)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚠️ Approximate nutritional values — Not medical advice. Consult a healthcare professional for personalized guidance.',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff7a5a00),
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPersonSelected() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No profile selected',
                style: TextStyle(fontSize: 18, color: Color(0xff7a8a85))),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        NutritionProfileScreen(state: widget.state)),
              ).then((_) => setState(() {})),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Profile'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff176b5c)),
            ),
          ],
        ),
      );

  Widget _buildNoMealsLogged() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No meals logged for this date',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.grey[500]),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap "Log Meal" below to record what you ate',
                style: TextStyle(fontSize: 13, color: Color(0xff7a8a85)),
              ),
            ],
          ),
        ),
      );

  Widget _buildSectionTitle(String title, IconData icon) => Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xff176b5c)),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xff176b5c))),
        ],
      );

  Widget _buildSummaryBox(NutritionRecord daily) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffe5f2eb),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff176b5c), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.summarize_outlined,
                    color: Color(0xff176b5c), size: 18),
                SizedBox(width: 8),
                Text("Today's Summary",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff176b5c))),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Total Calories',
                '${daily.totalNutrition.calories.toStringAsFixed(0)} kcal'),
            _buildSummaryRow('Total Protein',
                '${daily.totalNutrition.protein.toStringAsFixed(1)} g'),
            _buildSummaryRow('Total Carbs',
                '${daily.totalNutrition.carbohydrates.toStringAsFixed(1)} g'),
            _buildSummaryRow('Total Fat',
                '${daily.totalNutrition.fat.toStringAsFixed(1)} g'),
            _buildSummaryRow('Total Fiber',
                '${daily.totalNutrition.fiber.toStringAsFixed(1)} g'),
          ],
        ),
      );

  // ── WEEKLY TAB ────────────────────────────────────────────────────────────

  Widget _buildWeeklyTab() {
    final person = widget.state.currentPerson;
    if (person == null) return _buildNoPersonSelected();

    final weekly = widget.state.getWeeklyAverageNutrition(person.personId);
    final targets = widget.state.getNutritionTargets(person.personId);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Average',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Average daily intake for the past 7 days',
            style: TextStyle(fontSize: 13, color: Color(0xff7a8a85)),
          ),
          const SizedBox(height: 20),

          if (weekly.values.every((v) => v == 0))
            _buildNoDataCard('No meals logged in the past 7 days.\nStart logging meals to see weekly trends.')
          else ...[
            _buildTrendCard('Calories', weekly['calories'] ?? 0, 'kcal',
                Icons.local_fire_department, const Color(0xffc77b16),
                targets?.calorieTarget ?? 2000),
            const SizedBox(height: 12),
            _buildTrendCard('Protein', weekly['protein'] ?? 0, 'g',
                Icons.restaurant, const Color(0xffc44d4d),
                targets?.proteinTarget ?? 70),
            const SizedBox(height: 12),
            _buildTrendCard('Carbohydrates', weekly['carbohydrates'] ?? 0, 'g',
                Icons.grain, const Color(0xff3677b8),
                targets?.carbsTarget ?? 300),
            const SizedBox(height: 12),
            _buildTrendCard('Fat', weekly['fat'] ?? 0, 'g',
                Icons.opacity, const Color(0xff7a8a85),
                targets?.fatTarget ?? 65),
            const SizedBox(height: 12),
            _buildTrendCard('Fiber', weekly['fiber'] ?? 0, 'g',
                Icons.eco, const Color(0xff25805c),
                targets?.fiberTarget ?? 25),
            const SizedBox(height: 20),

            // Trend legend
            _buildTrendLegend(),
          ],

          const SizedBox(height: 16),
          _buildDisclaimerBox(),
        ],
      ),
    );
  }

  Widget _buildTrendCard(String label, double average, String unit,
      IconData icon, Color color, double target) {
    final pct = target > 0 ? (average / target * 100).clamp(0, 150) : 0;
    final trend = pct > 105
        ? '↑ Above target'
        : pct >= 85
            ? '✓ On track'
            : '↓ Below target';
    final trendColor = pct > 105
        ? const Color(0xffc77b16)
        : pct >= 85
            ? const Color(0xff25805c)
            : const Color(0xffc44d4d);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              color: Color(0xff7a8a85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      Text(
                        '${average.toStringAsFixed(label == 'Calories' ? 0 : 1)} $unit / day avg',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1a1a1a)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: trendColor, width: 1),
                ),
                child: Text(trend,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: trendColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0, 1).toDouble(),
              minHeight: 7,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Target: ${target.toStringAsFixed(0)} $unit/day  •  ${pct.toStringAsFixed(0)}% of target',
            style: const TextStyle(fontSize: 11, color: Color(0xffa0a0a0)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendLegend() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trend Legend',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(height: 8),
            Row(children: [
              Text('↑ Above target  ', style: TextStyle(color: Color(0xffc77b16), fontSize: 12)),
              Text('✓ On track  ', style: TextStyle(color: Color(0xff25805c), fontSize: 12)),
              Text('↓ Below target', style: TextStyle(color: Color(0xffc44d4d), fontSize: 12)),
            ]),
          ],
        ),
      );

  // ── MONTHLY TAB ───────────────────────────────────────────────────────────

  Widget _buildMonthlyTab() {
    final person = widget.state.currentPerson;
    if (person == null) return _buildNoPersonSelected();

    final monthly = widget.state.getMonthlyNutritionSummary(person.personId);
    final targets = widget.state.getNutritionTargets(person.personId);
    final dayCount = (monthly['dayCount'] as int?) ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Summary',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            dayCount > 0
                ? 'Based on $dayCount days of logged data this month'
                : 'No data logged this month yet',
            style: const TextStyle(fontSize: 13, color: Color(0xff7a8a85)),
          ),
          const SizedBox(height: 20),

          if (dayCount == 0)
            _buildNoDataCard('No meals have been logged this month.\nStart logging meals to see monthly summaries.')
          else ...[
            // Average daily stats
            _buildSectionTitle('Daily Averages', Icons.bar_chart),
            const SizedBox(height: 12),
            _buildMonthlyStatRow('Avg. Calories',
                '${(monthly['averageCalories'] as double).toStringAsFixed(0)} kcal',
                Icons.local_fire_department, const Color(0xffc77b16),
                targets?.calorieTarget),
            _buildMonthlyStatRow('Avg. Protein',
                '${(monthly['averageProtein'] as double).toStringAsFixed(1)} g',
                Icons.restaurant, const Color(0xffc44d4d),
                targets?.proteinTarget),
            _buildMonthlyStatRow('Avg. Carbs',
                '${(monthly['averageCarbs'] as double).toStringAsFixed(1)} g',
                Icons.grain, const Color(0xff3677b8),
                targets?.carbsTarget),
            _buildMonthlyStatRow('Avg. Fat',
                '${(monthly['averageFat'] as double).toStringAsFixed(1)} g',
                Icons.opacity, const Color(0xff7a8a85),
                targets?.fatTarget),
            _buildMonthlyStatRow('Avg. Fiber',
                '${(monthly['averageFiber'] as double).toStringAsFixed(1)} g',
                Icons.eco, const Color(0xff25805c),
                targets?.fiberTarget),

            const SizedBox(height: 20),
            _buildSectionTitle('Monthly Totals', Icons.summarize_outlined),
            const SizedBox(height: 12),
            _buildMonthlyTotalsCard(monthly),
          ],

          const SizedBox(height: 16),
          _buildDisclaimerBox(),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatRow(
      String label, String value, IconData icon, Color color, double? target) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xff7a8a85))),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color)),
          if (target != null) ...[
            const SizedBox(width: 8),
            Text(
              '/ ${target.toStringAsFixed(0)} target',
              style: const TextStyle(
                  fontSize: 11, color: Color(0xffa0a0a0)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthlyTotalsCard(Map<String, dynamic> monthly) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffe5f2eb),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff176b5c), width: 1),
        ),
        child: Column(
          children: [
            _buildSummaryRow('Total Calories',
                '${(monthly['totalCalories'] as double).toStringAsFixed(0)} kcal'),
            _buildSummaryRow('Total Protein',
                '${(monthly['totalProtein'] as double).toStringAsFixed(1)} g'),
            _buildSummaryRow('Total Carbs',
                '${(monthly['totalCarbs'] as double).toStringAsFixed(1)} g'),
            _buildSummaryRow('Total Fat',
                '${(monthly['totalFat'] as double).toStringAsFixed(1)} g'),
            _buildSummaryRow('Total Fiber',
                '${(monthly['totalFiber'] as double).toStringAsFixed(1)} g'),
            const Divider(height: 16),
            _buildSummaryRow('Days Tracked',
                '${monthly['dayCount']} days'),
          ],
        ),
      );

  Widget _buildNoDataCard(String message) => Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart, size: 56, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                    color: Color(0xff7a8a85), fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _buildDisclaimerBox() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xfffff3cd),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffc77b16)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 16, color: Color(0xffc77b16)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '⚠️ Approximate nutritional values — Not medical advice. Consult a healthcare professional for personalized nutrition guidance.',
                style: TextStyle(
                    fontSize: 11,
                    color: Color(0xff7a5a00),
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      );

  // ── Shared Widgets ─────────────────────────────────────────────────────────

  Widget _buildSummaryRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xff7a8a85))),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      );

  Widget _buildNutrientCard(String label, String rawValue, String unit,
      IconData icon, Color color, double target) {
    final actual = double.tryParse(rawValue) ?? 0;
    final percentage = target > 0 ? (actual / target * 100).clamp(0, 150) : 0;
    final displayValue = '$rawValue $unit';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              color: Color(0xff7a8a85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      Text(displayValue,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1a1a1a))),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  Text('of ${target.toStringAsFixed(0)} $unit',
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xffa0a0a0))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0, 1).toDouble(),
              minHeight: 7,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientBadge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: color)),
      );

  List<Widget> _buildDetailedMealHistory(String personId, DateTime date) {
    final meals = widget.state.getMealsForPerson(personId, date);

    if (meals.isEmpty) {
      return [
        const Center(
          child: Text(
            'No meals logged for this date',
            style: TextStyle(color: Color(0xff7a8a85)),
          ),
        ),
      ];
    }

    final mealGroups = <String, List<MealLog>>{};
    for (final meal in meals) {
      mealGroups.putIfAbsent(meal.mealType, () => []).add(meal);
    }

    const mealOrder = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    final widgets = <Widget>[];

    for (final mealType in mealOrder) {
      final typeMeals = mealGroups[mealType] ?? [];
      if (typeMeals.isEmpty) continue;

      for (final meal in typeMeals) {
        final nutrition = meal.calculateTotalNutrition();
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _getMealIcon(meal.mealType),
                        const SizedBox(width: 8),
                        Text(meal.mealType,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Text(
                      '${nutrition.calories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xffc77b16),
                          fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...meal.items.map((item) => Padding(
                      padding: const EdgeInsets.only(left: 28, bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '• ${item.name}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xff7a8a85)),
                            ),
                          ),
                          Text(
                            '${item.quantity.toStringAsFixed(0)} ${item.unit}',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xff7a8a85)),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildNutrientBadge(
                        '${nutrition.protein.toStringAsFixed(1)}g protein',
                        const Color(0xff3677b8)),
                    _buildNutrientBadge(
                        '${nutrition.carbohydrates.toStringAsFixed(1)}g carbs',
                        const Color(0xff25805c)),
                    _buildNutrientBadge(
                        '${nutrition.fat.toStringAsFixed(1)}g fat',
                        const Color(0xff7a8a85)),
                    _buildNutrientBadge(
                        '${nutrition.fiber.toStringAsFixed(1)}g fiber',
                        const Color(0xff176b5c)),
                  ],
                ),
                if (meal.notes != null && meal.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xfff0f0f0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      meal.notes!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xff7a8a85),
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }
    return widgets;
  }

  Icon _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return const Icon(Icons.wb_sunny, size: 18, color: Color(0xffc77b16));
      case 'Lunch':
        return const Icon(Icons.restaurant, size: 18, color: Color(0xff176b5c));
      case 'Dinner':
        return const Icon(Icons.nights_stay, size: 18, color: Color(0xff3677b8));
      case 'Snack':
        return const Icon(Icons.cookie, size: 18, color: Color(0xffc44d4d));
      default:
        return const Icon(Icons.restaurant_menu,
            size: 18, color: Color(0xff7a8a85));
    }
  }

  // ── AI Insights ───────────────────────────────────────────────────────────

  List<_AIInsight> _generateAIInsights(HouseholdMember person,
      NutritionRecord? daily, NutritionTarget? targets) {
    final insights = <_AIInsight>[];
    if (daily == null || targets == null) return insights;

    final proteinPct = daily.totalNutrition.protein / targets.proteinTarget * 100;
    final caloriePct = daily.totalNutrition.calories / targets.calorieTarget * 100;
    final fiberPct = daily.totalNutrition.fiber / targets.fiberTarget * 100;
    final carbsPct = daily.totalNutrition.carbohydrates / targets.carbsTarget * 100;

    // Protein insight
    if (proteinPct < 60) {
      insights.add(_AIInsight(
        icon: Icons.restaurant,
        title: 'Low Protein Intake',
        message:
            "Today's protein intake is ${proteinPct.toStringAsFixed(0)}% of your target. "
            "Consider adding pulses like Toor Dal, Moong Dal, or Chickpeas to your next meal.",
        color: const Color(0xffc77b16),
      ));
    } else if (proteinPct >= 100) {
      insights.add(_AIInsight(
        icon: Icons.check_circle,
        title: 'Protein Target Met! 🎉',
        message:
            "Excellent! You've reached your protein target today. Pulses and legumes contributed well to your nutrition.",
        color: const Color(0xff25805c),
      ));
    }

    // Calorie insight
    if (caloriePct < 50) {
      insights.add(_AIInsight(
        icon: Icons.local_fire_department,
        title: 'Calorie Intake Below Target',
        message:
            "Your calorie intake is at ${caloriePct.toStringAsFixed(0)}% of your daily target. "
            "Consider adding nutrient-dense foods like whole grains, peanuts, or legumes.",
        color: const Color(0xffc44d4d),
      ));
    } else if (caloriePct > 115) {
      insights.add(_AIInsight(
        icon: Icons.warning_amber,
        title: 'Calories Above Target',
        message:
            "You are at ${caloriePct.toStringAsFixed(0)}% of your calorie target. "
            "Consider lighter options for remaining meals.",
        color: const Color(0xffc77b16),
      ));
    }

    // Fiber insight
    if (fiberPct < 50) {
      insights.add(_AIInsight(
        icon: Icons.eco,
        title: 'Increase Fiber Intake',
        message:
            "Fiber supports healthy digestion. Add whole grains like Ragi or Wheat, "
            "and include more pulses in your meals.",
        color: const Color(0xffc77b16),
      ));
    }

    // Carbs insight
    if (carbsPct > 120) {
      insights.add(_AIInsight(
        icon: Icons.grain,
        title: 'High Carbohydrate Intake',
        message:
            "Your carbohydrate intake is ${carbsPct.toStringAsFixed(0)}% of target. "
            "Balance with protein-rich and fibrous foods for your remaining meals.",
        color: const Color(0xff3677b8),
      ));
    }

    // Pantry-based suggestions
    final availablePulses = widget.state.inventory
        .where((i) =>
            i.quantity > 0 &&
            ['Pulses', 'Beans / Legumes', 'Lentils'].contains(i.category))
        .map((i) => i.name)
        .toList();

    if (availablePulses.isNotEmpty && proteinPct < 80) {
      insights.add(_AIInsight(
        icon: Icons.inventory_2,
        title: 'Use Your Pantry',
        message:
            "You have ${availablePulses.join(', ')} available in your pantry. "
            "These are excellent protein sources for your next meal.",
        color: const Color(0xff3677b8),
      ));
    }

    // Recipe suggestion from pantry
    final matchingRecipes = widget.state.recipes
        .where((r) =>
            r.ingredients.any((i) =>
                widget.state.availableIngredients.contains(i.name)))
        .take(2)
        .toList();

    if (matchingRecipes.isNotEmpty) {
      final recipeNames = matchingRecipes.map((r) => r.name).join(' or ');
      insights.add(_AIInsight(
        icon: Icons.auto_awesome,
        title: 'Recipe Suggestion',
        message:
            "Based on your pantry, you can make $recipeNames. "
            "These use ingredients already available at home.",
        color: const Color(0xff176b5c),
      ));
    }

    if (insights.isEmpty) {
      insights.add(_AIInsight(
        icon: Icons.check_circle_outline,
        title: "You're on Track Today! 🌟",
        message:
            "Your nutrition for today looks balanced. Keep maintaining good food habits.",
        color: const Color(0xff25805c),
      ));
    }

    return insights;
  }

  Widget _buildAIInsightCard(_AIInsight insight) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: insight.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: insight.color, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(insight.icon, color: insight.color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insight.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: insight.color,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(insight.message,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xff1a1a1a))),
                ],
              ),
            ),
          ],
        ),
      );

  // ── Log Meal Dialog ────────────────────────────────────────────────────────

  void _showLogMealDialog() {
    if (widget.state.currentPerson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or add a household member first.'),
          backgroundColor: Color(0xffc77b16),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => LogMealDialog(
        state: widget.state,
        personId: widget.state.currentPerson!.personId,
        onMealLogged: () {
          setState(() {});
          Navigator.pop(context);
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatNutritionGoal(String goal) {
    switch (goal) {
      case 'maintainWeight':
        return 'Maintain Weight';
      case 'gainWeight':
        return 'Gain Weight';
      case 'loseWeight':
        return 'Lose Weight';
      default:
        return goal;
    }
  }
}

// ── Data class for AI Insights ─────────────────────────────────────────────

class _AIInsight {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  _AIInsight({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });
}
