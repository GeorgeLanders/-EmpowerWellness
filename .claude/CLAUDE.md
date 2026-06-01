# EmpowerWellness — Claude Code Project Brief

## Project

Ultra-premium Flutter wellness app for overweight men + women. Glassmorphic, 3D-animated, "shiny" design — NOT flat or minimal.

## Tech Stack

- Flutter (Dart)
- SharedPreferences + SQLite (StorageService)
- OpenRouter AI backend
- 4px grid spacing system

## Design System

- **Background**: Deep space void `#0B051A`
- **Primary**: Vivid purple `#8B5CF6`
- **Accent**: Neon cyan `#00F5FF`, Hot coral `#FF3366`, Warm gold `#FFB800`, Rose gold `#E8A87C`
- **Glass**: White 10% opacity with BackdropFilter blur sigma 12
- **Radius**: Sm 6, Md 8, Lg 16, Xl 24, Pill 100
- **No Inter font actually bundled** — theme sets `fontFamily: 'Inter'` but pubspec has no fonts config

## Architecture

- No state management library (no Provider/Riverpod/Bloc)
- Singletons: `StorageService()`, `AICoachService()`
- `main.dart` → `EmpowerWellnessApp` → `MaterialApp` → `AppNavShell()`
- No onboarding flow in current code (was removed)

## Files

```
lib/
├── main.dart                    # Entry point
├── theme/app_theme.dart         # Design tokens (colors, spacing, radius)
├── widgets/
│   ├── animated_background.dart # 3D nebula animation
│   ├── app_nav_shell.dart       # Bottom nav + screen switching
│   └── glass_card.dart          # Reusable frosted glass widget
├── screens/
│   ├── home/dashboard_screen.dart
│   ├── ai_coach/ai_coach_screen.dart
│   ├── movement/movement_library_screen.dart
│   └── sos/sos_screen.dart
├── services/
│   ├── storage_service.dart     # SQLite + SharedPreferences
│   └── diorama_controller.dart  # Miniature World gamification
└── models/
    └── user_data.dart           # Central data model
```

## AI Coach

- **Persona**: "Big Pickle Free" — shame-free, supportive
- **Backend**: OpenRouter via Render server
- **Model**: `google/gemma-4-31b-it:free` (not DeepSeek)

## Miniature World Gamification

Progress evolves through stages: Seed → Sprout → Tree → Garden → Empire
Controlled by `diorama_controller.dart`.

## Conventions

- `GlassCard` wraps all content containers
- `AnimatedBackground` wraps the full app
- Save user data via `StorageService().saveUserData(user)`
- All colors come from `AppTheme` constants — no hardcoded hex in widgets

## Known Issues

- Streak increments on every video watched (should be daily)
- Duplicate water tracker (Dashboard + NourishScreen)
- Sleep hours displayed but no UI to set it
- Some dead UserData fields (goals, mobilityPreference, showCalories)
- No video assets bundled — 17 personal clips exist but not in assets/
- Font family 'Inter' used but not bundled in pubspec.yaml
