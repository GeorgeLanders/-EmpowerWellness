import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import '../../services/storage_service.dart';
import '../../models/meal_entry.dart';

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  State<MealLogScreen> createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  final StorageService _storage = StorageService();
  late List<MealEntry> _meals;
  late int _calorieGoal;
  String _filterDate = _today();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final user = _storage.loadUserData();
    _meals = List<MealEntry>.from(user.meals);
    _meals.sort((a, b) => b.id.compareTo(a.id));
    _calorieGoal = user.dailyCalorieGoal;
  }

  static String _today() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  List<MealEntry> get _visibleMeals =>
      _meals.where((m) => m.date == _filterDate).toList();

  int get _todayCalories =>
      _visibleMeals.fold<int>(0, (sum, m) => sum + m.calories);

  double get _progress {
    if (_calorieGoal == 0) return 0;
    return (_todayCalories / _calorieGoal).clamp(0.0, 1.0);
  }

  Future<void> _addMeal() async {
    final result = await showModalBottomSheet<MealEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMealSheet(),
    );
    if (result == null) return;

    final user = _storage.loadUserData();
    final updated = List<MealEntry>.from(user.meals)..add(result);
    user.meals = updated;
    _storage.saveUserData(user);

    setState(_refresh);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '\ud83c\udf71 Logged ${result.name} \u2014 ${result.calories} cal',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.voidPurple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteMeal(MealEntry meal) async {
    final user = _storage.loadUserData();
    user.meals = user.meals.where((m) => m.id != meal.id).toList();
    _storage.saveUserData(user);
    setState(_refresh);
  }

  Color _mealTypeColor(String type) {
    switch (type) {
      case 'Breakfast':
        return AppTheme.warmGold;
      case 'Lunch':
        return AppTheme.mintGreen;
      case 'Dinner':
        return AppTheme.hotCoral;
      case 'Snack':
        return AppTheme.softLavender;
      default:
        return AppTheme.neonCyan;
    }
  }

  IconData _mealTypeIcon(String type) {
    switch (type) {
      case 'Breakfast':
        return Icons.wb_sunny_rounded;
      case 'Lunch':
        return Icons.lunch_dining_rounded;
      case 'Dinner':
        return Icons.dinner_dining_rounded;
      case 'Snack':
        return Icons.cookie_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'My Meals',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addMeal,
          backgroundColor: AppTheme.warmGold,
          foregroundColor: AppTheme.deepSpace,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Log a meal', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space3, AppTheme.space5, 100),
          children: [
            _buildCalorieCard(),
            const SizedBox(height: AppTheme.space4),
            _buildDateFilter(),
            const SizedBox(height: AppTheme.space3),
            if (_visibleMeals.isEmpty)
              _buildEmptyState()
            else
              ..._visibleMeals.map((m) => _buildMealCard(m)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard() {
    final isOver = _todayCalories > _calorieGoal;
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Today\'s calories',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                Text('$_todayCalories / $_calorieGoal',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: AppTheme.space3),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 12,
                backgroundColor: AppTheme.glassBorders,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOver ? AppTheme.hotCoral : AppTheme.warmGold,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.space2),
            Text(
              isOver
                  ? 'You are ${_todayCalories - _calorieGoal} cal over your goal. Tomorrow is a fresh start ✨'
                  : '$_calorieGoal-$_todayCalories cal left for today',
              style: TextStyle(
                color: isOver ? AppTheme.hotCoral : AppTheme.neonCyan,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return GlassCard(
      opacity: 0.2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
              onPressed: () {
                setState(() {
                  final d = DateTime.parse(_filterDate).subtract(const Duration(days: 1));
                  _filterDate = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                });
              },
            ),
            Column(
              children: [
                Text(
                  _filterDate == _today() ? 'Today' : _filterDate,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_filterDate != _today())
                  TextButton(
                    onPressed: () => setState(() => _filterDate = _today()),
                    child: const Text('Jump to today',
                        style: TextStyle(color: AppTheme.neonCyan, fontSize: 11)),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
              onPressed: _filterDate == _today()
                  ? null
                  : () {
                      setState(() {
                        final d = DateTime.parse(_filterDate).add(const Duration(days: 1));
                        _filterDate = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                      });
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(MealEntry meal) {
    final color = _mealTypeColor(meal.mealType);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space3),
      child: Dismissible(
        key: ValueKey(meal.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppTheme.hotCoral.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_rounded, color: AppTheme.hotCoral, size: 28),
        ),
        onDismissed: (_) => _deleteMeal(meal),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space4),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.2),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(_mealTypeIcon(meal.mealType), color: color, size: 24),
                ),
                const SizedBox(width: AppTheme.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meal.name,
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('${meal.mealType} \u2022 ${meal.time}',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                Text('${meal.calories} cal',
                    style: TextStyle(
                        color: color, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.warmGold.withValues(alpha: 0.15),
              border: Border.all(color: AppTheme.warmGold.withValues(alpha: 0.5), width: 2),
            ),
            child: const Icon(Icons.restaurant_menu_rounded, color: AppTheme.warmGold, size: 48),
          ),
          const SizedBox(height: AppTheme.space4),
          const Text('No meals logged yet',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.space2),
          const Text('Tap the gold button below to log your first meal',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet();

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  String _type = 'Breakfast';

  static String _today() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final cal = int.tryParse(_calCtrl.text.trim()) ?? 0;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a name for the meal')),
      );
      return;
    }
    final now = DateTime.now();
    final entry = MealEntry(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      mealType: _type,
      calories: cal,
      time: _formatTime(now),
      date: _today(),
    );
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: GlassCard(
        opacity: 0.35,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Log a meal',
                  style: TextStyle(
                      color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppTheme.space4),
              const Text('What did you have?',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: AppTheme.space2),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. Oatmeal with berries',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.glassWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppTheme.space3),
              const Text('Calories',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: AppTheme.space2),
              TextField(
                controller: _calCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 350',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.glassWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: AppTheme.space4),
              const Text('Meal type',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: AppTheme.space2),
              Wrap(
                spacing: 8,
                children: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                    .map((t) => ChoiceChip(
                          label: Text(t),
                          selected: _type == t,
                          onSelected: (_) => setState(() => _type = t),
                          selectedColor: AppTheme.warmGold,
                          labelStyle: TextStyle(
                            color: _type == t ? AppTheme.deepSpace : AppTheme.textPrimary,
                            fontWeight: _type == t ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: AppTheme.glassWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                            side: const BorderSide(color: AppTheme.glassBorders),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppTheme.space5),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warmGold,
                    foregroundColor: AppTheme.deepSpace,
                    elevation: 8,
                    shadowColor: AppTheme.warmGold.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                  ),
                  child: const Text('Save meal',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: AppTheme.space2),
            ],
          ),
        ),
      ),
    );
  }
}
