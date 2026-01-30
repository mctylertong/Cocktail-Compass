import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'ingredients_screen.dart';
import 'drink_detail_screen.dart';
import 'browse_screen.dart';
import '../services/drink_api_service.dart';
import '../config/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingRandom = false;

  Future<void> _fetchRandomCocktail() async {
    setState(() {
      _isLoadingRandom = true;
    });

    try {
      final drink = await DrinkAPIService.fetchRandomCocktail();
      if (drink != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DrinkDetailScreen(drink: drink)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch random cocktail')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRandom = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Elegant App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'COCKTAIL COMPASS',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 1,
                        color: AppTheme.primaryGold,
                      ),
                    ],
                  ),
                ),
              ),

              // Main Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 40),

                    // Welcome Section
                    _buildWelcomeSection(),

                    const SizedBox(height: 48),

                    // Menu Cards
                    _buildMenuCard(
                      icon: Icons.search_rounded,
                      title: 'Search Cocktails',
                      subtitle: 'Find your perfect drink by name',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildMenuCard(
                      icon: Icons.liquor_rounded,
                      title: 'By Ingredient',
                      subtitle: 'Discover what you can make',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IngredientsScreen()),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildMenuCard(
                      icon: Icons.explore_rounded,
                      title: 'Browse Collection',
                      subtitle: 'Explore by category or spirit',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BrowseScreen()),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Divider with text
                    _buildDividerWithText('or let us guide you'),

                    const SizedBox(height: 32),

                    // Featured Actions Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureButton(
                            icon: Icons.casino_rounded,
                            label: 'Surprise Me',
                            isLoading: _isLoadingRandom,
                            onTap: _isLoadingRandom ? null : _fetchRandomCocktail,
                            accentColor: AppTheme.accentCopper,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFeatureButton(
                            icon: Icons.smart_toy_rounded,
                            label: 'AI Bartender',
                            onTap: () => Navigator.pushNamed(context, '/ai-bartender'),
                            accentColor: AppTheme.accentEmerald,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'What shall we\nprepare tonight?',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.textMuted.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.textMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.textMuted.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.textMuted.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color accentColor,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accentColor,
                        ),
                      )
                    : Icon(
                        icon,
                        color: accentColor,
                        size: 28,
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
