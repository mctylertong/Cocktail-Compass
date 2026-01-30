import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/drink.dart';
import '../models/store.dart';
import '../viewmodels/shopping_list_viewmodel.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  // Current database version - increment when schema changes
  static const int _dbVersion = 3;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cocktail_compass.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Favorited drinks table - stores full drink data
    await db.execute('''
      CREATE TABLE favorited_drinks (
        idDrink TEXT PRIMARY KEY,
        strDrink TEXT NOT NULL,
        strDrinkThumb TEXT,
        strInstructions TEXT,
        strIngredient1 TEXT,
        strIngredient2 TEXT,
        strIngredient3 TEXT,
        strIngredient4 TEXT,
        strIngredient5 TEXT,
        strIngredient6 TEXT,
        strIngredient7 TEXT,
        strIngredient8 TEXT,
        strIngredient9 TEXT,
        strIngredient10 TEXT,
        strIngredient11 TEXT,
        strIngredient12 TEXT,
        strIngredient13 TEXT,
        strIngredient14 TEXT,
        strIngredient15 TEXT,
        strMeasure1 TEXT,
        strMeasure2 TEXT,
        strMeasure3 TEXT,
        strMeasure4 TEXT,
        strMeasure5 TEXT,
        strMeasure6 TEXT,
        strMeasure7 TEXT,
        strMeasure8 TEXT,
        strMeasure9 TEXT,
        strMeasure10 TEXT,
        strMeasure11 TEXT,
        strMeasure12 TEXT,
        strMeasure13 TEXT,
        strMeasure14 TEXT,
        strMeasure15 TEXT,
        favoritedAt INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Search history table
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL UNIQUE,
        searchCount INTEGER NOT NULL DEFAULT 1,
        lastSearchedAt INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Ingredient search history table
    await db.execute('''
      CREATE TABLE ingredient_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient TEXT NOT NULL UNIQUE,
        searchCount INTEGER NOT NULL DEFAULT 1,
        lastSearchedAt INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Favorite stores table
    await db.execute('''
      CREATE TABLE favorite_stores (
        placeId TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        notes TEXT,
        favoritedAt INTEGER NOT NULL
      )
    ''');

    // User preferences table (key-value store)
    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Recently viewed drinks table
    await db.execute('''
      CREATE TABLE recently_viewed (
        idDrink TEXT PRIMARY KEY,
        strDrink TEXT NOT NULL,
        strDrinkThumb TEXT,
        viewedAt INTEGER NOT NULL
      )
    ''');

    // Shopping list table
    await db.execute('''
      CREATE TABLE shopping_list (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        fromDrink TEXT,
        addedAt TEXT NOT NULL,
        isChecked INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes for faster queries
    await db.execute('CREATE INDEX idx_search_history_last ON search_history(lastSearchedAt DESC)');
    await db.execute('CREATE INDEX idx_ingredient_history_last ON ingredient_history(lastSearchedAt DESC)');
    await db.execute('CREATE INDEX idx_recently_viewed_time ON recently_viewed(viewedAt DESC)');
    await db.execute('CREATE INDEX idx_favorited_drinks_time ON favorited_drinks(favoritedAt DESC)');
    await db.execute('CREATE INDEX idx_shopping_list_added ON shopping_list(addedAt DESC)');
  }

  // Handle database upgrades
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration from version 1 to version 2
      // Add new columns to favorited_drinks
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient1 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient2 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient3 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient4 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient5 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient6 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient7 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient8 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient9 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient10 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient11 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient12 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient13 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient14 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strIngredient15 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure1 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure2 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure3 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure4 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure5 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure6 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure7 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure8 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure9 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure10 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure11 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure12 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure13 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure14 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN strMeasure15 TEXT');
      await db.execute('ALTER TABLE favorited_drinks ADD COLUMN favoritedAt INTEGER NOT NULL DEFAULT 0');

      // Create new tables
      await db.execute('''
        CREATE TABLE IF NOT EXISTS search_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          query TEXT NOT NULL UNIQUE,
          searchCount INTEGER NOT NULL DEFAULT 1,
          lastSearchedAt INTEGER NOT NULL,
          createdAt INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS ingredient_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ingredient TEXT NOT NULL UNIQUE,
          searchCount INTEGER NOT NULL DEFAULT 1,
          lastSearchedAt INTEGER NOT NULL,
          createdAt INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS favorite_stores (
          placeId TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          address TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          notes TEXT,
          favoritedAt INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_preferences (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updatedAt INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS recently_viewed (
          idDrink TEXT PRIMARY KEY,
          strDrink TEXT NOT NULL,
          strDrinkThumb TEXT,
          viewedAt INTEGER NOT NULL
        )
      ''');

      // Create indexes
      await db.execute('CREATE INDEX IF NOT EXISTS idx_search_history_last ON search_history(lastSearchedAt DESC)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_ingredient_history_last ON ingredient_history(lastSearchedAt DESC)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_recently_viewed_time ON recently_viewed(viewedAt DESC)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_favorited_drinks_time ON favorited_drinks(favoritedAt DESC)');
    }

    if (oldVersion < 3) {
      // Migration from version 2 to version 3 - add shopping list
      await db.execute('''
        CREATE TABLE IF NOT EXISTS shopping_list (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          fromDrink TEXT,
          addedAt TEXT NOT NULL,
          isChecked INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_shopping_list_added ON shopping_list(addedAt DESC)');
    }
  }

  // ============================================================
  // FAVORITED DRINKS METHODS
  // ============================================================

  Future<List<Drink>> fetchFavoritedDrinks() async {
    final db = await instance.database;
    final results = await db.query(
      'favorited_drinks',
      orderBy: 'favoritedAt DESC',
    );

    return results.map((json) => Drink(
      idDrink: json['idDrink'] as String,
      strDrink: json['strDrink'] as String,
      strDrinkThumb: json['strDrinkThumb'] as String?,
      strInstructions: json['strInstructions'] as String?,
      strIngredient1: json['strIngredient1'] as String?,
      strIngredient2: json['strIngredient2'] as String?,
      strIngredient3: json['strIngredient3'] as String?,
      strIngredient4: json['strIngredient4'] as String?,
      strIngredient5: json['strIngredient5'] as String?,
      strIngredient6: json['strIngredient6'] as String?,
      strIngredient7: json['strIngredient7'] as String?,
      strIngredient8: json['strIngredient8'] as String?,
      strIngredient9: json['strIngredient9'] as String?,
      strIngredient10: json['strIngredient10'] as String?,
      strIngredient11: json['strIngredient11'] as String?,
      strIngredient12: json['strIngredient12'] as String?,
      strIngredient13: json['strIngredient13'] as String?,
      strIngredient14: json['strIngredient14'] as String?,
      strIngredient15: json['strIngredient15'] as String?,
      strMeasure1: json['strMeasure1'] as String?,
      strMeasure2: json['strMeasure2'] as String?,
      strMeasure3: json['strMeasure3'] as String?,
      strMeasure4: json['strMeasure4'] as String?,
      strMeasure5: json['strMeasure5'] as String?,
      strMeasure6: json['strMeasure6'] as String?,
      strMeasure7: json['strMeasure7'] as String?,
      strMeasure8: json['strMeasure8'] as String?,
      strMeasure9: json['strMeasure9'] as String?,
      strMeasure10: json['strMeasure10'] as String?,
      strMeasure11: json['strMeasure11'] as String?,
      strMeasure12: json['strMeasure12'] as String?,
      strMeasure13: json['strMeasure13'] as String?,
      strMeasure14: json['strMeasure14'] as String?,
      strMeasure15: json['strMeasure15'] as String?,
    )).toList();
  }

  Future<void> addFavoritedDrink(Drink drink) async {
    final db = await instance.database;
    await db.insert(
      'favorited_drinks',
      {
        'idDrink': drink.id,
        'strDrink': drink.name,
        'strDrinkThumb': drink.thumbnailURL,
        'strInstructions': drink.strInstructions,
        'strIngredient1': drink.strIngredient1,
        'strIngredient2': drink.strIngredient2,
        'strIngredient3': drink.strIngredient3,
        'strIngredient4': drink.strIngredient4,
        'strIngredient5': drink.strIngredient5,
        'strIngredient6': drink.strIngredient6,
        'strIngredient7': drink.strIngredient7,
        'strIngredient8': drink.strIngredient8,
        'strIngredient9': drink.strIngredient9,
        'strIngredient10': drink.strIngredient10,
        'strIngredient11': drink.strIngredient11,
        'strIngredient12': drink.strIngredient12,
        'strIngredient13': drink.strIngredient13,
        'strIngredient14': drink.strIngredient14,
        'strIngredient15': drink.strIngredient15,
        'strMeasure1': drink.strMeasure1,
        'strMeasure2': drink.strMeasure2,
        'strMeasure3': drink.strMeasure3,
        'strMeasure4': drink.strMeasure4,
        'strMeasure5': drink.strMeasure5,
        'strMeasure6': drink.strMeasure6,
        'strMeasure7': drink.strMeasure7,
        'strMeasure8': drink.strMeasure8,
        'strMeasure9': drink.strMeasure9,
        'strMeasure10': drink.strMeasure10,
        'strMeasure11': drink.strMeasure11,
        'strMeasure12': drink.strMeasure12,
        'strMeasure13': drink.strMeasure13,
        'strMeasure14': drink.strMeasure14,
        'strMeasure15': drink.strMeasure15,
        'favoritedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFavoritedDrink(String drinkId) async {
    final db = await instance.database;
    await db.delete(
      'favorited_drinks',
      where: 'idDrink = ?',
      whereArgs: [drinkId],
    );
  }

  Future<bool> isFavorited(String drinkId) async {
    final db = await instance.database;
    final results = await db.query(
      'favorited_drinks',
      where: 'idDrink = ?',
      whereArgs: [drinkId],
    );
    return results.isNotEmpty;
  }

  Future<int> getFavoritesCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM favorited_drinks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============================================================
  // SEARCH HISTORY METHODS
  // ============================================================

  Future<List<SearchHistoryEntry>> getSearchHistory({int limit = 10}) async {
    final db = await instance.database;
    final results = await db.query(
      'search_history',
      orderBy: 'lastSearchedAt DESC',
      limit: limit,
    );

    return results.map((row) => SearchHistoryEntry(
      id: row['id'] as int,
      query: row['query'] as String,
      searchCount: row['searchCount'] as int,
      lastSearchedAt: DateTime.fromMillisecondsSinceEpoch(row['lastSearchedAt'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
    )).toList();
  }

  Future<void> addSearchQuery(String query) async {
    final db = await instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Try to update existing entry first
    final updated = await db.rawUpdate('''
      UPDATE search_history
      SET searchCount = searchCount + 1, lastSearchedAt = ?
      WHERE query = ?
    ''', [now, query]);

    // If no existing entry, insert new one
    if (updated == 0) {
      await db.insert('search_history', {
        'query': query,
        'searchCount': 1,
        'lastSearchedAt': now,
        'createdAt': now,
      });
    }
  }

  Future<void> deleteSearchHistoryEntry(String query) async {
    final db = await instance.database;
    await db.delete(
      'search_history',
      where: 'query = ?',
      whereArgs: [query],
    );
  }

  Future<void> clearSearchHistory() async {
    final db = await instance.database;
    await db.delete('search_history');
  }

  // ============================================================
  // INGREDIENT HISTORY METHODS
  // ============================================================

  Future<List<IngredientHistoryEntry>> getIngredientHistory({int limit = 10}) async {
    final db = await instance.database;
    final results = await db.query(
      'ingredient_history',
      orderBy: 'lastSearchedAt DESC',
      limit: limit,
    );

    return results.map((row) => IngredientHistoryEntry(
      id: row['id'] as int,
      ingredient: row['ingredient'] as String,
      searchCount: row['searchCount'] as int,
      lastSearchedAt: DateTime.fromMillisecondsSinceEpoch(row['lastSearchedAt'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
    )).toList();
  }

  Future<void> addIngredientSearch(String ingredient) async {
    final db = await instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Try to update existing entry first
    final updated = await db.rawUpdate('''
      UPDATE ingredient_history
      SET searchCount = searchCount + 1, lastSearchedAt = ?
      WHERE ingredient = ?
    ''', [now, ingredient]);

    // If no existing entry, insert new one
    if (updated == 0) {
      await db.insert('ingredient_history', {
        'ingredient': ingredient,
        'searchCount': 1,
        'lastSearchedAt': now,
        'createdAt': now,
      });
    }
  }

  Future<void> deleteIngredientHistoryEntry(String ingredient) async {
    final db = await instance.database;
    await db.delete(
      'ingredient_history',
      where: 'ingredient = ?',
      whereArgs: [ingredient],
    );
  }

  Future<void> clearIngredientHistory() async {
    final db = await instance.database;
    await db.delete('ingredient_history');
  }

  // ============================================================
  // FAVORITE STORES METHODS
  // ============================================================

  Future<List<Store>> getFavoriteStores() async {
    final db = await instance.database;
    final results = await db.query(
      'favorite_stores',
      orderBy: 'favoritedAt DESC',
    );

    return results.map((row) => Store(
      id: row['placeId'] as String,
      name: row['name'] as String,
      address: row['address'] as String,
      coordinate: LatLng(
        row['latitude'] as double,
        row['longitude'] as double,
      ),
    )).toList();
  }

  Future<void> addFavoriteStore(Store store, {String? notes}) async {
    final db = await instance.database;
    await db.insert(
      'favorite_stores',
      {
        'placeId': store.id,
        'name': store.name,
        'address': store.address,
        'latitude': store.coordinate.latitude,
        'longitude': store.coordinate.longitude,
        'notes': notes,
        'favoritedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFavoriteStore(String placeId) async {
    final db = await instance.database;
    await db.delete(
      'favorite_stores',
      where: 'placeId = ?',
      whereArgs: [placeId],
    );
  }

  Future<bool> isStoreFavorited(String placeId) async {
    final db = await instance.database;
    final results = await db.query(
      'favorite_stores',
      where: 'placeId = ?',
      whereArgs: [placeId],
    );
    return results.isNotEmpty;
  }

  Future<void> updateStoreNotes(String placeId, String notes) async {
    final db = await instance.database;
    await db.update(
      'favorite_stores',
      {'notes': notes},
      where: 'placeId = ?',
      whereArgs: [placeId],
    );
  }

  // ============================================================
  // USER PREFERENCES METHODS
  // ============================================================

  Future<String?> getPreference(String key) async {
    final db = await instance.database;
    final results = await db.query(
      'user_preferences',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (results.isEmpty) return null;
    return results.first['value'] as String;
  }

  Future<void> setPreference(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'user_preferences',
      {
        'key': key,
        'value': value,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deletePreference(String key) async {
    final db = await instance.database;
    await db.delete(
      'user_preferences',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<Map<String, String>> getAllPreferences() async {
    final db = await instance.database;
    final results = await db.query('user_preferences');

    return Map.fromEntries(
      results.map((row) => MapEntry(
        row['key'] as String,
        row['value'] as String,
      )),
    );
  }

  // ============================================================
  // RECENTLY VIEWED METHODS
  // ============================================================

  Future<List<Drink>> getRecentlyViewed({int limit = 20}) async {
    final db = await instance.database;
    final results = await db.query(
      'recently_viewed',
      orderBy: 'viewedAt DESC',
      limit: limit,
    );

    return results.map((json) => Drink(
      idDrink: json['idDrink'] as String,
      strDrink: json['strDrink'] as String,
      strDrinkThumb: json['strDrinkThumb'] as String?,
    )).toList();
  }

  Future<void> addRecentlyViewed(Drink drink) async {
    final db = await instance.database;
    await db.insert(
      'recently_viewed',
      {
        'idDrink': drink.id,
        'strDrink': drink.name,
        'strDrinkThumb': drink.thumbnailURL,
        'viewedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Keep only the most recent 50 entries
    await db.execute('''
      DELETE FROM recently_viewed
      WHERE idDrink NOT IN (
        SELECT idDrink FROM recently_viewed
        ORDER BY viewedAt DESC
        LIMIT 50
      )
    ''');
  }

  Future<void> clearRecentlyViewed() async {
    final db = await instance.database;
    await db.delete('recently_viewed');
  }

  // ============================================================
  // SHOPPING LIST METHODS
  // ============================================================

  Future<List<ShoppingItem>> getShoppingList() async {
    final db = await instance.database;
    final results = await db.query(
      'shopping_list',
      orderBy: 'addedAt DESC',
    );

    return results.map((row) => ShoppingItem(
      id: row['id'] as String,
      name: row['name'] as String,
      fromDrink: row['fromDrink'] as String?,
      addedAt: DateTime.parse(row['addedAt'] as String),
      isChecked: (row['isChecked'] as int) == 1,
    )).toList();
  }

  Future<void> addShoppingItem(ShoppingItem item) async {
    final db = await instance.database;
    await db.insert(
      'shopping_list',
      {
        'id': item.id,
        'name': item.name,
        'fromDrink': item.fromDrink,
        'addedAt': item.addedAt.toIso8601String(),
        'isChecked': item.isChecked ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateShoppingItem(ShoppingItem item) async {
    final db = await instance.database;
    await db.update(
      'shopping_list',
      {
        'name': item.name,
        'fromDrink': item.fromDrink,
        'isChecked': item.isChecked ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteShoppingItem(String id) async {
    final db = await instance.database;
    await db.delete(
      'shopping_list',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearShoppingList() async {
    final db = await instance.database;
    await db.delete('shopping_list');
  }

  // ============================================================
  // SETTINGS METHODS
  // ============================================================

  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final results = await db.query(
      'user_preferences',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (results.isEmpty) return null;
    return results.first['value'] as String?;
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'user_preferences',
      {
        'key': key,
        'value': value,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSetting(String key) async {
    final db = await instance.database;
    await db.delete(
      'user_preferences',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('favorited_drinks');
    await db.delete('search_history');
    await db.delete('ingredient_history');
    await db.delete('favorite_stores');
    await db.delete('user_preferences');
    await db.delete('recently_viewed');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

// ============================================================
// DATA MODELS FOR HISTORY ENTRIES
// ============================================================

class SearchHistoryEntry {
  final int id;
  final String query;
  final int searchCount;
  final DateTime lastSearchedAt;
  final DateTime createdAt;

  SearchHistoryEntry({
    required this.id,
    required this.query,
    required this.searchCount,
    required this.lastSearchedAt,
    required this.createdAt,
  });
}

class IngredientHistoryEntry {
  final int id;
  final String ingredient;
  final int searchCount;
  final DateTime lastSearchedAt;
  final DateTime createdAt;

  IngredientHistoryEntry({
    required this.id,
    required this.ingredient,
    required this.searchCount,
    required this.lastSearchedAt,
    required this.createdAt,
  });
}
