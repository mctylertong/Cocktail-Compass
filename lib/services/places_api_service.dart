import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/store.dart';
import '../config/api_keys.dart';
import 'error_service.dart';

/// Store category for filtering and display
enum StoreCategory {
  liquorStore,    // Dedicated liquor/wine/spirits stores
  specialty,      // Specialty stores (wine bars, craft beer shops)
  grocery,        // Supermarkets and grocery stores
}

class PlacesAPIService {
  // API key from centralized config (lib/config/api_keys.dart)
  static String get _apiKey => ApiKeys.googleMapsApiKey;
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const Duration _timeout = Duration(seconds: 15);

  // Keywords that indicate a store sells alcohol or cocktail ingredients
  static const List<String> _alcoholKeywords = [
    'liquor', 'wine', 'spirits', 'beer', 'alcohol', 'beverage',
    'bottle shop', 'off license', 'package store', 'abc store',
    'vodka', 'whiskey', 'rum', 'gin', 'tequila', 'bourbon',
    'cocktail', 'mixer', 'bar supply',
  ];

  // Keywords that indicate cocktail ingredient suppliers
  static const List<String> _ingredientKeywords = [
    'bitters', 'syrup', 'juice', 'garnish', 'citrus', 'lime',
    'lemon', 'orange', 'mint', 'herb', 'spice', 'sugar',
  ];

  // Store types/names to exclude (not relevant for cocktails)
  static const List<String> _excludePatterns = [
    'gas station', 'petrol', 'fuel', 'convenience',
    'pharmacy', 'drug store', 'cvs', 'walgreens',
    'dollar', '99 cent', 'thrift',
    'restaurant', 'cafe', 'coffee', 'diner',
    'bar', 'pub', 'tavern', 'nightclub', // We want stores, not bars
    'hotel', 'motel', 'inn',
    'laundry', 'dry clean', 'car wash',
    'bank', 'atm', 'insurance',
    'salon', 'spa', 'nail', 'hair',
    'auto', 'tire', 'mechanic',
  ];

  /// Searches for nearby stores that sell alcohol and cocktail ingredients.
  /// Filters out irrelevant stores and prioritizes liquor-specific stores.
  ///
  /// [latitude] - User's current latitude
  /// [longitude] - User's current longitude
  /// [radiusMeters] - Search radius in meters (default: 5000m = ~3.1 miles)
  ///
  /// Throws [AppException] on error for proper error handling by caller.
  static Future<List<Store>> searchNearbyStores({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
  }) async {
    List<_ScoredStore> scoredStores = [];
    List<String> errors = [];

    // Priority 1: Dedicated liquor stores (most relevant)
    try {
      final liquorStores = await _fetchPlacesByType(
        latitude: latitude,
        longitude: longitude,
        type: 'liquor_store',
        radiusMeters: radiusMeters,
      );
      for (var store in liquorStores) {
        scoredStores.add(_ScoredStore(store, _calculateRelevanceScore(store, StoreCategory.liquorStore)));
      }
    } catch (e) {
      errors.add('liquor_store: $e');
    }

    // Priority 2: Search for specific alcohol-related keywords
    final alcoholKeywordSearches = ['liquor store', 'wine shop', 'spirits', 'bottle shop'];
    for (String keyword in alcoholKeywordSearches) {
      try {
        final stores = await _fetchPlacesByKeyword(
          latitude: latitude,
          longitude: longitude,
          keyword: keyword,
          radiusMeters: radiusMeters,
        );
        for (var store in stores) {
          scoredStores.add(_ScoredStore(store, _calculateRelevanceScore(store, StoreCategory.specialty)));
        }
      } catch (e) {
        errors.add('keyword "$keyword": $e');
      }
    }

    // Priority 3: Supermarkets (lower priority, but they sell alcohol)
    try {
      final supermarkets = await _fetchPlacesByType(
        latitude: latitude,
        longitude: longitude,
        type: 'supermarket',
        radiusMeters: radiusMeters,
      );
      for (var store in supermarkets) {
        scoredStores.add(_ScoredStore(store, _calculateRelevanceScore(store, StoreCategory.grocery)));
      }
    } catch (e) {
      errors.add('supermarket: $e');
    }

    // If all requests failed, throw an error
    if (scoredStores.isEmpty && errors.isNotEmpty) {
      throw NetworkException('Failed to fetch stores: ${errors.first}');
    }

    // Remove duplicates, keeping highest score for each place
    final uniqueStores = <String, _ScoredStore>{};
    for (var scored in scoredStores) {
      final existing = uniqueStores[scored.store.id];
      if (existing == null || scored.score > existing.score) {
        uniqueStores[scored.store.id] = scored;
      }
    }

    // Filter out irrelevant stores
    final filteredStores = uniqueStores.values
        .where((s) => !_shouldExcludeStore(s.store))
        .toList();

    // Sort by relevance score first, then by distance
    filteredStores.sort((a, b) {
      // Higher score = more relevant
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      // If same score, sort by distance
      return (a.store.distance ?? 0).compareTo(b.store.distance ?? 0);
    });

    // Return top 20 stores
    return filteredStores.take(20).map((s) => s.store).toList();
  }

  /// Calculates a relevance score for a store based on its name and category
  static int _calculateRelevanceScore(Store store, StoreCategory category) {
    int score = 0;
    final nameLower = store.name.toLowerCase();

    // Base score by category
    switch (category) {
      case StoreCategory.liquorStore:
        score = 100; // Highest priority
        break;
      case StoreCategory.specialty:
        score = 75;
        break;
      case StoreCategory.grocery:
        score = 25; // Lower priority
        break;
    }

    // Bonus points for alcohol-related keywords in name
    for (var keyword in _alcoholKeywords) {
      if (nameLower.contains(keyword)) {
        score += 15;
      }
    }

    // Bonus for cocktail ingredient keywords
    for (var keyword in _ingredientKeywords) {
      if (nameLower.contains(keyword)) {
        score += 10;
      }
    }

    // Bonus for "store" or "shop" in name (indicates retail)
    if (nameLower.contains('store') || nameLower.contains('shop')) {
      score += 5;
    }

    // Penalty for generic names
    if (nameLower == 'supermarket' || nameLower == 'grocery store') {
      score -= 10;
    }

    return score;
  }

  /// Checks if a store should be excluded based on its name
  static bool _shouldExcludeStore(Store store) {
    final nameLower = store.name.toLowerCase();

    for (var pattern in _excludePatterns) {
      if (nameLower.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  /// Fetches places by type using Google Places API Nearby Search
  static Future<List<Store>> _fetchPlacesByType({
    required double latitude,
    required double longitude,
    required String type,
    required int radiusMeters,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/nearbysearch/json'
      '?location=$latitude,$longitude'
      '&radius=$radiusMeters'
      '&type=$type'
      '&key=$_apiKey',
    );

    final data = await _makeRequest(url);
    return _parsePlacesResponse(data, latitude, longitude);
  }

  /// Fetches places by keyword using Google Places API Nearby Search
  static Future<List<Store>> _fetchPlacesByKeyword({
    required double latitude,
    required double longitude,
    required String keyword,
    required int radiusMeters,
  }) async {
    final encodedKeyword = Uri.encodeComponent(keyword);
    final url = Uri.parse(
      '$_baseUrl/nearbysearch/json'
      '?location=$latitude,$longitude'
      '&radius=$radiusMeters'
      '&keyword=$encodedKeyword'
      '&key=$_apiKey',
    );

    final data = await _makeRequest(url);
    return _parsePlacesResponse(data, latitude, longitude);
  }

  /// Makes an HTTP request with timeout and error handling
  static Future<Map<String, dynamic>> _makeRequest(Uri url) async {
    try {
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          _validateApiResponse(data);
          return data;
        }
        throw ParsingException('Unexpected response format');
      } else {
        throw ServerException(
          statusCode: response.statusCode,
          details: 'Places API returned status ${response.statusCode}',
        );
      }
    } on SocketException {
      throw NetworkException('Unable to connect to Google Places API');
    } on TimeoutException {
      throw AppException(
        'Request timed out',
        details: 'Places API did not respond in time',
        type: AppErrorType.timeout,
      );
    } on FormatException catch (e) {
      throw ParsingException('Invalid response format: ${e.message}');
    }
  }

  /// Validates the Google Places API response status
  static void _validateApiResponse(Map<String, dynamic> data) {
    final status = data['status'] as String?;

    switch (status) {
      case 'OK':
      case 'ZERO_RESULTS':
        // These are valid responses
        return;
      case 'REQUEST_DENIED':
        throw ApiKeyException(
          data['error_message'] as String? ?? 'API key is invalid or not authorized',
        );
      case 'OVER_QUERY_LIMIT':
        throw RateLimitException('Google Places API quota exceeded');
      case 'INVALID_REQUEST':
        throw AppException(
          'Invalid request',
          details: data['error_message'] as String?,
          type: AppErrorType.unknown,
        );
      default:
        throw AppException(
          'Places API error',
          details: 'Status: $status - ${data['error_message'] ?? 'Unknown error'}',
          type: AppErrorType.unknown,
        );
    }
  }

  /// Parses the Google Places API response and converts to Store objects
  static List<Store> _parsePlacesResponse(
    Map<String, dynamic> data,
    double userLat,
    double userLng,
  ) {
    List<Store> stores = [];

    if (data['status'] == 'OK' && data['results'] != null) {
      for (var result in data['results']) {
        try {
          final location = result['geometry']?['location'];
          if (location == null) continue;

          final lat = (location['lat'] as num).toDouble();
          final lng = (location['lng'] as num).toDouble();

          // Calculate distance from user location (in meters)
          final distance = _calculateDistance(userLat, userLng, lat, lng);

          final store = Store(
            id: result['place_id'] ?? '',
            name: result['name'] ?? 'Unknown Store',
            address: result['vicinity'] ?? result['formatted_address'] ?? 'Address unavailable',
            coordinate: LatLng(lat, lng),
            distance: distance,
          );

          stores.add(store);
        } catch (e) {
          // Skip malformed entries but continue processing
          continue;
        }
      }
    }

    return stores;
  }

  /// Calculates the distance between two coordinates using Haversine formula
  /// Returns distance in meters
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusMeters = 6371000; // Earth's radius in meters

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Validates if the API key is configured
  static bool isApiKeyConfigured() {
    return ApiKeys.isGoogleMapsConfigured;
  }
}

/// Helper class to track store with its relevance score
class _ScoredStore {
  final Store store;
  final int score;

  _ScoredStore(this.store, this.score);
}
