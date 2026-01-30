import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/drink.dart';

class CacheService {
  static final CacheService instance = CacheService._init();
  static Database? _database;

  // Cache expiration time (24 hours)
  static const Duration cacheExpiration = Duration(hours: 24);

  CacheService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cocktail_cache.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Cache for search results
    await db.execute('''
      CREATE TABLE search_cache (
        query TEXT PRIMARY KEY,
        results TEXT NOT NULL,
        cachedAt INTEGER NOT NULL
      )
    ''');

    // Cache for ingredient search results
    await db.execute('''
      CREATE TABLE ingredient_cache (
        ingredient TEXT PRIMARY KEY,
        results TEXT NOT NULL,
        cachedAt INTEGER NOT NULL
      )
    ''');

    // Cache for category results
    await db.execute('''
      CREATE TABLE category_cache (
        category TEXT PRIMARY KEY,
        results TEXT NOT NULL,
        cachedAt INTEGER NOT NULL
      )
    ''');

    // Cache for drink details
    await db.execute('''
      CREATE TABLE drink_cache (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        cachedAt INTEGER NOT NULL
      )
    ''');

    // Cache for filter lists
    await db.execute('''
      CREATE TABLE filter_cache (
        filterType TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        cachedAt INTEGER NOT NULL
      )
    ''');
  }

  // ============================================================
  // SEARCH CACHE
  // ============================================================

  Future<List<Drink>?> getCachedSearch(String query) async {
    final db = await database;
    final results = await db.query(
      'search_cache',
      where: 'query = ?',
      whereArgs: [query.toLowerCase()],
    );

    if (results.isEmpty) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(results.first['cachedAt'] as int);
    if (DateTime.now().difference(cachedAt) > cacheExpiration) {
      // Cache expired
      await db.delete('search_cache', where: 'query = ?', whereArgs: [query.toLowerCase()]);
      return null;
    }

    final jsonList = json.decode(results.first['results'] as String) as List;
    return jsonList.map((j) => Drink.fromJson(j)).toList();
  }

  Future<void> cacheSearch(String query, List<Drink> drinks) async {
    final db = await database;
    final jsonData = json.encode(drinks.map((d) => d.toJson()).toList());

    await db.insert(
      'search_cache',
      {
        'query': query.toLowerCase(),
        'results': jsonData,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // INGREDIENT CACHE
  // ============================================================

  Future<List<Drink>?> getCachedIngredientSearch(String ingredient) async {
    final db = await database;
    final results = await db.query(
      'ingredient_cache',
      where: 'ingredient = ?',
      whereArgs: [ingredient.toLowerCase()],
    );

    if (results.isEmpty) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(results.first['cachedAt'] as int);
    if (DateTime.now().difference(cachedAt) > cacheExpiration) {
      await db.delete('ingredient_cache', where: 'ingredient = ?', whereArgs: [ingredient.toLowerCase()]);
      return null;
    }

    final jsonList = json.decode(results.first['results'] as String) as List;
    return jsonList.map((j) => Drink.fromJson(j)).toList();
  }

  Future<void> cacheIngredientSearch(String ingredient, List<Drink> drinks) async {
    final db = await database;
    final jsonData = json.encode(drinks.map((d) => d.toJson()).toList());

    await db.insert(
      'ingredient_cache',
      {
        'ingredient': ingredient.toLowerCase(),
        'results': jsonData,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // DRINK DETAILS CACHE
  // ============================================================

  Future<Drink?> getCachedDrink(String id) async {
    final db = await database;
    final results = await db.query(
      'drink_cache',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(results.first['cachedAt'] as int);
    if (DateTime.now().difference(cachedAt) > cacheExpiration) {
      await db.delete('drink_cache', where: 'id = ?', whereArgs: [id]);
      return null;
    }

    final jsonData = json.decode(results.first['data'] as String);
    return Drink.fromJson(jsonData);
  }

  Future<void> cacheDrink(Drink drink) async {
    final db = await database;
    final jsonData = json.encode(drink.toJson());

    await db.insert(
      'drink_cache',
      {
        'id': drink.id,
        'data': jsonData,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // FILTER LIST CACHE
  // ============================================================

  Future<List<String>?> getCachedFilterList(String filterType) async {
    final db = await database;
    final results = await db.query(
      'filter_cache',
      where: 'filterType = ?',
      whereArgs: [filterType],
    );

    if (results.isEmpty) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(results.first['cachedAt'] as int);
    if (DateTime.now().difference(cachedAt) > cacheExpiration) {
      await db.delete('filter_cache', where: 'filterType = ?', whereArgs: [filterType]);
      return null;
    }

    final jsonList = json.decode(results.first['data'] as String) as List;
    return jsonList.cast<String>();
  }

  Future<void> cacheFilterList(String filterType, List<String> items) async {
    final db = await database;
    final jsonData = json.encode(items);

    await db.insert(
      'filter_cache',
      {
        'filterType': filterType,
        'data': jsonData,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // CATEGORY CACHE
  // ============================================================

  Future<List<Drink>?> getCachedCategorySearch(String category) async {
    final db = await database;
    final results = await db.query(
      'category_cache',
      where: 'category = ?',
      whereArgs: [category.toLowerCase()],
    );

    if (results.isEmpty) return null;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(results.first['cachedAt'] as int);
    if (DateTime.now().difference(cachedAt) > cacheExpiration) {
      await db.delete('category_cache', where: 'category = ?', whereArgs: [category.toLowerCase()]);
      return null;
    }

    final jsonList = json.decode(results.first['results'] as String) as List;
    return jsonList.map((j) => Drink.fromJson(j)).toList();
  }

  Future<void> cacheCategorySearch(String category, List<Drink> drinks) async {
    final db = await database;
    final jsonData = json.encode(drinks.map((d) => d.toJson()).toList());

    await db.insert(
      'category_cache',
      {
        'category': category.toLowerCase(),
        'results': jsonData,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('search_cache');
    await db.delete('ingredient_cache');
    await db.delete('category_cache');
    await db.delete('drink_cache');
    await db.delete('filter_cache');
  }

  Future<void> clearExpiredCache() async {
    final db = await database;
    final expirationTime = DateTime.now().subtract(cacheExpiration).millisecondsSinceEpoch;

    await db.delete('search_cache', where: 'cachedAt < ?', whereArgs: [expirationTime]);
    await db.delete('ingredient_cache', where: 'cachedAt < ?', whereArgs: [expirationTime]);
    await db.delete('category_cache', where: 'cachedAt < ?', whereArgs: [expirationTime]);
    await db.delete('drink_cache', where: 'cachedAt < ?', whereArgs: [expirationTime]);
    await db.delete('filter_cache', where: 'cachedAt < ?', whereArgs: [expirationTime]);
  }

  Future<Map<String, int>> getCacheStats() async {
    final db = await database;

    final searchCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM search_cache')) ?? 0;
    final ingredientCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ingredient_cache')) ?? 0;
    final categoryCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM category_cache')) ?? 0;
    final drinkCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM drink_cache')) ?? 0;
    final filterCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM filter_cache')) ?? 0;

    return {
      'searches': searchCount,
      'ingredients': ingredientCount,
      'categories': categoryCount,
      'drinks': drinkCount,
      'filters': filterCount,
      'total': searchCount + ingredientCount + categoryCount + drinkCount + filterCount,
    };
  }
}
