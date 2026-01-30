import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../widgets/drink_list_item.dart';
import '../widgets/error_widget.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/banner_ad_widget.dart';
import '../config/app_theme.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Search Results',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<SearchViewModel, FavoritesViewModel>(
        builder: (context, searchViewModel, favoritesViewModel, child) {
          if (searchViewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGold),
            );
          }

          if (searchViewModel.hasError) {
            return ErrorDisplayWidget(
              error: searchViewModel.error,
              onRetry: searchViewModel.canRetry ? () => searchViewModel.retry() : null,
            );
          }

          if (searchViewModel.drinks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No results found',
                    style: TextStyle(
                      color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${searchViewModel.query}"',
                    style: TextStyle(
                      color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to Search'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGold,
                      side: BorderSide(color: AppTheme.primaryGold.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Results for "${searchViewModel.query}"',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      searchViewModel.paginationInfo,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Results list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: searchViewModel.drinks.length,
                  itemBuilder: (context, index) {
                    final drink = searchViewModel.drinks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DrinkListItem(
                        drink: drink,
                        isFavorited: favoritesViewModel.isFavorited(drink.id),
                        showHeartButton: true,
                        onFavoriteToggle: () {
                          favoritesViewModel.toggleFavorite(drink);
                        },
                      ),
                    );
                  },
                ),
              ),

              // Pagination
              if (searchViewModel.totalPages > 1)
                PaginationControls(
                  currentPage: searchViewModel.currentPage,
                  totalPages: searchViewModel.totalPages,
                  totalItems: searchViewModel.totalResults,
                  itemsInfo: searchViewModel.paginationInfo,
                  onPreviousPage: searchViewModel.hasPreviousPage
                      ? () => searchViewModel.previousPage()
                      : null,
                  onNextPage: searchViewModel.hasNextPage
                      ? () => searchViewModel.nextPage()
                      : null,
                  onPageSelected: (page) => searchViewModel.goToPage(page),
                  compact: true,
                ),

              // Ad banner at bottom
              const BannerAdWidget(),

              // Back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGold,
                      side: BorderSide(color: AppTheme.primaryGold.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Back to Search'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
