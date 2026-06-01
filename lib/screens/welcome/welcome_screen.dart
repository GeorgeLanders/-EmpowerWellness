import 'package:flutter/material.dart';
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

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  int _currentPage = 0;
  String _selectedMobility = 'All';
  final List<String> _selectedGoals = [];

  final List<Map<String, dynamic>> _onboardingPages = [
    {
      'emoji': '🌱',
      'title': 'Welcome to Your World',
      'subtitle': 'Every journey starts with a single step. Let\'s build your wellness empire together.',
    },
    {
      'emoji': '🏔️',
      'title': 'Miniature World',
      'subtitle': 'As you progress, your personal diorama evolves from a tiny seed into a magnificent empire.',
    },
    {
      'emoji': '🥒',
      'title': 'Meet Big Pickle Free',
      'subtitle': 'Your AI coach is here to guide you — no shame, no judgment, just real support.',
    },
  ];

  final List<String> _goalOptions = [
    'Lose weight',
    'Build strength',
    'Eat better',
    'Sleep more',
    'Feel happier',
    'Move more',
  ];

  final List<Map<String, dynamic>> _mobilityOptions = [
    {'label': 'All', 'icon': Icons.accessibility_new, 'desc': 'I can do most activities'},
    {'label': 'Seated', 'icon': Icons.chair, 'desc': 'I prefer seated exercises'},
    {'label': 'Gentle', 'icon': Icons.spa, 'desc': 'I need low-impact movement'},
  ];

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _goToSetup();
    }
  }

  void _goToSetup() {
    // Stay on the last page which now shows setup form
    _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void _finishOnboarding() {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Friend';
    final user = UserData(
      name: name,
      onboardingComplete: true,
      goals: _selectedGoals,
      mobilityPreference: _selectedMobility,
    );
    StorageService().saveUserData(user);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppNavShell()),
    );
  }

  void _skipOnboarding() {
    final user = UserData(onboardingComplete: true);
    StorageService().saveUserData(user);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppNavShell()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              // Pages 0-2: Welcome intro slides
              ..._onboardingPages.map((page) => _buildIntroPage(page)),
              // Page 3: Setup form
              _buildSetupPage(),
            ],
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
          const Spacer(),
          Text(page['emoji'], style: const TextStyle(fontSize: 80)),
          const SizedBox(height: AppTheme.space6),
          Text(
            page['title'],
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            page['subtitle'],
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          _buildPageIndicator(),
          const SizedBox(height: AppTheme.space6),
          _buildButtons(showSkip: true),
          const SizedBox(height: AppTheme.space4),
        ],
      ),
    );
  }

  Widget _buildSetupPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.space4),
          const Text(
            'Let\'s Personalize',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          const Text(
            'Tell us about yourself so we can tailor your experience.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: AppTheme.space6),

          // Name input
          const Text('What should we call you?',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: AppTheme.space2),
          _buildTextField(_nameController, 'Your name', Icons.person),
          const SizedBox(height: AppTheme.space5),

          // Mobility preference
          const Text('Movement preference',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: AppTheme.space3),
          ..._mobilityOptions.map((opt) => _buildMobilityOption(opt)),
          const SizedBox(height: AppTheme.space5),

          // Goals
          const Text('Your goals (pick any)',
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primaryPurple.withValues(alpha: 0.3) : AppTheme.glassWhite,
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
    return GlassCard(
      tint: AppTheme.primaryPurple,
      opacity: 0.1,
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          prefixIcon: Icon(icon, color: AppTheme.primaryPurple, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMobilityOption(Map<String, dynamic> opt) {
    final selected = _selectedMobility == opt['label'];
    return GestureDetector(
      onTap: () => setState(() => _selectedMobility = opt['label']),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.space2),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          tint: selected ? AppTheme.neonCyan : AppTheme.glassWhite,
          opacity: selected ? 0.2 : 0.05,
          child: Row(
            children: [
              Icon(opt['icon'], color: selected ? AppTheme.neonCyan : AppTheme.textSecondary, size: 22),
              const SizedBox(width: AppTheme.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opt['label'],
                        style: TextStyle(
                            color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(opt['desc'],
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: AppTheme.neonCyan, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    final totalPages = _onboardingPages.length + 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        final active = i == _currentPage;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
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
        if (showSkip) const SizedBox(width: AppTheme.space4),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: showSkip ? _nextPage : _finishOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
            ),
            child: Text(
              showSkip ? 'Continue' : 'Start My Journey',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
