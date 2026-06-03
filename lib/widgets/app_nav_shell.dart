import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/ai_coach/ai_coach_screen.dart';
import '../screens/movement/movement_library_screen.dart';
import '../screens/sos/sos_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/progress/progress_dashboard_screen.dart';

class AppNavShell extends StatefulWidget {
  const AppNavShell({super.key});

  @override
  State<AppNavShell> createState() => _AppNavShellState();
}

class _AppNavShellState extends State<AppNavShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AICoachScreen(),
    MovementLibraryScreen(),
    SOSScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home', color: Color(0xFFFFB800)),
    _NavItem(icon: Icons.psychology_rounded, label: 'Coach', color: Color(0xFF8B5CF6)),
    _NavItem(icon: Icons.fitness_center_rounded, label: 'Move', color: Color(0xFF00F5FF)),
    _NavItem(icon: Icons.favorite_rounded, label: 'SOS', color: Color(0xFFFF3366)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.deepSpace.withValues(alpha: 0.9),
          border: Border(
            top: BorderSide(color: AppTheme.glassBorders, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isActive = _currentIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentIndex = index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? item.color.withValues(alpha: 0.15)
                                  : Colors.transparent,
                            ),
                            child: Icon(
                              item.icon,
                              color: isActive ? item.color : AppTheme.textSecondary,
                              size: isActive ? 26 : 22,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isActive ? item.color : AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigate to the Profile screen (accessible from dashboard)
void navigateToProfile(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ProfileScreen()),
  );
}

/// Navigate to the Settings screen
void navigateToSettings(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SettingsScreen()),
  );
}

/// Navigate to the Progress Dashboard screen
void navigateToProgress(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ProgressDashboardScreen()),
  );
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;
  const _NavItem({required this.icon, required this.label, required this.color});
}
