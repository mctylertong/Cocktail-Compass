/// API Keys Configuration Template
///
/// SETUP INSTRUCTIONS:
/// 1. Copy this file to api_keys.dart in the same directory
/// 2. Replace the placeholder values with your actual API keys
/// 3. Never commit api_keys.dart to version control!
///
/// WHERE TO GET API KEYS:
/// - Gemini: https://aistudio.google.com/app/apikey
/// - Google Maps/Places: https://console.cloud.google.com/
///   (Enable: Places API, Maps SDK for Android, Maps SDK for iOS)

class ApiKeys {
  // Google Gemini API Key (for AI Bartender feature)
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

  // Google Places/Maps API Key (for nearby stores feature)
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';

  // Validation helpers
  static bool get isGeminiConfigured =>
      geminiApiKey.isNotEmpty && geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE';

  static bool get isGoogleMapsConfigured =>
      googleMapsApiKey.isNotEmpty && googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
}
