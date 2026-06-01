import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/ai_coach/ai_coach_screen.dart';
import '../screens/movement/movement_library_screen.dart';
import '../screens/sos/sos_screen.dart';

class AppNavShell extends StatefulWidget {
  const AppNavShell({super.key});

  @override
  State<AppNavShell> createState() => _AppNavShellState();
}

class _AppNavShellState extends State<AppNavShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AICoachScreen(),
    const MovementLibraryScreen(),
    const SOSScreen(),
  ];

  final List<String> _titles = ['Home', 'Coach', 'Move', 'SOS'];
  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.psychology_rounded,
    Icons.fitness_center_rounded,
    Icons.healing_rounded,
  ];
  
  final List<Color> _accentColors = [
    AppTheme.warmGold,
    AppTheme.primaryPurple,
    AppTheme.neonCyan,
    AppTheme.hotCoral,
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
          color: AppTheme.deepSpace.withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(color: AppTheme.glassBorders, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: _accentColors[_currentIndex],
          unselectedItemColor: AppTheme.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: List.generate(4, (index) {
            return BottomNavigationBarItem(
              icon: Icon(_icons[index], color: _currentIndex == index ? _accentColors[index] : AppTheme.textSecondary),
              label: _titles[index],
            );
          }),
        ),
      ),
    );
  }
}
