import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/drink.dart';
import '../screens/drink_detail_screen.dart';
import '../config/app_theme.dart';

class DrinkListItem extends StatelessWidget {
  final Drink drink;
  final bool isFavorited;
  final bool showHeartButton;
  final VoidCallback onFavoriteToggle;

  const DrinkListItem({
    Key? key,
    required this.drink,
    required this.isFavorited,
    required this.showHeartButton,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppTheme.textMuted.withValues(alpha: 0.2)
                  : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // Drink image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: drink.thumbnailURL != null
                    ? CachedNetworkImage(
                        imageUrl: drink.thumbnailURL!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 64,
                          height: 64,
                          color: isDark ? AppTheme.surfaceLight : AppTheme.lightSurfaceVariant,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryGold,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 64,
                          height: 64,
                          color: isDark ? AppTheme.surfaceLight : AppTheme.lightSurfaceVariant,
                          child: Icon(
                            Icons.local_bar_rounded,
                            color: AppTheme.primaryGold.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceLight : AppTheme.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_bar_rounded,
                          color: AppTheme.primaryGold.withValues(alpha: 0.5),
                          size: 28,
                        ),
                      ),
              ),
              const SizedBox(width: 16),

              // Drink name and category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drink.name,
                      style: TextStyle(
                        color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (drink.category != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        drink.category!,
                        style: TextStyle(
                          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Favorite button or chevron
              if (showHeartButton)
                IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    color: isFavorited ? AppTheme.accentBurgundy : AppTheme.textMuted,
                  ),
                  onPressed: onFavoriteToggle,
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
