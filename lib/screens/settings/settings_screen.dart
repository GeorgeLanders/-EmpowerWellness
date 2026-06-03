import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import '../../services/storage_service.dart';
import '../../models/user_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  late UserData _userData;

  late bool _movementReminders;
  late bool _dailyCheckIn;
  late bool _soundEffects;
  late bool _voiceGuidance;

  @override
  void initState() {
    super.initState();
    _userData = _storage.loadUserData();
    _movementReminders = _storage.getBool('movement_reminders', defaultValue: true);
    _dailyCheckIn = _storage.getBool('daily_checkin', defaultValue: true);
    _soundEffects = _storage.getBool('sound_effects', defaultValue: true);
    _voiceGuidance = _storage.getBool('voice_guidance', defaultValue: true);
  }

  // ── Name Edit Dialog ──────────────────────────────────────────────

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _userData.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.voidPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          side: BorderSide(color: AppTheme.glassBorders),
        ),
        title: Text('Edit Name', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: AppTheme.textMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.textMuted),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.neonCyan),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              setState(() {
                _userData.name = newName.isEmpty ? 'Friend' : newName;
              });
              _storage.saveUserData(_userData);
              Navigator.pop(ctx);
            },
            child: Text('Save', style: TextStyle(color: AppTheme.neonCyan)),
          ),
        ],
      ),
    );
  }

  // ── Reset Confirmation Dialog ──────────────────────────────────────

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.voidPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          side: BorderSide(color: AppTheme.glassBorders),
        ),
        title: Text('Reset All Data', style: TextStyle(color: AppTheme.hotCoral)),
        content: Text(
          'This will permanently erase all your data and settings. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _storage.eraseAll();
              setState(() {
                _userData = UserData();
                _movementReminders = true;
                _dailyCheckIn = true;
                _soundEffects = true;
                _voiceGuidance = false;
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All data has been reset.'),
                  backgroundColor: AppTheme.hotCoral,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Reset', style: TextStyle(color: AppTheme.hotCoral)),
          ),
        ],
      ),
    );
  }

  // ── Privacy Policy Launcher ───────────────────────────────────────

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse('https://empowerwellness.app/privacy');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Section Header Style ──────────────────────────────────────────

  TextStyle _sectionHeaderStyle() {
    return TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Settings',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          iconTheme: IconThemeData(color: AppTheme.textPrimary),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.space4,
              vertical: AppTheme.space2,
            ),
            children: [
              // ── Section: Profile ──
              Text('PROFILE', style: _sectionHeaderStyle()),
              SizedBox(height: AppTheme.space2),
              GlassCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person_outline, color: AppTheme.textSecondary),
                      title: Text('Name', style: TextStyle(color: AppTheme.textPrimary)),
                      subtitle: Text(
                        _userData.name,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      trailing: Icon(Icons.edit, color: AppTheme.textMuted, size: 18),
                      onTap: _showEditNameDialog,
                    ),
                    Divider(color: AppTheme.glassBorders, height: 1, indent: 56),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.space4,
                        vertical: AppTheme.space3,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.accessibility_new_outlined,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              SizedBox(width: AppTheme.space2),
                              Text(
                                'Mobility Preference',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppTheme.space3),
                          Wrap(
                            spacing: AppTheme.space2,
                            runSpacing: AppTheme.space1,
                            children: ['All', 'Seated Only', 'Low Impact'].map((pref) {
                              final isSelected = _userData.mobilityPreference == pref;
                              return ChoiceChip(
                                label: Text(pref),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _userData.mobilityPreference = pref;
                                  });
                                  _storage.saveUserData(_userData);
                                },
                                selectedColor: AppTheme.neonCyan.withValues(alpha: 0.2),
                                backgroundColor: AppTheme.glassWhite,
                                labelStyle: TextStyle(
                                  color: isSelected ? AppTheme.neonCyan : AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                                side: BorderSide(
                                  color: isSelected ? AppTheme.neonCyan : AppTheme.glassBorders,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.space6),

              // ── Section: Notifications ──
              Text('NOTIFICATIONS', style: _sectionHeaderStyle()),
              SizedBox(height: AppTheme.space2),
              GlassCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _movementReminders,
                      onChanged: (val) {
                        setState(() => _movementReminders = val);
                        _storage.setBool('movement_reminders', val);
                      },
                      title: Text(
                        'Movement Reminders',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      secondary: Icon(
                        Icons.notifications_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      activeThumbColor: AppTheme.neonCyan,
                      activeTrackColor: AppTheme.neonCyan.withValues(alpha: 0.3),
                    ),
                    Divider(color: AppTheme.glassBorders, height: 1, indent: 56),
                    SwitchListTile(
                      value: _dailyCheckIn,
                      onChanged: (val) {
                        setState(() => _dailyCheckIn = val);
                        _storage.setBool('daily_checkin', val);
                      },
                      title: Text(
                        'Daily Check-in',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      secondary: Icon(
                        Icons.today_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      activeThumbColor: AppTheme.neonCyan,
                      activeTrackColor: AppTheme.neonCyan.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.space6),

              // ── Section: Sound ──
              Text('SOUND', style: _sectionHeaderStyle()),
              SizedBox(height: AppTheme.space2),
              GlassCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _soundEffects,
                      onChanged: (val) {
                        setState(() => _soundEffects = val);
                        _storage.setBool('sound_effects', val);
                      },
                      title: Text(
                        'Sound Effects',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      secondary: Icon(
                        Icons.volume_up_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      activeThumbColor: AppTheme.neonCyan,
                      activeTrackColor: AppTheme.neonCyan.withValues(alpha: 0.3),
                    ),
                    Divider(color: AppTheme.glassBorders, height: 1, indent: 56),
                    SwitchListTile(
                      value: _voiceGuidance,
                      onChanged: (val) {
                        setState(() => _voiceGuidance = val);
                        _storage.setBool('voice_guidance', val);
                      },
                      title: Text(
                        'Voice Guidance',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      secondary: Icon(
                        Icons.record_voice_over_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      activeThumbColor: AppTheme.neonCyan,
                      activeTrackColor: AppTheme.neonCyan.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.space6),

              // ── Section: Account ──
              Text('ACCOUNT', style: _sectionHeaderStyle()),
              SizedBox(height: AppTheme.space2),
              GlassCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.login_outlined, color: AppTheme.textSecondary),
                      title: Text('Sign In', style: TextStyle(color: AppTheme.textPrimary)),
                      trailing: Icon(Icons.chevron_right, color: AppTheme.textMuted),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sign in feature coming soon!'),
                            backgroundColor: AppTheme.primaryPurple,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    Divider(color: AppTheme.glassBorders, height: 1, indent: 56),
                    ListTile(
                      leading: Icon(
                        Icons.privacy_tip_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      title: Text(
                        'Privacy Policy',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      trailing: Icon(Icons.open_in_new, color: AppTheme.textMuted, size: 18),
                      onTap: _launchPrivacyPolicy,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.space6),

              // ── Section: Data ──
              Text('DATA', style: _sectionHeaderStyle()),
              SizedBox(height: AppTheme.space2),
              GlassCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.file_download_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      title: Text(
                        'Export Data',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      trailing: Icon(Icons.chevron_right, color: AppTheme.textMuted),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Export feature coming soon!'),
                            backgroundColor: AppTheme.primaryPurple,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    Divider(color: AppTheme.glassBorders, height: 1, indent: 56),
                    ListTile(
                      leading: Icon(
                        Icons.delete_forever_outlined,
                        color: AppTheme.hotCoral,
                      ),
                      title: Text(
                        'Reset All Data',
                        style: TextStyle(color: AppTheme.hotCoral),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppTheme.hotCoral.withValues(alpha: 0.5),
                      ),
                      onTap: _showResetConfirmation,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.space6),

              // ── Section: About ──
              Text('ABOUT', style: _sectionHeaderStyle()),
              SizedBox(height: AppTheme.space2),
              GlassCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppTheme.space5,
                    horizontal: AppTheme.space4,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: AppTheme.primaryPurple,
                        size: 36,
                      ),
                      SizedBox(height: AppTheme.space2),
                      Text(
                        'EmpowerWellness',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppTheme.space1),
                      Text(
                        'Your world is evolving',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: AppTheme.space3),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.space3,
                          vertical: AppTheme.space1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.glassWhite,
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          border: Border.all(color: AppTheme.glassBorders),
                        ),
                        child: Text(
                          'v1.0.0',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppTheme.space8),
            ],
          ),
        ),
      ),
    );
  }
}
