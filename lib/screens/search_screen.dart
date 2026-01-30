import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';
import '../config/app_theme.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<SearchViewModel>();
      if (viewModel.query.isNotEmpty) {
        _searchController.text = viewModel.query;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_searchController.text.isNotEmpty) {
      final viewModel = context.read<SearchViewModel>();
      viewModel.searchDrinks(_searchController.text);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SearchResultsScreen(),
        ),
      );
    }
  }

  void _onHistoryTap(String query) {
    _searchController.text = query;
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
          'Search',
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
              'Find your\nperfect cocktail',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
                height: 1.2,
                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 32),

            // Search field
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
                controller: _searchController,
                focusNode: _focusNode,
                style: TextStyle(
                  color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Old Fashioned, Margarita...',
                  hintStyle: TextStyle(
                    color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppTheme.primaryGold,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
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

            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchController.text.isNotEmpty ? _onSubmit : null,
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
                  'Search',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Search history
            Consumer<SearchViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.searchHistory.isEmpty) {
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
                                'RECENT SEARCHES',
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
                          itemCount: viewModel.searchHistory.length,
                          itemBuilder: (context, index) {
                            final query = viewModel.searchHistory[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _onHistoryTap(query),
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
                                          Icons.access_time_rounded,
                                          size: 18,
                                          color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            query,
                                            style: TextStyle(
                                              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => viewModel.removeFromHistory(query),
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
