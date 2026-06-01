
class UserData {
  String name;
  int waterCups;
  int steps;
  int sleepHours;
  String mood;
  bool onboardingComplete;
  List<String> goals;
  String mobilityPreference;

  UserData({
    this.name = 'Friend',
    this.waterCups = 0,
    this.steps = 0,
    this.sleepHours = 0,
    this.mood = 'Good',
    this.onboardingComplete = false,
    this.goals = const [],
    this.mobilityPreference = 'All',
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
  );
}
