// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/FontController.dart';
import '../controller/WatchlistController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import '../view/Watchlist.dart';

class WatchlistSummaryCard extends StatefulWidget {
  final bool showAnimation;
  final EdgeInsets? margin;
  final double? elevation;

  const WatchlistSummaryCard({
    super.key,
    this.showAnimation = true,
    this.margin,
    this.elevation,
  });

  @override
  State<WatchlistSummaryCard> createState() => _WatchlistSummaryCardState();
}

class _WatchlistSummaryCardState extends State<WatchlistSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;
    final Color primaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);
    final Color secondaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 210, 209, 224)
            : const Color.fromARGB(255, 40, 41, 61);

    final watchlistController = Get.find<WatchlistController>();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Container(
                margin: widget.margin ?? const EdgeInsets.all(16),
                child: InkWell(
                  onTap: () => _navigateToWatchlist(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(primaryColor, secondaryColor),
                          const SizedBox(height: 16),
                          _buildStats(watchlistController, primaryColor),
                          const SizedBox(height: 16),
                          _buildActionButton(primaryColor, secondaryColor),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Color primaryColor, Color secondaryColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.bookmark, color: primaryColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Watchlist',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontController().currentFontFamily,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track your learning progress',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: FontController().currentFontFamily,
                  color: primaryColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, color: primaryColor, size: 20),
      ],
    );
  }

  Widget _buildStats(
    WatchlistController watchlistController,
    Color primaryColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Total Items',
            '${watchlistController.allWatchlistItems.length}',
            Icons.list_alt,
            primaryColor,
          ),
        ),
        Container(width: 1, height: 40, color: primaryColor.withOpacity(0.3)),
        Expanded(
          child: _buildStatItem(
            'Active',
            '${watchlistController.allWatchlistItems.where((item) => item.status == 'active').length}',
            Icons.play_circle_outline,
            primaryColor,
          ),
        ),
        Container(width: 1, height: 40, color: primaryColor.withOpacity(0.3)),
        Expanded(
          child: _buildStatItem(
            'Completed',
            '${watchlistController.allWatchlistItems.where((item) => item.status == 'completed').length}',
            Icons.check_circle_outline,
            primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color primaryColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: FontController().currentFontFamily,
            color: primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: FontController().currentFontFamily,
            color: primaryColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(Color primaryColor, Color secondaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility, color: primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'View Full Watchlist',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: FontController().currentFontFamily,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToWatchlist() {
    Get.to(() => const Watchlist());
  }
}
