import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ShoppingItem {
  final String id;
  final String name;
  final String? fromDrink;
  final DateTime addedAt;
  bool isChecked;

  ShoppingItem({
    required this.id,
    required this.name,
    this.fromDrink,
    required this.addedAt,
    this.isChecked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fromDrink': fromDrink,
      'addedAt': addedAt.toIso8601String(),
      'isChecked': isChecked ? 1 : 0,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      fromDrink: json['fromDrink'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
      isChecked: (json['isChecked'] as int) == 1,
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? fromDrink,
    DateTime? addedAt,
    bool? isChecked,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      fromDrink: fromDrink ?? this.fromDrink,
      addedAt: addedAt ?? this.addedAt,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

class ShoppingListViewModel extends ChangeNotifier {
  List<ShoppingItem> _items = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<ShoppingItem> get items => _items;
  List<ShoppingItem> get uncheckedItems => _items.where((i) => !i.isChecked).toList();
  List<ShoppingItem> get checkedItems => _items.where((i) => i.isChecked).toList();
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isEmpty => _items.isEmpty;
  int get totalCount => _items.length;
  int get uncheckedCount => uncheckedItems.length;
  int get checkedCount => checkedItems.length;

  /// Get items grouped by the drink they came from
  Map<String?, List<ShoppingItem>> get itemsByDrink {
    final Map<String?, List<ShoppingItem>> grouped = {};
    for (final item in _items) {
      final key = item.fromDrink;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(item);
    }
    return grouped;
  }

  /// Initialize and load from database
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      _items = await DatabaseService.instance.getShoppingList();
    } catch (e) {
      _items = [];
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  /// Add an item to the shopping list
  Future<void> addItem(String name, {String? fromDrink}) async {
    // Check if item already exists (case-insensitive)
    final existingIndex = _items.indexWhere(
      (item) => item.name.toLowerCase() == name.toLowerCase(),
    );

    if (existingIndex != -1) {
      // Item already exists, don't add duplicate
      return;
    }

    final item = ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      fromDrink: fromDrink,
      addedAt: DateTime.now(),
    );

    _items.insert(0, item);
    notifyListeners();

    await DatabaseService.instance.addShoppingItem(item);
  }

  /// Add multiple items at once
  Future<void> addItems(List<String> names, {String? fromDrink}) async {
    for (final name in names) {
      await addItem(name, fromDrink: fromDrink);
    }
  }

  /// Toggle the checked state of an item
  Future<void> toggleItem(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _items[index] = _items[index].copyWith(isChecked: !_items[index].isChecked);
    notifyListeners();

    await DatabaseService.instance.updateShoppingItem(_items[index]);
  }

  /// Remove an item from the list
  Future<void> removeItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();

    await DatabaseService.instance.deleteShoppingItem(id);
  }

  /// Remove all checked items
  Future<void> removeCheckedItems() async {
    final checkedIds = checkedItems.map((i) => i.id).toList();
    _items.removeWhere((item) => item.isChecked);
    notifyListeners();

    for (final id in checkedIds) {
      await DatabaseService.instance.deleteShoppingItem(id);
    }
  }

  /// Clear all items
  Future<void> clearAll() async {
    _items.clear();
    notifyListeners();

    await DatabaseService.instance.clearShoppingList();
  }

  /// Check all items
  Future<void> checkAll() async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isChecked: true);
    }
    notifyListeners();

    for (final item in _items) {
      await DatabaseService.instance.updateShoppingItem(item);
    }
  }

  /// Uncheck all items
  Future<void> uncheckAll() async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isChecked: false);
    }
    notifyListeners();

    for (final item in _items) {
      await DatabaseService.instance.updateShoppingItem(item);
    }
  }

  /// Get a shareable text version of the list
  String toShareableText() {
    final buffer = StringBuffer();
    buffer.writeln('Shopping List');
    buffer.writeln('=============');

    for (final item in _items) {
      final checkMark = item.isChecked ? '[x]' : '[ ]';
      buffer.writeln('$checkMark ${item.name}');
    }

    return buffer.toString();
  }
}
