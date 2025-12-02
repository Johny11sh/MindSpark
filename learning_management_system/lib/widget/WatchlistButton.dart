// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:get/get.dart';
import '../controller/WatchlistController.dart';
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
  bool _isPressed = false;
  late Themes themes;

  @override
  void initState() {
    super.initState();
    themes = Themes();
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watchlistController = Get.find<WatchlistController>();

    return Obx(() {
      final isInWatchlist = watchlistController.isInWatchlist(
        widget.itemId,
        widget.itemType,
      );

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
                            ? (isInWatchlist
                                ? themes.SoftViolet.withOpacity(0.2)
                                : themes.LavenderGray.withOpacity(0.2))
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
                      color:
                          isInWatchlist
                              ? (widget.activeColor ?? themes.SoftViolet)
                              : (widget.color ?? themes.LavenderGray),
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
    } else if (widget.itemType == 'book' || widget.itemType == 'resource') {
      watchlistController.toggleResourceWatchlist(
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
        backgroundColor: isInWatchlist ? themes.MutedGreen : themes.SoftPink,
        colorText: isInWatchlist ? themes.DarkEmerald : themes.DeepCoral,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        icon: Icon(
          isInWatchlist ? Icons.check_circle : Icons.remove_circle,
          color: isInWatchlist ? themes.DarkEmerald : themes.DeepCoral,
        ),
      );
    });
  }
}
