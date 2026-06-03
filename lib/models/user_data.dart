
class UserData {
  String name;
  int waterCups;
  int steps;
  int sleepHours;
  String mood;
  bool onboardingComplete;
  List<String> goals;
  String mobilityPreference;

  // Tracking fields for Profile/Progress/Settings
  int currentStreak;        // consecutive days with activity
  int totalMovements;       // lifetime movements completed
  int daysActive;           // total days with any activity
  String lastActiveDate;    // ISO date string of last activity
  List<String> completedExerciseIds; // exercise IDs completed
  int dioramaProgress;      // 0-100 progress toward Empire

  UserData({
    this.name = 'Friend',
    this.waterCups = 0,
    this.steps = 0,
    this.sleepHours = 0,
    this.mood = 'Good',
    this.onboardingComplete = false,
    this.goals = const [],
    this.mobilityPreference = 'All',
    this.currentStreak = 0,
    this.totalMovements = 0,
    this.daysActive = 0,
    this.lastActiveDate = '',
    this.completedExerciseIds = const [],
    this.dioramaProgress = 0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'waterCups': waterCups,
    'steps': steps,
    'sleepHours': sleepHours,
    'mood': mood,
    'onboardingComplete': onboardingComplete,
    'goals': goals,
    'mobilityPreference': mobilityPreference,
    'currentStreak': currentStreak,
    'totalMovements': totalMovements,
    'daysActive': daysActive,
    'lastActiveDate': lastActiveDate,
    'completedExerciseIds': completedExerciseIds,
    'dioramaProgress': dioramaProgress,
  };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    name: json['name'] ?? 'Friend',
    waterCups: json['waterCups'] ?? 0,
    steps: json['steps'] ?? 0,
    sleepHours: json['sleepHours'] ?? 0,
    mood: json['mood'] ?? 'Good',
    onboardingComplete: json['onboardingComplete'] ?? false,
    goals: List<String>.from(json['goals'] ?? []),
    mobilityPreference: json['mobilityPreference'] ?? 'All',
    currentStreak: json['currentStreak'] ?? 0,
    totalMovements: json['totalMovements'] ?? 0,
    daysActive: json['daysActive'] ?? 0,
    lastActiveDate: json['lastActiveDate'] ?? '',
    completedExerciseIds: List<String>.from(json['completedExerciseIds'] ?? []),
    dioramaProgress: json['dioramaProgress'] ?? 0,
  );
}
