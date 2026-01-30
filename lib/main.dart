import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/loading_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/ai_bartender_screen.dart';
import 'viewmodels/favorites_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/ingredients_viewmodel.dart';
import 'viewmodels/stores_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/shopping_list_viewmodel.dart';
import 'viewmodels/ai_bartender_viewmodel.dart';
import 'services/database_service.dart';
import 'services/ad_service.dart';
import 'config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await DatabaseService.instance.database;

  // Initialize Mobile Ads SDK
  await AdService.instance.initialize();

  // Initialize theme before running app
  final themeViewModel = ThemeViewModel();
  await themeViewModel.initialize();

  runApp(CocktailCompassApp(themeViewModel: themeViewModel));
}

class CocktailCompassApp extends StatelessWidget {
  final ThemeViewModel themeViewModel;

  const CocktailCompassApp({Key? key, required this.themeViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme state management - initialized before app starts
        ChangeNotifierProvider.value(value: themeViewModel),
        // Global state management - all ViewModels are now shared across screens
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => IngredientsViewModel()),
        ChangeNotifierProvider(create: (_) => StoresViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => ShoppingListViewModel()),
        ChangeNotifierProvider(create: (_) => AIBartenderViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, child) {
          return MaterialApp(
            title: 'Cocktail Compass',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeVM.materialThemeMode,
            home: const LoadingScreen(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/shopping-list': (context) => const ShoppingListScreen(),
              '/ai-bartender': (context) => const AIBartenderScreen(),
            },
          );
        },
      ),
    );
  }
}
