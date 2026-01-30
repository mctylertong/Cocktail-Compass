import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/stores_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/ingredients_viewmodel.dart';
import '../services/cache_service.dart';
import '../config/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().initialize();
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
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<SettingsViewModel, ThemeViewModel>(
        builder: (context, settingsVM, themeVM, child) {
          if (!settingsVM.isInitialized) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGold,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 8),

              // Appearance Section
              _buildSectionHeader('Appearance', isDark),
              _buildSettingsCard(
                isDark: isDark,
                children: [
                  _buildThemeTile(context, themeVM, isDark),
                ],
              ),

              // Location Section
              _buildSectionHeader('Location', isDark),
              _buildSettingsCard(
                isDark: isDark,
                children: [
                  _buildLocationPermissionTile(context, settingsVM, isDark),
                  _buildDivider(isDark),
                  _buildSearchRadiusTile(context, settingsVM, isDark),
                  _buildDivider(isDark),
                  _buildDistanceUnitTile(context, settingsVM, isDark),
                ],
              ),

              // Display Section
              _buildSectionHeader('Display', isDark),
              _buildSettingsCard(
                isDark: isDark,
                children: [
                  _buildPageSizeTile(context, settingsVM, isDark),
                ],
              ),

              // Data Section
              _buildSectionHeader('Data', isDark),
              _buildSettingsCard(
                isDark: isDark,
                children: [
                  _buildClearCacheTile(context, isDark),
                  _buildDivider(isDark),
                  _buildClearHistoryTile(context, isDark),
                  _buildDivider(isDark),
                  _buildResetSettingsTile(context, settingsVM, isDark),
                ],
              ),

              // About Section
              _buildSectionHeader('About', isDark),
              _buildSettingsCard(
                isDark: isDark,
                children: [
                  _buildAboutTile(context, isDark),
                ],
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          color: AppTheme.primaryGold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.textMuted.withValues(alpha: 0.2)
              : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark
          ? AppTheme.textMuted.withValues(alpha: 0.15)
          : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeViewModel themeVM, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          themeVM.themeModeIcon,
          color: AppTheme.primaryGold,
          size: 20,
        ),
      ),
      title: Text(
        'Theme',
        style: TextStyle(
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        themeVM.themeModeLabel,
        style: TextStyle(
          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
      ),
      onTap: () => _showThemeDialog(context, themeVM, isDark),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeViewModel themeVM, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Choose Theme',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, themeVM, AppThemeMode.light, 'Light', Icons.light_mode_rounded, isDark),
            _buildThemeOption(context, themeVM, AppThemeMode.dark, 'Dark', Icons.dark_mode_rounded, isDark),
            _buildThemeOption(context, themeVM, AppThemeMode.system, 'System', Icons.brightness_auto_rounded, isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.primaryGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeViewModel themeVM, AppThemeMode mode, String label, IconData icon, bool isDark) {
    final isSelected = themeVM.themeMode == mode;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryGold : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryGold : (isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: AppTheme.primaryGold)
          : null,
      onTap: () {
        themeVM.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLocationPermissionTile(BuildContext context, SettingsViewModel settingsVM, bool isDark) {
    final hasPermission = settingsVM.hasLocationPermission;
    final statusColor = settingsVM.locationPermissionStatusColor;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          hasPermission ? Icons.location_on_rounded : Icons.location_off_rounded,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Text(
        'Location Permission',
        style: TextStyle(
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        settingsVM.locationPermissionStatusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 13,
        ),
      ),
      trailing: settingsVM.isCheckingPermission
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryGold,
              ),
            )
          : _buildLocationButton(context, settingsVM, isDark),
      onTap: () => _handleLocationPermission(context, settingsVM),
    );
  }

  Widget? _buildLocationButton(BuildContext context, SettingsViewModel settingsVM, bool isDark) {
    if (settingsVM.hasLocationPermission) {
      return Icon(Icons.check_circle_rounded, color: AppTheme.success);
    }
    if (settingsVM.isLocationPermissionDeniedForever) {
      return TextButton(
        onPressed: () => settingsVM.openAppSettings(),
        child: Text(
          'Open Settings',
          style: TextStyle(color: AppTheme.primaryGold, fontSize: 13),
        ),
      );
    }
    if (!settingsVM.locationServiceEnabled) {
      return TextButton(
        onPressed: () => settingsVM.openLocationSettings(),
        child: Text(
          'Enable',
          style: TextStyle(color: AppTheme.primaryGold, fontSize: 13),
        ),
      );
    }
    return TextButton(
      onPressed: () => _handleLocationPermission(context, settingsVM),
      child: Text(
        'Grant',
        style: TextStyle(color: AppTheme.primaryGold, fontSize: 13),
      ),
    );
  }

  Future<void> _handleLocationPermission(BuildContext context, SettingsViewModel settingsVM) async {
    if (settingsVM.hasLocationPermission) {
      await settingsVM.openAppSettings();
      await settingsVM.checkLocationPermission();
      return;
    }

    if (!settingsVM.locationServiceEnabled) {
      await settingsVM.openLocationSettings();
      await settingsVM.checkLocationPermission();
      return;
    }

    if (settingsVM.isLocationPermissionDeniedForever) {
      await settingsVM.openAppSettings();
      await settingsVM.checkLocationPermission();
      return;
    }

    final granted = await settingsVM.requestLocationPermission();
    if (granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location permission granted'),
          backgroundColor: AppTheme.surfaceLight,
        ),
      );
      context.read<StoresViewModel>().initializeLocation();
    }
  }

  Widget _buildSearchRadiusTile(BuildContext context, SettingsViewModel settingsVM, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accentCopper.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.radar_rounded,
          color: AppTheme.accentCopper,
          size: 20,
        ),
      ),
      title: Text(
        'Search Radius',
        style: TextStyle(
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        settingsVM.searchRadiusDisplay,
        style: TextStyle(
          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
      ),
      onTap: () => _showSearchRadiusDialog(context, settingsVM, isDark),
    );
  }

  void _showSearchRadiusDialog(BuildContext context, SettingsViewModel settingsVM, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Search Radius',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsViewModel.searchRadiusOptions.map((radius) {
            final displayText = settingsVM.showDistanceInMiles
                ? '${(radius * 0.000621371).toStringAsFixed(1)} miles'
                : '${(radius / 1000).toStringAsFixed(1)} km';
            final isSelected = radius == settingsVM.searchRadius;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(
                displayText,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryGold : (isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: isSelected ? Icon(Icons.check_rounded, color: AppTheme.primaryGold) : null,
              onTap: () {
                settingsVM.setSearchRadius(radius);
                context.read<StoresViewModel>().setSearchRadius(radius);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.primaryGold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceUnitTile(BuildContext context, SettingsViewModel settingsVM, bool isDark) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accentEmerald.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.straighten_rounded,
          color: AppTheme.accentEmerald,
          size: 20,
        ),
      ),
      title: Text(
        'Show Distance in Miles',
        style: TextStyle(
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        settingsVM.showDistanceInMiles ? 'Miles (mi)' : 'Kilometers (km)',
        style: TextStyle(
          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          fontSize: 13,
        ),
      ),
      value: settingsVM.showDistanceInMiles,
      activeTrackColor: AppTheme.primaryGold.withValues(alpha: 0.4),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppTheme.primaryGold;
        return isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary;
      }),
      onChanged: (value) => settingsVM.setShowDistanceInMiles(value),
    );
  }

  Widget _buildPageSizeTile(BuildContext context, SettingsViewModel settingsVM, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accentBurgundy.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.format_list_numbered_rounded,
          color: AppTheme.accentBurgundy,
          size: 20,
        ),
      ),
      title: Text(
        'Results Per Page',
        style: TextStyle(
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${settingsVM.pageSize} items',
        style: TextStyle(
          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          fontSize: 13,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
      ),
      onTap: () => _showPageSizeDialog(context, settingsVM, isDark),
    );
  }

  void _showPageSizeDialog(BuildContext context, SettingsViewModel settingsVM, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Results Per Page',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsViewModel.pageSizeOptions.map((size) {
            final isSelected = size == settingsVM.pageSize;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(
                '$size items',
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryGold : (isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: isSelected ? Icon(Icons.check_rounded, color: AppTheme.primaryGold) : null,
              onTap: () {
                settingsVM.setPageSize(size);
                context.read<SearchViewModel>().setPageSize(size);
                context.read<IngredientsViewModel>().setPageSize(size);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.primaryGold)),
          ),
        ],
      ),
    );
  }

  Widget _buildClearCacheTile(BuildContext context, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.cached_rounded,
          color: AppTheme.warning,
          size: 20,
        ),
      ),
      title: Text(
        'Clear Offline Cache',
        style: TextStyle(
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Remove cached API data',
        style: TextStyle(
          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          fontSize: 13,
        ),
      ),
      onTap: () => _showClearCacheDialog(context, isDark),
    );
  }

  void _showClearCacheDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Cache',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        content: FutureBuilder<Map<String, int>>(
          future: CacheService.instance.getCacheStats(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                ),
              );
            }
            final stats = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will clear all cached cocktail data.',
                  style: TextStyle(
                    color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cached items: ${stats['total']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...[
                  'Searches: ${stats['searches']}',
                  'Ingredients: ${stats['ingredients']}',
                  'Categories: ${stats['categories']}',
                  'Drinks: ${stats['drinks']}',
                  'Filters: ${stats['filters']}',
                ].map((text) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                    ),
                  ),
                )),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.primaryGold)),
          ),
          TextButton(
            onPressed: () async {
              await CacheService.instance.clearAllCache();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Cache cleared'),
                    backgroundColor: AppTheme.surfaceLight,
                  ),
                );
              }
            },
            child: Text('Clear', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildClearHistoryTile(BuildContext context, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.history_rounded,
          color: AppTheme.error,
          size: 20,
        ),
      ),
      title: Text(
        'Clear Search History',
        style: TextStyle(
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Remove all search history',
        style: TextStyle(
          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          fontSize: 13,
        ),
      ),
      onTap: () => _showClearHistoryDialog(context, isDark),
    );
  }

  void _showClearHistoryDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear History',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        content: Text(
          'This will remove all your search history. This action cannot be undone.',
          style: TextStyle(
            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.primaryGold)),
          ),
          TextButton(
            onPressed: () {
              context.read<SearchViewModel>().clearHistory();
              context.read<IngredientsViewModel>().clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('History cleared'),
                  backgroundColor: AppTheme.surfaceLight,
                ),
              );
            },
            child: Text('Clear', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildResetSettingsTile(BuildContext context, SettingsViewModel settingsVM, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.textMuted.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.restore_rounded,
          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          size: 20,
        ),
      ),
      title: Text(
        'Reset to Defaults',
        style: TextStyle(
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Restore all settings',
        style: TextStyle(
          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          fontSize: 13,
        ),
      ),
      onTap: () => _showResetDialog(context, settingsVM, isDark),
    );
  }

  void _showResetDialog(BuildContext context, SettingsViewModel settingsVM, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Settings',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        content: Text(
          'This will restore all settings to default values. Theme preference will not be affected.',
          style: TextStyle(
            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.primaryGold)),
          ),
          TextButton(
            onPressed: () async {
              await settingsVM.resetToDefaults();
              context.read<StoresViewModel>().setSearchRadius(SettingsViewModel.defaultSearchRadius);
              context.read<SearchViewModel>().setPageSize(SettingsViewModel.defaultPageSize);
              context.read<IngredientsViewModel>().setPageSize(SettingsViewModel.defaultPageSize);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Settings reset to defaults'),
                  backgroundColor: AppTheme.surfaceLight,
                ),
              );
            },
            child: Text('Reset', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.info_outline_rounded,
          color: AppTheme.primaryGold,
          size: 20,
        ),
      ),
      title: Text(
        'About Cocktail Compass',
        style: TextStyle(
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Version 1.0.0',
        style: TextStyle(
          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          fontSize: 13,
        ),
      ),
      onTap: () => _showAboutDialog(context, isDark),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.local_bar_rounded,
                size: 48,
                color: AppTheme.primaryGold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'COCKTAIL COMPASS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                letterSpacing: 3,
                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Discover cocktails and find nearby stores to get your ingredients.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Data provided by TheCocktailDB\nand Google Places API.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.primaryGold)),
          ),
        ],
      ),
    );
  }
}
