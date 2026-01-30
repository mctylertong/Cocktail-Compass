import 'package:flutter/material.dart';
import '../models/drink.dart';
import '../models/paginated_result.dart';
import '../services/drink_api_service.dart';
import '../services/error_service.dart';

class IngredientsViewModel extends ChangeNotifier {
  String _ingredient = '';
  List<Drink> _allDrinks = []; // Full result set from API
  bool _isLoading = false;
  AppException? _error;
  List<String> _ingredientHistory = [];
  bool _hasSearched = false;
  PaginationState _pagination = const PaginationState(pageSize: 10);

  // Getters
  String get ingredient => _ingredient;

  /// Returns paginated drinks for current page
  List<Drink> get drinks {
    final result = PaginatedResult.fromList(
      _allDrinks,
      page: _pagination.currentPage,
      pageSize: _pagination.pageSize,
    );
    return result.items;
  }

  /// Returns all drinks without pagination
  List<Drink> get allDrinks => _allDrinks;

  bool get isLoading => _isLoading;
  AppException? get error => _error;
  String? get errorMessage => _error != null ? ErrorService.getUserMessage(_error!) : null;
  AppErrorType? get errorType => _error?.type;
  bool get hasError => _error != null;
  bool get canRetry => _error != null && ErrorService.isRetryable(_error!.type);
  List<String> get ingredientHistory => _ingredientHistory;
  bool get hasSearched => _hasSearched;
  bool get hasResults => _allDrinks.isNotEmpty;

  // Pagination getters
  PaginationState get pagination => _pagination;
  int get currentPage => _pagination.currentPage;
  int get totalPages => _allDrinks.isEmpty ? 1 : (_allDrinks.length / _pagination.pageSize).ceil();
  int get totalResults => _allDrinks.length;
  bool get hasNextPage => _pagination.currentPage < totalPages;
  bool get hasPreviousPage => _pagination.currentPage > 1;
  int get pageSize => _pagination.pageSize;

  /// Get display range (e.g., "1-10 of 25")
  String get paginationInfo {
    if (_allDrinks.isEmpty) return '0 results';
    final start = ((_pagination.currentPage - 1) * _pagination.pageSize) + 1;
    var end = _pagination.currentPage * _pagination.pageSize;
    if (end > _allDrinks.length) end = _allDrinks.length;
    return '$start-$end of ${_allDrinks.length}';
  }

  void setIngredient(String value) {
    _ingredient = value;
    notifyListeners();
  }

  Future<void> fetchDrinksByIngredient([String? newIngredient]) async {
    final searchIngredient = newIngredient ?? _ingredient;
    if (searchIngredient.isEmpty) return;

    _ingredient = searchIngredient;
    _isLoading = true;
    _error = null;
    _hasSearched = true;
    _pagination = _pagination.copyWith(currentPage: 1); // Reset to first page
    notifyListeners();

    try {
      _allDrinks = await DrinkAPIService.fetchDrinksByIngredient(searchIngredient);
      _pagination = _pagination.copyWith(totalItems: _allDrinks.length);

      // Add to ingredient history if not already present
      if (!_ingredientHistory.contains(searchIngredient)) {
        _ingredientHistory.insert(0, searchIngredient);
        // Keep only last 10 ingredients
        if (_ingredientHistory.length > 10) {
          _ingredientHistory = _ingredientHistory.take(10).toList();
        }
      }
    } on AppException catch (e) {
      _error = e;
      _allDrinks = [];
    } catch (e) {
      _error = ErrorService.handleException(e);
      _allDrinks = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Go to next page
  void nextPage() {
    if (hasNextPage) {
      _pagination = _pagination.copyWith(currentPage: _pagination.currentPage + 1);
      notifyListeners();
    }
  }

  /// Go to previous page
  void previousPage() {
    if (hasPreviousPage) {
      _pagination = _pagination.copyWith(currentPage: _pagination.currentPage - 1);
      notifyListeners();
    }
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _pagination = _pagination.copyWith(currentPage: page);
      notifyListeners();
    }
  }

  /// Change page size
  void setPageSize(int size) {
    if (size > 0 && size != _pagination.pageSize) {
      _pagination = _pagination.copyWith(
        pageSize: size,
        currentPage: 1, // Reset to first page when changing page size
      );
      notifyListeners();
    }
  }

  /// Retry the last ingredient search if it failed
  Future<void> retry() async {
    if (_ingredient.isNotEmpty) {
      await fetchDrinksByIngredient(_ingredient);
    }
  }

  void clearResults() {
    _allDrinks = [];
    _error = null;
    _hasSearched = false;
    _pagination = _pagination.copyWith(currentPage: 1, totalItems: 0);
    notifyListeners();
  }

  void clearIngredient() {
    _ingredient = '';
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clear() {
    _ingredient = '';
    _allDrinks = [];
    _error = null;
    _hasSearched = false;
    _pagination = _pagination.copyWith(currentPage: 1, totalItems: 0);
    notifyListeners();
  }

  void clearHistory() {
    _ingredientHistory = [];
    notifyListeners();
  }

  void removeFromHistory(String ingredient) {
    _ingredientHistory.remove(ingredient);
    notifyListeners();
  }
}
