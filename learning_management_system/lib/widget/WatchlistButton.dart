// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:get/get.dart';
import '../controller/WatchlistController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';

class WatchlistButton extends StatefulWidget {
  final String itemId;
  final String itemType;
  final String itemTitle;
  final String itemImage;
  final double size;
  final Color? color;
  final Color? activeColor;

  const WatchlistButton({
    super.key,
    required this.itemId,
    required this.itemType,
    required this.itemTitle,
    required this.itemImage,
    this.size = 24.0,
    this.color,
    this.activeColor,
  });

  @override
  State<WatchlistButton> createState() => _WatchlistButtonState();
}

class _WatchlistButtonState extends State<WatchlistButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.bounceOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watchlistController = Get.find<WatchlistController>();
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

    return Obx(() {
      final isInWatchlist = watchlistController.isInWatchlist(
        widget.itemId,
        widget.itemType,
      );

      final buttonColor =
          isInWatchlist
              ? (widget.activeColor ?? primaryColor)
              : (widget.color ?? primaryColor.withOpacity(0.5));

      return GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        onTap: () => _toggleWatchlist(watchlistController),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? 0.9 : _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 3.14159,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _isPressed
                            ? buttonColor.withOpacity(0.2)
                            : Colors.transparent,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                      key: ValueKey(isInWatchlist),
                      size: widget.size,
                      color: buttonColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _toggleWatchlist(WatchlistController watchlistController) {
    // Enhanced animation sequence
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Use actual API calls
    if (widget.itemType == 'lecture') {
      watchlistController.toggleLectureWatchlist(
        widget.itemId,
        widget.itemTitle,
        widget.itemImage,
      );
    } else if (widget.itemType == 'course') {
      watchlistController.toggleCourseWatchlist(
        widget.itemId,
        widget.itemTitle,
        widget.itemImage,
      );
    } else if (widget.itemType == 'book') {
      watchlistController.toggleBookWatchlist(
        widget.itemId,
        widget.itemTitle,
        widget.itemImage,
      );
    }

    // Show feedback with enhanced animation
    Future.delayed(const Duration(milliseconds: 150), () {
      final isInWatchlist = watchlistController.isInWatchlist(
        widget.itemId,
        widget.itemType,
      );

      Get.snackbar(
        isInWatchlist ? 'Added to Watchlist' : 'Removed from Watchlist',
        '${widget.itemTitle} has been ${isInWatchlist ? 'added to' : 'removed from'} your watchlist',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: isInWatchlist ? Colors.green[100] : Colors.orange[100],
        colorText: isInWatchlist ? Colors.green[800] : Colors.orange[800],
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        icon: Icon(
          isInWatchlist ? Icons.check_circle : Icons.remove_circle,
          color: isInWatchlist ? Colors.green[800] : Colors.orange[800],
        ),
      );
    });
  }
}
