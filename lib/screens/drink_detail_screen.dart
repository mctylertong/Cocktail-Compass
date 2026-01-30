import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/drink.dart';
import '../services/drink_api_service.dart';
import '../viewmodels/shopping_list_viewmodel.dart';
import '../config/app_theme.dart';
import '../widgets/banner_ad_widget.dart';

class DrinkDetailScreen extends StatefulWidget {
  final Drink drink;

  const DrinkDetailScreen({Key? key, required this.drink}) : super(key: key);

  @override
  State<DrinkDetailScreen> createState() => _DrinkDetailScreenState();
}

class _DrinkDetailScreenState extends State<DrinkDetailScreen> {
  late Drink _drink;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _drink = widget.drink;
    if (_drink.ingredients.isEmpty || _drink.strInstructions == null) {
      _fetchDrinkDetails();
    }
  }

  Future<void> _fetchDrinkDetails() async {
    setState(() {
      _isLoading = true;
    });

    final detailedDrink = await DrinkAPIService.fetchDrinkDetails(_drink.id);
    if (detailedDrink != null && mounted) {
      setState(() {
        _drink = detailedDrink;
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.lightBackground,
      body: CustomScrollView(
        slivers: [
          // Hero Image with App Bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.lightBackground,
            leading: _buildBackButton(context, isDark),
            actions: [
              _buildActionButton(
                icon: Icons.add_shopping_cart_rounded,
                onPressed: _drink.ingredientNames.isNotEmpty
                    ? () => _addToShoppingList(context)
                    : null,
                isDark: isDark,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  if (_drink.thumbnailURL != null)
                    CachedNetworkImage(
                      imageUrl: _drink.thumbnailURL!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurfaceVariant,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurfaceVariant,
                        child: Icon(
                          Icons.local_bar_rounded,
                          size: 64,
                          color: AppTheme.primaryGold.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurfaceVariant,
                      child: Icon(
                        Icons.local_bar_rounded,
                        size: 64,
                        color: AppTheme.primaryGold.withValues(alpha: 0.5),
                      ),
                    ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 150,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            (isDark ? AppTheme.backgroundDark : AppTheme.lightBackground)
                                .withValues(alpha: 0.8),
                            isDark ? AppTheme.backgroundDark : AppTheme.lightBackground,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drink name
                  Text(
                    _drink.name,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                      color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info chips
                  if (!_isLoading) _buildInfoChips(context, isDark),

                  // Tags
                  if (_drink.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _drink.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.surfaceLight
                              : AppTheme.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Ingredients section
                  _buildSectionHeader('Ingredients', Icons.liquor_rounded, isDark),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    _buildLoadingCard(isDark)
                  else if (_drink.ingredients.isEmpty)
                    _buildEmptyState('No ingredients available', isDark)
                  else
                    _buildIngredientsCard(context, isDark),

                  const SizedBox(height: 32),

                  // Instructions section
                  _buildSectionHeader('Preparation', Icons.restaurant_menu_rounded, isDark),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    _buildLoadingCard(isDark)
                  else if (_drink.strInstructions != null && _drink.strInstructions!.isNotEmpty)
                    _buildInstructionsCard(context, isDark)
                  else
                    _buildEmptyState('No instructions available', isDark),

                  const SizedBox(height: 24),

                  // Ad banner
                  const Center(child: BannerAdWidget()),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? AppTheme.backgroundDark : Colors.white).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? AppTheme.backgroundDark : Colors.white).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(
            icon,
            color: onPressed != null
                ? AppTheme.primaryGold
                : (isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildInfoChips(BuildContext context, bool isDark) {
    final chips = <Widget>[];

    if (_drink.category != null) {
      chips.add(_buildInfoChip(
        Icons.category_rounded,
        _drink.category!,
        AppTheme.primaryGold,
        isDark,
      ));
    }

    if (_drink.glass != null) {
      chips.add(_buildInfoChip(
        Icons.local_bar_rounded,
        _drink.glass!,
        AppTheme.accentCopper,
        isDark,
      ));
    }

    if (_drink.alcoholicType != null) {
      final isAlcoholic = _drink.isAlcoholic;
      chips.add(_buildInfoChip(
        isAlcoholic ? Icons.wine_bar_rounded : Icons.no_drinks_rounded,
        _drink.alcoholicType!,
        isAlcoholic ? AppTheme.accentBurgundy : AppTheme.accentEmerald,
        isDark,
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: chips,
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: AppTheme.primaryGold,
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            color: isDark
                ? AppTheme.textMuted.withValues(alpha: 0.2)
                : AppTheme.lightTextSecondary.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.textMuted.withValues(alpha: 0.2)
              : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryGold,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.textMuted.withValues(alpha: 0.2)
              : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.textMuted.withValues(alpha: 0.2)
              : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: _drink.ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          final isLast = index == _drink.ingredients.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: AppTheme.primaryGold,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: isDark
                      ? AppTheme.textMuted.withValues(alpha: 0.1)
                      : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.textMuted.withValues(alpha: 0.2)
              : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        _drink.strInstructions!,
        style: TextStyle(
          fontSize: 15,
          height: 1.7,
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
        ),
      ),
    );
  }

  void _addToShoppingList(BuildContext context) {
    final shoppingListVM = context.read<ShoppingListViewModel>();
    final ingredients = _drink.ingredientNames;

    for (final ingredient in ingredients) {
      shoppingListVM.addItem(ingredient, fromDrink: _drink.name);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${ingredients.length} ingredients to shopping list'),
        backgroundColor: AppTheme.surfaceLight,
        action: SnackBarAction(
          label: 'View',
          textColor: AppTheme.primaryGold,
          onPressed: () {
            Navigator.pushNamed(context, '/shopping-list');
          },
        ),
      ),
    );
  }
}
