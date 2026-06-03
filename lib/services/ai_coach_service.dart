import 'dart:convert';
import 'package:http/http.dart' as http;

class AICoachService {
  static AICoachService? _instance;
  AICoachService._();
  factory AICoachService() {
    _instance ??= AICoachService._();
    return _instance!;
  }

  String _apiKey = '';
  String _model = 'big-pickle';

  String get model => _model;

  void configure(String apiKey, String model) {
    _apiKey = apiKey;
    _model = model;
  }

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> getResponse(String message, {String userName = 'Friend'}) async {
    if (_apiKey.isEmpty) {
      return _localResponse(message);
    }

    try {
      final response = await http.post(
        Uri.parse('https://opencode.ai/zen/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': _systemPrompt(userName),
            },
            {
              'role': 'user',
              'content': message,
            },
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return _localResponse(message);
      }
    } catch (_) {
      return _localResponse(message);
    }
  }

  String _systemPrompt(String userName) {
    return '''You are Lumina, a warm, supportive AI wellness coach for the EmpowerWellness app.
Your user is $userName. Your style is:
- Shame-free, never judgmental
- Encouraging and uplifting
- Uses metaphors like "your world is evolving"
- Short, conversational responses (2-3 sentences max)
- Focuses on small wins and progress, not perfection
- Never mentions calories, weight loss targets, or restrictive diets''';
  }

  String _localResponse(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('hello') || lower.contains('hi')) {
      return 'Hey there, beautiful soul! Welcome back to your sanctuary. What would you like to focus on today?';
    }
    if (lower.contains('tired') || lower.contains('exhausted')) {
      return 'Rest is part of the journey, not a detour. Your world is still growing even when you pause. What small thing feels doable right now?';
    }
    if (lower.contains('sad') || lower.contains('down') || lower.contains('depressed')) {
      return 'Your feelings are valid, and you are not alone in this. Even the strongest trees weather storms. What is one tiny thing that might bring you a moment of peace?';
    }
    if (lower.contains('anxious') || lower.contains('worried') || lower.contains('stress')) {
      return 'Let us breathe through this together. Your world is safe, and you are doing better than you think. Want to try a grounding exercise?';
    }
    if (lower.contains('motivation') || lower.contains('motivated') || lower.contains('give up')) {
      return 'Motivation comes and goes, but your commitment to showing up? That is the real magic. What is one small win you can claim today?';
    }
    return 'That is a powerful thing to share. Remember, your journey is not a sprint — it is a dance. Let us focus on one small step forward. What feels most empowering right now?';
  }
}
