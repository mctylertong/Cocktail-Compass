import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/drink.dart';
import '../config/api_keys.dart';

class AIBartenderService {
  static AIBartenderService? _instance;
  GenerativeModel? _model;
  ChatSession? _chatSession;
  String? _apiKey;

  AIBartenderService._();

  static AIBartenderService get instance {
    _instance ??= AIBartenderService._();
    return _instance!;
  }

  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  /// Initialize with embedded API key if available
  void initializeWithEmbeddedKey() {
    if (ApiKeys.isGeminiConfigured && !isConfigured) {
      configure(ApiKeys.geminiApiKey);
    }
  }

  void configure(String apiKey) {
    if (apiKey.isEmpty) {
      _apiKey = null;
      _model = null;
      _chatSession = null;
      return;
    }

    _apiKey = apiKey;
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(_systemPrompt),
    );
    _chatSession = null; // Reset chat session when reconfigured
  }

  static const String _systemPrompt = '''
You are a friendly, knowledgeable AI bartender assistant for a cocktail discovery app called "Cocktail Compass". Your role is to:

1. **Recommend cocktails** based on user preferences like:
   - Mood or occasion (relaxing evening, party, date night)
   - Flavor preferences (sweet, sour, bitter, fruity, smoky)
   - Base spirit preferences (vodka, rum, gin, whiskey, tequila)
   - Dietary needs (non-alcoholic, low-sugar)

2. **Create custom cocktail recipes** when users describe what they want:
   - Provide realistic, balanced recipes
   - Include exact measurements
   - Give clear preparation instructions

3. **Answer cocktail questions** like:
   - Ingredient substitutions
   - Technique explanations
   - History and origin of drinks
   - Pairing suggestions

**Response Guidelines:**
- Be conversational and friendly, like a real bartender
- Keep responses concise but helpful
- When suggesting cocktails, mention 2-3 options with brief descriptions
- For recipes, use this format:

  **[Cocktail Name]**

  *Ingredients:*
  - 2 oz [spirit]
  - 1 oz [mixer]
  - etc.

  *Instructions:*
  1. Step one
  2. Step two

  *Glass:* [glass type]
  *Garnish:* [garnish]

- If asked about something unrelated to cocktails/bartending, politely redirect the conversation
- Never recommend excessive drinking; suggest mocktails as alternatives when appropriate
''';

  void startNewChat() {
    if (_model != null) {
      _chatSession = _model!.startChat();
    }
  }

  Future<String> sendMessage(String message) async {
    if (_model == null) {
      throw AIBartenderException('AI Bartender is not configured. Please add your Gemini API key in Settings.');
    }

    _chatSession ??= _model!.startChat();

    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      final text = response.text;

      if (text == null || text.isEmpty) {
        throw AIBartenderException('Received empty response from AI');
      }

      return text;
    } on GenerativeAIException catch (e) {
      // Log the full error for debugging
      print('Gemini API Error: ${e.message}');

      if (e.message.contains('API_KEY_INVALID') || e.message.contains('API key not valid')) {
        throw AIBartenderException('Invalid API key. Please check your Gemini API key in Settings.');
      }
      if (e.message.contains('RESOURCE_EXHAUSTED') || e.message.contains('quota')) {
        throw AIBartenderException('API quota exceeded. Please try again later or check your Google AI Studio quota.');
      }
      if (e.message.contains('PERMISSION_DENIED')) {
        throw AIBartenderException('Permission denied. The API key may not have access to Gemini.');
      }
      // Show the actual error for debugging
      throw AIBartenderException('AI error: ${e.message}');
    } catch (e) {
      print('Unknown error: $e');
      throw AIBartenderException('Failed to get response: $e');
    }
  }

  /// Get cocktail recommendations based on criteria
  Future<String> getRecommendations({
    String? mood,
    String? flavorProfile,
    String? baseSpirit,
    List<String>? availableIngredients,
    bool nonAlcoholic = false,
  }) async {
    final parts = <String>[];

    if (mood != null) parts.add('I\'m in the mood for something $mood');
    if (flavorProfile != null) parts.add('I like $flavorProfile flavors');
    if (baseSpirit != null) parts.add('I prefer $baseSpirit-based drinks');
    if (availableIngredients != null && availableIngredients.isNotEmpty) {
      parts.add('I have these ingredients: ${availableIngredients.join(", ")}');
    }
    if (nonAlcoholic) parts.add('I\'d like non-alcoholic options');

    final prompt = parts.isEmpty
        ? 'Can you recommend some popular cocktails?'
        : '${parts.join(". ")}. What cocktails would you recommend?';

    return sendMessage(prompt);
  }

  /// Create a custom cocktail based on description
  Future<String> createCustomCocktail(String description) async {
    final prompt = 'Create a cocktail recipe based on this description: $description';
    return sendMessage(prompt);
  }

  /// Get information about a specific cocktail
  Future<String> getCocktailInfo(Drink drink) async {
    final prompt = 'Tell me about the ${drink.name} cocktail - its history, taste profile, and any interesting facts.';
    return sendMessage(prompt);
  }

  /// Get ingredient substitution suggestions
  Future<String> getSubstitution(String ingredient, {String? forCocktail}) async {
    final prompt = forCocktail != null
        ? 'What can I substitute for $ingredient in a $forCocktail?'
        : 'What are good substitutes for $ingredient in cocktails?';
    return sendMessage(prompt);
  }

  void clearHistory() {
    _chatSession = null;
  }
}

class AIBartenderException implements Exception {
  final String message;

  AIBartenderException(this.message);

  @override
  String toString() => message;
}
