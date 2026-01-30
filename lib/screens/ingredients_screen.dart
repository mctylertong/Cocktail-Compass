import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ingredients_viewmodel.dart';
import '../config/app_theme.dart';
import 'ingredient_results_screen.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({Key? key}) : super(key: key);

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<IngredientsViewModel>();
      if (viewModel.ingredient.isNotEmpty) {
        _ingredientController.text = viewModel.ingredient;
      }
    });
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_ingredientController.text.isNotEmpty) {
      final viewModel = context.read<IngredientsViewModel>();
      viewModel.fetchDrinksByIngredient(_ingredientController.text);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const IngredientResultsScreen(),
        ),
      );
    }
  }

  void _onHistoryTap(String ingredient) {
    _ingredientController.text = ingredient;
    _onSubmit();
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
          'Ingredients',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // Header text
            Text(
              'Search by\ningredient',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
                height: 1.2,
                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 32),

            // Input field
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppTheme.textMuted.withValues(alpha: 0.2)
                      : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
                ),
              ),
              child: TextField(
                controller: _ingredientController,
                focusNode: _focusNode,
                style: TextStyle(
                  color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Whiskey, Tequila, Lime...',
                  hintStyle: TextStyle(
                    color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.local_bar_rounded,
                    color: AppTheme.primaryGold,
                  ),
                  suffixIcon: _ingredientController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                          ),
                          onPressed: () {
                            _ingredientController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _onSubmit(),
                textInputAction: TextInputAction.search,
              ),
            ),
            const SizedBox(height: 20),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _ingredientController.text.isNotEmpty ? _onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: AppTheme.backgroundDark,
                  disabledBackgroundColor: isDark
                      ? AppTheme.surfaceLight
                      : AppTheme.lightSurfaceVariant,
                  disabledForegroundColor: isDark
                      ? AppTheme.textMuted
                      : AppTheme.lightTextSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Find Cocktails',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Ingredient history
            Consumer<IngredientsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.ingredientHistory.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 18,
                                color: AppTheme.primaryGold,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'RECENT INGREDIENTS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                  color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => viewModel.clearHistory(),
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                color: AppTheme.primaryGold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: viewModel.ingredientHistory.length,
                          itemBuilder: (context, index) {
                            final ingredient = viewModel.ingredientHistory[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _onHistoryTap(ingredient),
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
                                        Icon(
                                          Icons.local_bar_outlined,
                                          size: 18,
                                          color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            ingredient,
                                            style: TextStyle(
                                              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => viewModel.removeFromHistory(ingredient),
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 18,
                                            color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                                          ),
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
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
