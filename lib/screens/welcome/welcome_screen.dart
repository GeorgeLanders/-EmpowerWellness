import 'package:flutter/material.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/glass_card.dart';
import '../../services/storage_service.dart';
import '../../models/user_data.dart';
import '../../widgets/app_nav_shell.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  int _currentPage = 0;
  String _selectedMobility = 'All';
  final List<String> _selectedGoals = [];

  final List<Map<String, dynamic>> _pages = [
    {
      'emoji': '🌱',
      'title': 'Welcome to\nYour World',
      'subtitle': 'Every journey starts with a single step.\nLet\'s build your wellness empire together.',
      'gradient': [AppTheme.primaryPurple, AppTheme.hotCoral],
    },
    {
      'emoji': '🏔️',
      'title': 'Your Miniature\nWorld',
      'subtitle': 'As you progress, your personal diorama\nevolves from a tiny seed to a magnificent empire.',
      'gradient': [AppTheme.neonCyan, AppTheme.warmGold],
    },
    {
      'emoji': '🥒',
      'title': 'Meet Big\nPickle Free',
      'subtitle': 'Your AI coach is here to guide you —\nno shame, no judgment, just real support.',
      'gradient': [AppTheme.roseGold, AppTheme.primaryPurple],
    },
  ];

  final List<String> _goalOptions = [
    'Lose weight', 'Build strength', 'Eat better',
    'Sleep well', 'Feel happier', 'Move more',
  ];

  final List<Map<String, dynamic>> _mobilityOptions = [
    {'label': 'All', 'icon': Icons.accessibility_new_rounded, 'desc': 'I can do most activities', 'color': AppTheme.neonCyan},
    {'label': 'Seated', 'icon': Icons.chair_rounded, 'desc': 'I prefer seated exercises', 'color': AppTheme.roseGold},
    {'label': 'Gentle', 'icon': Icons.spa_rounded, 'desc': 'I need low-impact movement', 'color': AppTheme.mintGreen},
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entryFade = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _entryController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _finishOnboarding() {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Friend';
    StorageService().saveUserData(UserData(
      name: name,
      onboardingComplete: true,
      goals: _selectedGoals,
      mobilityPreference: _selectedMobility,
    ));
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AppNavShell(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _skipOnboarding() {
    StorageService().saveUserData(UserData(onboardingComplete: true));
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AppNavShell(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FadeTransition(
          opacity: _entryFade,
          child: SafeArea(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                ..._pages.map((p) => _buildIntroPage(p)),
                _buildSetupPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroPage(Map<String, dynamic> page) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.space6),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Animated emoji circle
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: page['gradient']),
                boxShadow: [
                  BoxShadow(
                    color: (page['gradient'][0] as Color).withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(page['emoji'], style: const TextStyle(fontSize: 52)),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space6),
          Text(
            page['title'],
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            page['subtitle'],
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
          _buildPageIndicator(),
          const SizedBox(height: AppTheme.space5),
          _buildButtons(showSkip: true),
          const SizedBox(height: AppTheme.space4),
        ],
      ),
    );
  }

  Widget _buildSetupPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.space2),
          const Text('Let\'s Personalize',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.space1),
          const Text('Tell us about yourself. This is your journey.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: AppTheme.space5),

          // Name
          const Text('Your Name',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: AppTheme.space2),
          _buildTextField(_nameController, 'What should we call you?', Icons.person_rounded),
          const SizedBox(height: AppTheme.space5),

          // Mobility
          const Text('Movement Comfort',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: AppTheme.space3),
          ..._mobilityOptions.map((opt) => _buildMobilityOption(opt)),
          const SizedBox(height: AppTheme.space5),

          // Goals
          const Text('Your Goals (pick any)',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: AppTheme.space3),
          Wrap(
            spacing: AppTheme.space2,
            runSpacing: AppTheme.space2,
            children: _goalOptions.map((goal) {
              final selected = _selectedGoals.contains(goal);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selected ? _selectedGoals.remove(goal) : _selectedGoals.add(goal);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primaryPurple.withValues(alpha: 0.2) : AppTheme.glassWhite,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    border: Border.all(
                      color: selected ? AppTheme.primaryPurple : AppTheme.glassBorders,
                    ),
                  ),
                  child: Text(
                    goal,
                    style: TextStyle(
                      color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.space6),
          _buildButtons(showSkip: false),
          const SizedBox(height: AppTheme.space4),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.glassBorders),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppTheme.textMuted),
              prefixIcon: Icon(icon, color: AppTheme.primaryPurple, size: 20),
              filled: true,
              fillColor: AppTheme.deepSpace.withValues(alpha: 0.5),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobilityOption(Map<String, dynamic> opt) {
    final selected = _selectedMobility == opt['label'];
    return GestureDetector(
      onTap: () => setState(() => _selectedMobility = opt['label']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppTheme.space2),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          tint: opt['color'] as Color,
          opacity: selected ? 0.15 : 0.04,
          glowing: selected,
          glowColor: opt['color'] as Color,
          glowIntensity: 0.1,
          child: Row(
            children: [
              Icon(opt['icon'] as IconData, color: selected ? (opt['color'] as Color) : AppTheme.textSecondary, size: 22),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opt['label'] as String,
                        style: TextStyle(
                            color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(opt['desc'] as String,
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: opt['color'] as Color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    final totalPages = _pages.length + 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        final active = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryPurple : AppTheme.textMuted.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          ),
        );
      }),
    );
  }

  Widget _buildButtons({required bool showSkip}) {
    return Row(
      children: [
        if (showSkip)
          Expanded(
            child: TextButton(
              onPressed: _skipOnboarding,
              child: const Text('Skip', style: TextStyle(color: AppTheme.textMuted)),
            ),
          ),
        if (showSkip) const SizedBox(width: AppTheme.space3),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: showSkip ? _nextPage : _finishOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
              elevation: 4,
              shadowColor: AppTheme.primaryPurple.withValues(alpha: 0.4),
            ),
            child: Text(
              showSkip ? 'Continue' : 'Start My Journey ✨',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
