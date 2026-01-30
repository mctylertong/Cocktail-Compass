import 'package:flutter/material.dart';
import '../models/drink.dart';
import '../services/database_service.dart';

class FavoritesViewModel extends ChangeNotifier {
  List<Drink> _favoritedDrinks = [];
  Set<String> _favoritedDrinkIDs = {};
  bool _isLoading = false;

  List<Drink> get favoritedDrinks => _favoritedDrinks;
  Set<String> get favoritedDrinkIDs => _favoritedDrinkIDs;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final drinks = await DatabaseService.instance.fetchFavoritedDrinks();
      _favoritedDrinks = drinks;
      _favoritedDrinkIDs = drinks.map((d) => d.id).toSet();
    } catch (e) {
      print('Error loading favorites: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(Drink drink) async {
    if (_favoritedDrinkIDs.contains(drink.id)) {
      await DatabaseService.instance.deleteFavoritedDrink(drink.id);
      _favoritedDrinkIDs.remove(drink.id);
      _favoritedDrinks.removeWhere((d) => d.id == drink.id);
    } else {
      await DatabaseService.instance.addFavoritedDrink(drink);
      _favoritedDrinkIDs.add(drink.id);
      _favoritedDrinks.add(drink);
    }
    notifyListeners();
  }

  Future<void> removeFavorite(Drink drink) async {
    await DatabaseService.instance.deleteFavoritedDrink(drink.id);
    _favoritedDrinkIDs.remove(drink.id);
    _favoritedDrinks.removeWhere((d) => d.id == drink.id);
    notifyListeners();
  }

  bool isFavorited(String drinkId) {
    return _favoritedDrinkIDs.contains(drinkId);
  }
}
