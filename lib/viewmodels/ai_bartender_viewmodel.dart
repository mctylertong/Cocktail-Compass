import 'package:flutter/foundation.dart';
import '../services/ai_bartender_service.dart';
import '../services/database_service.dart';

enum MessageRole { user, assistant, system }

class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.isError = false,
  })  : id = DateTime.now().microsecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();
}

class AIBartenderViewModel extends ChangeNotifier {
  final AIBartenderService _aiService = AIBartenderService.instance;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _apiKey;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isConfigured => _aiService.isConfigured;
  bool get hasMessages => _messages.isNotEmpty;

  Future<void> initialize() async {
    // First, try to use the embedded API key
    _aiService.initializeWithEmbeddedKey();

    // If not configured, check for user-provided key in database
    if (!_aiService.isConfigured) {
      _apiKey = await DatabaseService.instance.getSetting('gemini_api_key');
      if (_apiKey != null && _apiKey!.isNotEmpty) {
        _aiService.configure(_apiKey!);
      }
    }

    // Add welcome message if no messages
    if (_messages.isEmpty) {
      _addWelcomeMessage();
    }

    notifyListeners();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      content: '''Hey there! I'm your AI Bartender. I can help you with:

- **Cocktail recommendations** based on your mood or preferences
- **Custom recipes** - describe what you want and I'll create it
- **Questions** about ingredients, techniques, or cocktail history

What can I mix up for you today?''',
      role: MessageRole.assistant,
    ));
  }

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey;
    await DatabaseService.instance.saveSetting('gemini_api_key', apiKey);
    _aiService.configure(apiKey);
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(
      content: content,
      role: MessageRole.user,
    ));
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _aiService.sendMessage(content);

      _messages.add(ChatMessage(
        content: response,
        role: MessageRole.assistant,
      ));
    } on AIBartenderException catch (e) {
      _messages.add(ChatMessage(
        content: e.message,
        role: MessageRole.assistant,
        isError: true,
      ));
    } catch (e) {
      _messages.add(ChatMessage(
        content: 'Sorry, something went wrong. Please try again.',
        role: MessageRole.assistant,
        isError: true,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getQuickRecommendation(String type) async {
    String prompt;
    switch (type) {
      case 'refreshing':
        prompt = 'Suggest a refreshing cocktail perfect for a hot day';
        break;
      case 'classic':
        prompt = 'Recommend a classic cocktail that every bartender should know';
        break;
      case 'party':
        prompt = 'What\'s a crowd-pleasing cocktail for a party?';
        break;
      case 'romantic':
        prompt = 'Suggest an elegant cocktail for a romantic evening';
        break;
      case 'mocktail':
        prompt = 'Recommend a delicious non-alcoholic mocktail';
        break;
      case 'adventurous':
        prompt = 'Surprise me with an unusual or exotic cocktail!';
        break;
      default:
        prompt = 'Recommend a popular cocktail';
    }

    await sendMessage(prompt);
  }

  void clearChat() {
    _messages.clear();
    _aiService.clearHistory();
    _addWelcomeMessage();
    notifyListeners();
  }

  void startNewConversation() {
    _aiService.startNewChat();
    clearChat();
  }
}
