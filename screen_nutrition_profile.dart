import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';

class NutritionProfileScreen extends StatefulWidget {
  const NutritionProfileScreen({super.key, required this.state});

  final AppState state;

  @override
  State<NutritionProfileScreen> createState() => _NutritionProfileScreenState();
}

class _NutritionProfileScreenState extends State<NutritionProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7faf7),
      appBar: AppBar(
        backgroundColor: const Color(0xfff7faf7),
        elevation: 0,
        title: const Text('Household Profiles',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
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
                      '⚠️ Nutrition targets are ESTIMATES calculated using standard formulas. '
                      'They are NOT personalized medical prescriptions. '
                      'Consult a healthcare professional for clinical nutrition advice.',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xff7a5a00),
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),

            // Add new profile button
            ElevatedButton.icon(
              onPressed: _showAddProfileDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Add New Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff176b5c),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 20),

            // Profile list header
            const Text(
              'Household Members',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff176b5c)),
            ),
            const SizedBox(height: 12),

            if (widget.state.householdMembers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No profiles yet.\nAdd your first household member to start tracking nutrition!',
                    style: TextStyle(color: Color(0xff7a8a85)),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...widget.state.householdMembers
                  .map((member) => _buildProfileCard(member)),
          ],
        ),
      ),
    );
  }

  // ── Profile Card ──────────────────────────────────────────────────────────

  Widget _buildProfileCard(HouseholdMember member) {
    final targets = widget.state.getNutritionTargets(member.personId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xffe5f2eb),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Icon(
                        member.gender == 'Female'
                            ? Icons.face_3
                            : member.gender == 'Male'
                                ? Icons.face
                                : Icons.person,
                        color: const Color(0xff176b5c),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${member.gender}  •  ${member.age} yrs  •  ${member.weight} kg  •  ${member.height} cm',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xff7a8a85)),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xff3677b8)),
                      tooltip: 'Edit Profile',
                      onPressed: () => _showEditProfileDialog(member),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, color: Color(0xffc44d4d)),
                      tooltip: 'Delete Profile',
                      onPressed: () => _confirmDelete(member),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Profile details
            _buildDetailRow(
                'Activity Level', _formatActivityLevel(member.activityLevel)),
            _buildDetailRow(
                'Nutrition Goal', _formatNutritionGoal(member.nutritionGoal)),

            // Targets section
            if (targets != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Estimated Daily Targets',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xff7a8a85)),
              ),
              const SizedBox(height: 8),
              _buildTargetRow('Calories',
                  '${targets.calorieTarget.toStringAsFixed(0)} kcal',
                  Icons.local_fire_department, const Color(0xffc77b16)),
              _buildTargetRow('Protein',
                  '${targets.proteinTarget.toStringAsFixed(1)} g',
                  Icons.restaurant, const Color(0xffc44d4d)),
              _buildTargetRow('Carbohydrates',
                  '${targets.carbsTarget.toStringAsFixed(1)} g',
                  Icons.grain, const Color(0xff3677b8)),
              _buildTargetRow('Fat',
                  '${targets.fatTarget.toStringAsFixed(1)} g',
                  Icons.opacity, const Color(0xff7a8a85)),
              _buildTargetRow('Fiber',
                  '${targets.fiberTarget.toStringAsFixed(1)} g',
                  Icons.eco, const Color(0xff25805c)),
              const SizedBox(height: 8),
              const Text(
                '⚠️ Approximate values — not medical prescriptions',
                style: TextStyle(
                    fontSize: 10,
                    color: Color(0xffc77b16),
                    fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xff7a8a85))),
            Text(value,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _buildTargetRow(
      String label, String value, IconData icon, Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xff7a8a85))),
            ),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      );

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatActivityLevel(String level) {
    switch (level) {
      case 'sedentary':
        return 'Sedentary (little/no exercise)';
      case 'light':
        return 'Light (1–3 days/week)';
      case 'moderate':
        return 'Moderate (3–5 days/week)';
      case 'active':
        return 'Active (6–7 days/week)';
      case 'veryActive':
        return 'Very Active (daily + intense)';
      default:
        return level;
    }
  }

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

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showAddProfileDialog() => _showProfileDialog(null);
  void _showEditProfileDialog(HouseholdMember member) =>
      _showProfileDialog(member);

  void _showProfileDialog(HouseholdMember? member) {
    final nameController =
        TextEditingController(text: member?.name ?? '');
    final ageController =
        TextEditingController(text: member?.age.toString() ?? '');
    final heightController =
        TextEditingController(text: member?.height.toString() ?? '');
    final weightController =
        TextEditingController(text: member?.weight.toString() ?? '');

    String gender = member?.gender ?? 'Male';
    String activityLevel = member?.activityLevel ?? 'moderate';
    String nutritionGoal = member?.nutritionGoal ?? 'maintainWeight';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(member == null ? 'Add Profile' : 'Edit Profile',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff176b5c))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),

                // Age + Height row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder(),
                          suffixText: 'yrs',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Height',
                          border: OutlineInputBorder(),
                          suffixText: 'cm',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Weight
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    border: OutlineInputBorder(),
                    suffixText: 'kg',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender
                const Text('Gender',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(
                        value: 'Female', child: Text('Female')),
                    DropdownMenuItem(
                        value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => gender = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Activity Level
                const Text('Activity Level',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: activityLevel,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_run_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'sedentary',
                        child: Text('Sedentary')),
                    DropdownMenuItem(
                        value: 'light', child: Text('Light Activity')),
                    DropdownMenuItem(
                        value: 'moderate', child: Text('Moderate')),
                    DropdownMenuItem(
                        value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                        value: 'veryActive',
                        child: Text('Very Active')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => activityLevel = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Nutrition Goal
                const Text('Nutrition Goal',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: nutritionGoal,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'maintainWeight',
                        child: Text('Maintain Weight')),
                    DropdownMenuItem(
                        value: 'gainWeight',
                        child: Text('Gain Weight')),
                    DropdownMenuItem(
                        value: 'loseWeight',
                        child: Text('Lose Weight')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => nutritionGoal = value);
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Disclaimer
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xfffff3cd),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚠️ This is not medical advice. Targets are estimates based on standard formulas. '
                    'Consult a healthcare professional for personalized nutrition guidance.',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xff7a5a00),
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveProfile(
                context,
                member: member,
                nameController: nameController,
                ageController: ageController,
                heightController: heightController,
                weightController: weightController,
                gender: gender,
                activityLevel: activityLevel,
                nutritionGoal: nutritionGoal,
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff176b5c)),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile(
    BuildContext context, {
    required HouseholdMember? member,
    required TextEditingController nameController,
    required TextEditingController ageController,
    required TextEditingController heightController,
    required TextEditingController weightController,
    required String gender,
    required String activityLevel,
    required String nutritionGoal,
  }) {
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim());
    final height = double.tryParse(heightController.text.trim());
    final weight = double.tryParse(weightController.text.trim());

    if (name.isEmpty || age == null || height == null || weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields correctly'),
          backgroundColor: Color(0xffc44d4d),
        ),
      );
      return;
    }

    if (age < 1 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid age (1–120)'),
          backgroundColor: Color(0xffc44d4d),
        ),
      );
      return;
    }

    if (height < 50 || height > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid height in cm (50–250)'),
          backgroundColor: Color(0xffc44d4d),
        ),
      );
      return;
    }

    if (weight < 5 || weight > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight in kg (5–500)'),
          backgroundColor: Color(0xffc44d4d),
        ),
      );
      return;
    }

    if (member == null) {
      // Add new member
      final newMember = HouseholdMember(
        personId: 'person_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        activityLevel: activityLevel,
        nutritionGoal: nutritionGoal,
      );
      widget.state.householdMembers.add(newMember);
      widget.state.currentPerson ??= newMember;
    } else {
      // Update existing member
      member.name = name;
      member.age = age;
      member.gender = gender;
      member.height = height;
      member.weight = weight;
      member.activityLevel = activityLevel;
      member.nutritionGoal = nutritionGoal;
    }

    widget.state.notifyListeners();
    Navigator.pop(context);
    setState(() {});
  }

  void _confirmDelete(HouseholdMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text(
            'Are you sure you want to delete ${member.name}? '
            'This will also delete all their meal history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.state.householdMembers.remove(member);
              widget.state.mealLogs
                  .removeWhere((m) => m.personId == member.personId);
              if (widget.state.currentPerson?.personId == member.personId) {
                widget.state.currentPerson =
                    widget.state.householdMembers.firstOrNull;
              }
              widget.state.notifyListeners();
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffc44d4d)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
