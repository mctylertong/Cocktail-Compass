import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/drink.dart';
import 'error_service.dart';
import 'cache_service.dart';

class DrinkAPIService {
  static const String baseUrl = 'https://www.thecocktaildb.com/api/json/v1/1';
  static const Duration _timeout = Duration(seconds: 15);
  static const int _maxRetries = 3;

  /// Fetches drinks by name with retry logic and caching
  static Future<List<Drink>> fetchDrinks(String query, {bool useCache = true}) async {
    // Check cache first
    if (useCache) {
      final cached = await CacheService.instance.getCachedSearch(query);
      if (cached != null) return cached;
    }

    final List<Drink> drinks = await _executeWithRetry<List<Drink>>(() async {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse('$baseUrl/search.php?s=$encodedQuery');

      final response = await _makeRequest(url);
      final drinkResponse = DrinkResponse.fromJson(response);
      return drinkResponse.drinks ?? [];
    });

    // Cache the results
    if (drinks.isNotEmpty) {
      await CacheService.instance.cacheSearch(query, drinks);
    }

    return drinks;
  }

  /// Fetches drinks by ingredient with retry logic and caching
  static Future<List<Drink>> fetchDrinksByIngredient(String ingredient, {bool useCache = true}) async {
    // Check cache first
    if (useCache) {
      final cached = await CacheService.instance.getCachedIngredientSearch(ingredient);
      if (cached != null) return cached;
    }

    final List<Drink> drinks = await _executeWithRetry<List<Drink>>(() async {
      final encodedIngredient = Uri.encodeComponent(ingredient);
      final url = Uri.parse('$baseUrl/filter.php?i=$encodedIngredient');

      final response = await _makeRequest(url);
      final drinkResponse = DrinkResponse.fromJson(response);
      return drinkResponse.drinks ?? [];
    });

    // Cache the results
    if (drinks.isNotEmpty) {
      await CacheService.instance.cacheIngredientSearch(ingredient, drinks);
    }

    return drinks;
  }

  /// Fetches drink details by ID with retry logic and caching
  static Future<Drink?> fetchDrinkDetails(String id, {bool useCache = true}) async {
    // Check cache first
    if (useCache) {
      final cached = await CacheService.instance.getCachedDrink(id);
      if (cached != null) return cached;
    }

    final drink = await _executeWithRetry(() async {
      final url = Uri.parse('$baseUrl/lookup.php?i=$id');

      final response = await _makeRequest(url);
      final drinkResponse = DrinkResponse.fromJson(response);
      return drinkResponse.drinks?.first;
    });

    // Cache the result
    if (drink != null) {
      await CacheService.instance.cacheDrink(drink);
    }

    return drink;
  }

  /// Fetches a random cocktail
  static Future<Drink?> fetchRandomCocktail() async {
    return _executeWithRetry(() async {
      final url = Uri.parse('$baseUrl/random.php');

      final response = await _makeRequest(url);
      final drinkResponse = DrinkResponse.fromJson(response);
      return drinkResponse.drinks?.first;
    });
  }

  /// Fetches drinks filtered by alcoholic type (Alcoholic, Non_Alcoholic, Optional_alcohol)
  static Future<List<Drink>> fetchDrinksByAlcoholic(String alcoholicType, {bool useCache = true}) async {
    // Check cache first
    if (useCache) {
      final cached = await CacheService.instance.getCachedFilterList('alcoholic_$alcoholicType');
      if (cached != null) {
        // For filter results, we only have IDs and names, need to return basic Drink objects
        return cached.map((name) => Drink(idDrink: '', strDrink: name)).toList();
      }
    }

    final List<Drink> drinks = await _executeWithRetry<List<Drink>>(() async {
      final encodedType = Uri.encodeComponent(alcoholicType);
      final url = Uri.parse('$baseUrl/filter.php?a=$encodedType');

      final response = await _makeRequest(url);
      final drinkResponse = DrinkResponse.fromJson(response);
      return drinkResponse.drinks ?? [];
    });

    return drinks;
  }

  /// Fetches drinks filtered by category
  static Future<List<Drink>> fetchDrinksByCategory(String category, {bool useCache = true}) async {
    // Check cache first
    if (useCache) {
      final cached = await CacheService.instance.getCachedCategorySearch(category);
      if (cached != null) return cached;
    }

    final List<Drink> drinks = await _executeWithRetry<List<Drink>>(() async {
      final encodedCategory = Uri.encodeComponent(category);
      final url = Uri.parse('$baseUrl/filter.php?c=$encodedCategory');

      final response = await _makeRequest(url);
      final drinkResponse = DrinkResponse.fromJson(response);
      return drinkResponse.drinks ?? [];
    });

    // Cache the results
    if (drinks.isNotEmpty) {
      await CacheService.instance.cacheCategorySearch(category, drinks);
    }

    return drinks;
  }

  /// Fetches drinks filtered by glass type
  static Future<List<Drink>> fetchDrinksByGlass(String glassType, {bool useCache = true}) async {
    // Check cache first (using filter cache with glass_ prefix)
    if (useCache) {
      final cached = await CacheService.instance.getCachedFilterList('glass_$glassType');
      if (cached != null) {
        return cached.map((name) => Drink(idDrink: '', strDrink: name)).toList();
      }
    }

    final List<Drink> drinks = await _executeWithRetry<List<Drink>>(() async {
      final encodedGlass = Uri.encodeComponent(glassType);
      final url = Uri.parse('$baseUrl/filter.php?g=$encodedGlass');

      final response = await _makeRequest(url);
      final drinkResponse = DrinkResponse.fromJson(response);
      return drinkResponse.drinks ?? [];
    });

    // Cache the results
    if (drinks.isNotEmpty) {
      await CacheService.instance.cacheFilterList(
        'glass_$glassType',
        drinks.map((d) => d.name).toList(),
      );
    }

    return drinks;
  }

  /// Fetches list of all categories
  static Future<List<String>> fetchCategories({bool useCache = true}) async {
    // Check cache first
    if (useCache) {
      final cached = await CacheService.instance.getCachedFilterList('categories');
      if (cached != null) return cached;
    }

    final List<String> categories = await _executeWithRetry<List<String>>(() async {
      final url = Uri.parse('$baseUrl/list.php?c=list');

      final response = await _makeRequest(url);
      final drinks = response['drinks'] as List?;
      if (drinks == null) return <String>[];
      return drinks.map((d) => d['strCategory'] as String).toList();
    });

    // Cache the results
    if (categories.isNotEmpty) {
      await CacheService.instance.cacheFilterList('categories', categories);
    }

    return categories;
  }

  /// Fetches list of all glass types
  static Future<List<String>> fetchGlassTypes({bool useCache = true}) async {
    // Check cache first
    if (useCache) {
      final cached = await CacheService.instance.getCachedFilterList('glass_types');
      if (cached != null) return cached;
    }

    final List<String> glassTypes = await _executeWithRetry<List<String>>(() async {
      final url = Uri.parse('$baseUrl/list.php?g=list');

      final response = await _makeRequest(url);
      final drinks = response['drinks'] as List?;
      if (drinks == null) return <String>[];
      return drinks.map((d) => d['strGlass'] as String).toList();
    });

    // Cache the results
    if (glassTypes.isNotEmpty) {
      await CacheService.instance.cacheFilterList('glass_types', glassTypes);
    }

    return glassTypes;
  }

  /// Fetches list of all ingredients
  static Future<List<String>> fetchIngredientsList({bool useCache = true}) async {
    // Check cache first
    if (useCache) {
      final cached = await CacheService.instance.getCachedFilterList('ingredients');
      if (cached != null) return cached;
    }

    final List<String> ingredients = await _executeWithRetry<List<String>>(() async {
      final url = Uri.parse('$baseUrl/list.php?i=list');

      final response = await _makeRequest(url);
      final drinks = response['drinks'] as List?;
      if (drinks == null) return <String>[];
      return drinks.map((d) => d['strIngredient1'] as String).toList();
    });

    // Cache the results
    if (ingredients.isNotEmpty) {
      await CacheService.instance.cacheFilterList('ingredients', ingredients);
    }

    return ingredients;
  }

  /// Fetches list of alcoholic filter options
  static Future<List<String>> fetchAlcoholicFilters({bool useCache = true}) async {
    // Check cache first
    if (useCache) {
      final cached = await CacheService.instance.getCachedFilterList('alcoholic_filters');
      if (cached != null) return cached;
    }

    final List<String> filters = await _executeWithRetry<List<String>>(() async {
      final url = Uri.parse('$baseUrl/list.php?a=list');

      final response = await _makeRequest(url);
      final drinks = response['drinks'] as List?;
      if (drinks == null) return <String>[];
      return drinks.map((d) => d['strAlcoholic'] as String).toList();
    });

    // Cache the results
    if (filters.isNotEmpty) {
      await CacheService.instance.cacheFilterList('alcoholic_filters', filters);
    }

    return filters;
  }

  /// Makes an HTTP request with timeout and error handling
  static Future<Map<String, dynamic>> _makeRequest(Uri url) async {
    try {
      final response = await http.get(url).timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('Unable to connect to server');
    } on TimeoutException {
      throw TimeoutException('Request timed out after ${_timeout.inSeconds} seconds');
    } on FormatException catch (e) {
      throw ParsingException('Invalid response format: ${e.message}');
    }
  }

  /// Handles HTTP response and converts to appropriate exception if needed
  static Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        try {
          final data = json.decode(response.body);
          if (data is Map<String, dynamic>) {
            return data;
          }
          throw ParsingException('Unexpected response format');
        } on FormatException catch (e) {
          throw ParsingException('Failed to parse response: ${e.message}');
        }
      case 400:
        throw AppException('Invalid request', type: AppErrorType.unknown);
      case 401:
      case 403:
        throw AppException('Access denied', type: AppErrorType.unauthorized);
      case 404:
        throw NotFoundException('Resource not found');
      case 429:
        throw RateLimitException('Too many requests, please try again later');
      case 500:
      case 502:
      case 503:
      case 504:
        throw ServerException(
          statusCode: response.statusCode,
          details: 'Server returned status ${response.statusCode}',
        );
      default:
        throw AppException(
          'Unexpected error',
          details: 'Status code: ${response.statusCode}',
          type: AppErrorType.unknown,
        );
    }
  }

  /// Executes a function with retry logic for transient failures
  static Future<T> _executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = _maxRetries,
  }) async {
    int attempts = 0;
    AppException? lastError;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } on AppException catch (e) {
        lastError = e;
        attempts++;

        // Only retry for retryable errors
        if (!ErrorService.isRetryable(e.type) || attempts >= maxRetries) {
          throw e;
        }

        // Exponential backoff: 1s, 2s, 4s...
        final delay = Duration(milliseconds: 500 * (1 << attempts));
        await Future.delayed(delay);
      } catch (e) {
        // Convert unknown errors and don't retry
        throw ErrorService.handleException(e);
      }
    }

    throw lastError ?? AppException('Operation failed after $maxRetries attempts');
  }
}
