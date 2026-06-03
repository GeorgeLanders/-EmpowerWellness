/// A single meal/snack logged by the user.
/// id is a timestamp string so reordering is stable and the list stays light.
class MealEntry {
  String id;
  String name;
  String mealType; // 'Breakfast', 'Lunch', 'Dinner', 'Snack'
  int calories;
  String time;     // HH:mm display string
  String date;     // YYYY-MM-DD

  MealEntry({
    required this.id,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.time,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'mealType': mealType,
    'calories': calories,
    'time': time,
    'date': date,
  };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    mealType: json['mealType'] ?? 'Snack',
    calories: (json['calories'] ?? 0) as int,
    time: json['time'] ?? '',
    date: json['date'] ?? '',
  );
}
