import 'package:flutter/material.dart';
import '../models/drink.dart';
import '../services/drink_api_service.dart';
import '../config/app_theme.dart';
import 'drink_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({Key? key}) : super(key: key);

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filter options loaded from API
  List<String> _categories = [];
  List<String> _glassTypes = [];
  List<String> _alcoholicFilters = [];
  List<String> _ingredients = [];

  // Loading states
  bool _isLoadingFilters = true;
  bool _isLoadingDrinks = false;

  // Selected filter
  String? _selectedCategory;
  String? _selectedGlass;
  String? _selectedAlcoholic;
  String? _selectedIngredient;

  // Results
  List<Drink> _drinks = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadFilterOptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterOptions() async {
    setState(() {
      _isLoadingFilters = true;
    });

    try {
      final results = await Future.wait([
        DrinkAPIService.fetchCategories(),
        DrinkAPIService.fetchGlassTypes(),
        DrinkAPIService.fetchAlcoholicFilters(),
        DrinkAPIService.fetchIngredientsList(),
      ]);

      setState(() {
        _categories = results[0];
        _glassTypes = results[1];
        _alcoholicFilters = results[2];
        _ingredients = results[3];
        _isLoadingFilters = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load filter options';
        _isLoadingFilters = false;
      });
    }
  }

  Future<void> _searchByCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _isLoadingDrinks = true;
      _errorMessage = null;
    });

    try {
      final drinks = await DrinkAPIService.fetchDrinksByCategory(category);
      setState(() {
        _drinks = drinks;
        _isLoadingDrinks = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load drinks';
        _isLoadingDrinks = false;
      });
    }
  }

  Future<void> _searchByGlass(String glass) async {
    setState(() {
      _selectedGlass = glass;
      _isLoadingDrinks = true;
      _errorMessage = null;
    });

    try {
      final drinks = await DrinkAPIService.fetchDrinksByGlass(glass);
      setState(() {
        _drinks = drinks;
        _isLoadingDrinks = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load drinks';
        _isLoadingDrinks = false;
      });
    }
  }

  Future<void> _searchByAlcoholic(String alcoholic) async {
    setState(() {
      _selectedAlcoholic = alcoholic;
      _isLoadingDrinks = true;
      _errorMessage = null;
    });

    try {
      final drinks = await DrinkAPIService.fetchDrinksByAlcoholic(alcoholic);
      setState(() {
        _drinks = drinks;
        _isLoadingDrinks = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load drinks';
        _isLoadingDrinks = false;
      });
    }
  }

  Future<void> _searchByIngredient(String ingredient) async {
    setState(() {
      _selectedIngredient = ingredient;
      _isLoadingDrinks = true;
      _errorMessage = null;
    });

    try {
      final drinks = await DrinkAPIService.fetchDrinksByIngredient(ingredient);
      setState(() {
        _drinks = drinks;
        _isLoadingDrinks = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load drinks';
        _isLoadingDrinks = false;
      });
    }
  }

  void _clearResults() {
    setState(() {
      _drinks = [];
      _selectedCategory = null;
      _selectedGlass = null;
      _selectedAlcoholic = null;
      _selectedIngredient = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Browse',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGold,
          unselectedLabelColor: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
          indicatorColor: AppTheme.primaryGold,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Category'),
            Tab(text: 'Glass'),
            Tab(text: 'Type'),
            Tab(text: 'Ingredient'),
          ],
          onTap: (_) => _clearResults(),
        ),
      ),
      body: _isLoadingFilters
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGold),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFilterTab(_categories, _selectedCategory, _searchByCategory, 'category'),
                _buildFilterTab(_glassTypes, _selectedGlass, _searchByGlass, 'glass'),
                _buildFilterTab(_alcoholicFilters, _selectedAlcoholic, _searchByAlcoholic, 'type'),
                _buildFilterTab(_ingredients, _selectedIngredient, _searchByIngredient, 'ingredient'),
              ],
            ),
    );
  }

  Widget _buildFilterTab(
    List<String> options,
    String? selectedOption,
    Function(String) onSelect,
    String filterType,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_drinks.isNotEmpty || _isLoadingDrinks) {
      return _buildResultsView(selectedOption ?? '', filterType);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Select a $filterType to browse cocktails',
            style: TextStyle(
              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelect(option),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.textMuted.withValues(alpha: 0.15)
                              : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppTheme.primaryGold,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView(String filter, String filterType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Filter header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? AppTheme.textMuted.withValues(alpha: 0.15)
                    : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filter,
                      style: TextStyle(
                        color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_drinks.length} cocktails',
                      style: TextStyle(
                        color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _clearResults,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryGold,
                ),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),

        // Results
        Expanded(
          child: _isLoadingDrinks
              ? Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                )
              : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                    )
                  : _drinks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_bar_outlined,
                                size: 48,
                                color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No drinks found',
                                style: TextStyle(
                                  color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: _drinks.length,
                          itemBuilder: (context, index) {
                            final drink = _drinks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DrinkDetailScreen(drink: drink),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isDark
                                            ? AppTheme.textMuted.withValues(alpha: 0.15)
                                            : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Thumbnail
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: drink.thumbnailURL != null
                                              ? Image.network(
                                                  '${drink.thumbnailURL}/preview',
                                                  width: 56,
                                                  height: 56,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Container(
                                                    width: 56,
                                                    height: 56,
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? AppTheme.surfaceLight
                                                          : AppTheme.lightSurfaceVariant,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Icon(
                                                      Icons.local_bar_rounded,
                                                      color: AppTheme.primaryGold,
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  width: 56,
                                                  height: 56,
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? AppTheme.surfaceLight
                                                        : AppTheme.lightSurfaceVariant,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Icon(
                                                    Icons.local_bar_rounded,
                                                    color: AppTheme.primaryGold,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 14),
                                        // Name
                                        Expanded(
                                          child: Text(
                                            drink.name,
                                            style: TextStyle(
                                              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        // Arrow
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppTheme.primaryGold,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
