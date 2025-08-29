// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controller/WatchlistController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import '../core/constants/ImageAssets.dart';
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
  bool _isPressed = false;
  late Themes themes;

  @override
  void initState() {
    super.initState();
    themes = Themes();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
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
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.initialTheme.brightness == Brightness.dark;

      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                margin: widget.margin ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                    isDark
                        ? [themes.MidnightBlue, themes.DarkViolet]
                        : [themes.SoftCream, themes.SoftBlue],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: widget.elevation ?? 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTapDown: (_) => setState(() => _isPressed = true),
                    onTapUp: (_) => setState(() => _isPressed = false),
                    onTapCancel: () => setState(() => _isPressed = false),
                    onTap: _navigateToWatchlist,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color:
                        _isPressed
                            ? Colors.black.withValues(alpha: 0.05)
                            : Colors.transparent,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTitleSection(isDark),
                              _buildIconSection(isDark),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStatsSection(isDark),
                          const SizedBox(height: 8),
                          _buildProgressBar(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildTitleSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Watchlist',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : themes.DarkSlate,
          ),
        ),
        const SizedBox(height: 4),
        Obx(() {
          final watchlistController = Get.find<WatchlistController>();
          return Text(
            '${watchlistController.allWatchlistItems.length} items saved',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? themes.LavenderGray : themes.MutedPurple,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildIconSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
        isDark
            ? themes.MutedPurple.withValues(alpha: 0.3)
            : themes.MutedPurple.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.bookmark,
        size: 24,
        color: isDark ? Colors.white : themes.MutedPurple,
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return Obx(() {
      final watchlistController = Get.find<WatchlistController>();
      final items = watchlistController.allWatchlistItems;

      final courses = items.where((item) => item.itemType == 'course').length;
      final lectures = items.where((item) => item.itemType == 'lecture').length;
      final books = items.where((item) => item.itemType == 'book').length;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.school,
            count: courses,
            label: 'Courses',
            color: isDark ? themes.SoftViolet : themes.MutedPurple,
          ),
          _buildStatItem(
            icon: Icons.video_library,
            count: lectures,
            label: 'Lectures',
            color: isDark ? themes.SoftViolet : themes.MutedPurple,
          ),
          _buildStatItem(
            icon: Icons.book,
            count: books,
            label: 'Books',
            color: isDark ? themes.SoftViolet : themes.MutedPurple,
          ),
        ],
      );
    });
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return Obx(() {
      final watchlistController = Get.find<WatchlistController>();
      final items = watchlistController.allWatchlistItems;

      if (items.isEmpty) {
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: isDark ? themes.DarkSlate : themes.WarmBeige,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }

      final completed =
          items.where((item) => item.status == 'completed').length;
      final progress = items.isEmpty ? 0.0 : completed / items.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? themes.LavenderGray : themes.MutedPurple,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : themes.MutedPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? themes.DarkSlate : themes.WarmBeige,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: MediaQuery.of(context).size.width * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [themes.MutedPurple, themes.SoftViolet],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _navigateToWatchlist() {
    Get.to(() => const Watchlist(), transition: Transition.fadeIn);
  }

  void _playAnimation() {
    _animationController.reset();
    _animationController.forward();
  }
}
