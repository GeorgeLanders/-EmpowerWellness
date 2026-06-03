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
  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;
  late Animation<double> _celebrationGlow;
  int _currentPage = 0;
  String _selectedMobility = 'All';
  final List<String> _selectedGoals = [];
  String _selectedMood = 'Good';
  String _selectedActivity = 'Just starting out';
  bool _isCelebrating = false;

  final List<Map<String, dynamic>> _pages = [
    {
      'emoji': '🌱',
      'title': 'Welcome to\nYour World',
      'subtitle':
          'Every journey starts with a single step.\nLet\'s build your wellness empire together.',
      'gradient': [AppTheme.primaryPurple, AppTheme.hotCoral],
    },
    {
      'emoji': '🏔️',
      'title': 'Your Miniature\nWorld',
      'subtitle':
          'As you progress, your personal diorama\nevolves from a tiny seed to a magnificent empire.',
      'gradient': [AppTheme.neonCyan, AppTheme.warmGold],
    },
    {
      'emoji': '💎',
      'title': 'Meet\nLumina',
      'subtitle':
          'Your AI coach is here to guide you —\nno shame, no judgment, just real support.',
      'gradient': [AppTheme.roseGold, AppTheme.primaryPurple],
    },
  ];

  final List<Map<String, dynamic>> _featureCards = [
    {
      'label': 'Move',
      'desc': 'Exercises',
      'icon': Icons.directions_run_rounded,
      'color': AppTheme.warmGold,
    },
    {
      'label': 'Coach',
      'desc': 'AI chat',
      'icon': Icons.chat_bubble_rounded,
      'color': AppTheme.neonCyan,
    },
    {
      'label': 'Track',
      'desc': 'Progress',
      'icon': Icons.insights_rounded,
      'color': AppTheme.mintGreen,
    },
    {
      'label': 'SOS',
      'desc': 'Emergency',
      'icon': Icons.emergency_rounded,
      'color': AppTheme.hotCoral,
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

  final List<Map<String, dynamic>> _moodOptions = [
    {'label': 'Great', 'emoji': '😊', 'color': AppTheme.warmGold},
    {'label': 'Good',  'emoji': '🙂', 'color': AppTheme.mintGreen},
    {'label': 'Okay',  'emoji': '😐', 'color': AppTheme.neonCyan},
    {'label': 'Low',   'emoji': '😔', 'color': AppTheme.softLavender},
  ];

  final List<Map<String, dynamic>> _activityOptions = [
    {'label': 'Just starting out',         'color': AppTheme.roseGold},
    {'label': 'I move a few times a week', 'color': AppTheme.neonCyan},
    {'label': "I'm pretty active",         'color': AppTheme.warmGold},
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

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _celebrationScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
    _celebrationGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _entryController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _startCelebrationAndFinish() async {
    if (_isCelebrating) return;
    setState(() => _isCelebrating = true);
    _celebrationController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    _finishOnboarding();
  }

  void _finishOnboarding() {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Friend';
    StorageService().saveUserData(UserData(
      name: name,
      onboardingComplete: true,
      goals: _selectedGoals,
      mobilityPreference: _selectedMobility,
      initialMood: _selectedMood,
      activityLevel: _selectedActivity,
    ));
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AppNavShell(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
        body: Stack(
          fit: StackFit.expand,
          children: [
            FadeTransition(
              opacity: _entryFade,
              child: SafeArea(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    ..._pages.map((p) => _buildIntroPage(p)),
                    _buildFeaturesPage(),
                    _buildSetupPage(),
                  ],
                ),
              ),
            ),
            if (_isCelebrating) _buildCelebrationOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, _) {
        final scale = _celebrationScale.value;
        final glow = _celebrationGlow.value.clamp(0.0, 1.0);
        return IgnorePointer(
          ignoring: true,
          child: Container(
            color: AppTheme.deepSpace.withValues(alpha: 0.85 * glow),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20 * glow, sigmaY: 20 * glow),
              child: Center(
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.neonCyan, AppTheme.warmGold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonCyan.withValues(alpha: 0.5 * glow),
                          blurRadius: 60 * glow,
                          spreadRadius: 20 * glow,
                        ),
                        BoxShadow(
                          color: AppTheme.warmGold.withValues(alpha: 0.4 * glow),
                          blurRadius: 80 * glow,
                          spreadRadius: 30 * glow,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppTheme.deepSpace,
                      size: 110,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
              fontSize: 16,
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

  Widget _buildFeaturesPage() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.space6),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.space2),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.softLavender, AppTheme.neonCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.softLavender.withValues(alpha: 0.35),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Text('✨', style: TextStyle(fontSize: 52)),
            ),
          ),
          const SizedBox(height: AppTheme.space6),
          const Text(
            'Your\nCompanion',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space3),
          const Text(
            'Four gentle tools to support you\nat your own pace.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space5),
          // 2x2 grid of feature cards
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppTheme.space3,
              crossAxisSpacing: AppTheme.space3,
              childAspectRatio: 1.05,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _featureCards.map((f) => _buildFeatureCard(f)).toList(),
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          _buildPageIndicator(),
          const SizedBox(height: AppTheme.space5),
          _buildButtons(showSkip: true),
          const SizedBox(height: AppTheme.space4),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> f) {
    final color = f['color'] as Color;
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space3),
      tint: color,
      opacity: 0.08,
      glowing: true,
      glowColor: color,
      glowIntensity: 0.12,
      radius: AppTheme.radiusLg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.18),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Icon(f['icon'] as IconData, color: color, size: 28),
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            f['label'] as String,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.space1),
          Text(
            f['desc'] as String,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
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
          const Text("Let's Personalize",
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.space1),
          const Text('Tell us about yourself. This is your journey.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          const SizedBox(height: AppTheme.space5),

          // Name
          const Text('Your Name',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: AppTheme.space2),
          _buildTextField(_nameController, 'What should we call you?', Icons.person_rounded),
          const SizedBox(height: AppTheme.space5),

          // Mobility
          const Text('Movement Comfort',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: AppTheme.space3),
          ..._mobilityOptions.map((opt) => _buildMobilityOption(opt)),
          const SizedBox(height: AppTheme.space5),

          // Goals
          const Text('Your Goals (pick any)',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.space6),

          // Mood
          const Text('How are you feeling today?',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: AppTheme.space3),
          Wrap(
            spacing: AppTheme.space2,
            runSpacing: AppTheme.space2,
            children: _moodOptions.map((m) {
              final selected = _selectedMood == m['label'];
              final color = m['color'] as Color;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = m['label'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? color.withValues(alpha: 0.22) : AppTheme.glassWhite,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    border: Border.all(
                      color: selected ? color : AppTheme.glassBorders,
                      width: selected ? 1.5 : 1.0,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m['emoji'] as String, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: AppTheme.space2),
                      Text(
                        m['label'] as String,
                        style: TextStyle(
                          color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                          fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.space6),

          // Activity Level
          const Text('How active are you right now?',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: AppTheme.space3),
          ..._activityOptions.map((opt) => _buildActivityOption(opt)),
          const SizedBox(height: AppTheme.space6),
          _buildButtons(showSkip: false),
          const SizedBox(height: AppTheme.space4),
        ],
      ),
    );
  }

  Widget _buildActivityOption(Map<String, dynamic> opt) {
    final selected = _selectedActivity == opt['label'];
    final color = opt['color'] as Color;
    return GestureDetector(
      onTap: () => setState(() => _selectedActivity = opt['label'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppTheme.space2),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          tint: color,
          opacity: selected ? 0.15 : 0.04,
          glowing: selected,
          glowColor: color,
          glowIntensity: 0.12,
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: selected ? color : AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: Text(
                  opt['label'] as String,
                  style: TextStyle(
                    color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
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
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppTheme.textMuted),
              prefixIcon: Icon(icon, color: AppTheme.primaryPurple, size: 22),
              filled: true,
              fillColor: AppTheme.deepSpace.withValues(alpha: 0.5),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          tint: opt['color'] as Color,
          opacity: selected ? 0.15 : 0.04,
          glowing: selected,
          glowColor: opt['color'] as Color,
          glowIntensity: 0.12,
          child: Row(
            children: [
              Icon(opt['icon'] as IconData, color: selected ? (opt['color'] as Color) : AppTheme.textSecondary, size: 24),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opt['label'] as String,
                        style: TextStyle(
                            color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text(opt['desc'] as String,
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: opt['color'] as Color, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    // 3 intro pages + 1 features page + 1 setup page
    const totalPages = 5;
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
              child: const Text('Skip', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
            ),
          ),
        if (showSkip) const SizedBox(width: AppTheme.space3),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: showSkip
                ? _nextPage
                : (_isCelebrating ? null : _startCelebrationAndFinish),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
              elevation: 4,
              shadowColor: AppTheme.primaryPurple.withValues(alpha: 0.4),
            ),
            child: Text(
              showSkip ? 'Continue' : 'Start My Journey ✨',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
        ),
      ],
    );
  }
}
