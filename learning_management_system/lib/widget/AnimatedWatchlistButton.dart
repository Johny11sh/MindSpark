// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:get/get.dart';
import '../controller/WatchlistController.dart';
import '../themes/Themes.dart';

class AnimatedWatchlistButton extends StatefulWidget {
  final String itemId;
  final String itemType;
  final String itemTitle;
  final String itemImage;
  final double size;
  final Color? color;
  final Color? activeColor;
  final bool isCourse; // Different animation for courses vs books

  const AnimatedWatchlistButton({
    super.key,
    required this.itemId,
    required this.itemType,
    required this.itemTitle,
    required this.itemImage,
    this.size = 24.0,
    this.color,
    this.activeColor,
    this.isCourse = false,
  });

  @override
  State<AnimatedWatchlistButton> createState() =>
      _AnimatedWatchlistButtonState();
}

class _AnimatedWatchlistButtonState extends State<AnimatedWatchlistButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  late Themes themes;

  @override
  void initState() {
    super.initState();
    themes = Themes();

    // Scale animation for press effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Rotation animation for course bookmark
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Bounce animation for book bookmark
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Pulse animation for active state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.elasticOut),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
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

      // Start pulse animation if item is in watchlist
      if (isInWatchlist && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      } else if (!isInWatchlist && _pulseController.isAnimating) {
        _pulseController.stop();
      }

      return GestureDetector(
        onTapDown: (_) {
          _scaleController.forward();
        },
        onTapUp: (_) {
          _scaleController.reverse();
        },
        onTapCancel: () {
          _scaleController.reverse();
        },
        onTap: () => _toggleWatchlist(watchlistController),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _rotationAnimation,
            _bounceAnimation,
            _pulseAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale:
                  _scaleAnimation.value *
                  (isInWatchlist ? _pulseAnimation.value : 1.0),
              child: Transform.rotate(
                angle:
                    isInWatchlist && widget.isCourse
                        ? _rotationAnimation.value
                        : 0.0,
                child: Transform.scale(
                  scale:
                      isInWatchlist && !widget.isCourse
                          ? _bounceAnimation.value
                          : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            isInWatchlist
                                ? [
                                  widget.activeColor ?? themes.MutedPurple,
                                  (widget.activeColor ?? themes.MutedPurple)
                                      .withOpacity(0.8),
                                ]
                                : [
                                  widget.color ?? themes.LavenderGray,
                                  (widget.color ?? themes.LavenderGray)
                                      .withOpacity(0.8),
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isInWatchlist
                                  ? (widget.activeColor ?? themes.MutedPurple)
                                  : (widget.color ?? themes.LavenderGray))
                              .withOpacity(0.3),
                          blurRadius: isInWatchlist ? 8 : 4,
                          spreadRadius: isInWatchlist ? 2 : 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: widget.size,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          isInWatchlist
                              ? Icons.bookmark
                              : Icons.bookmark_add_outlined,
                          key: ValueKey('${isInWatchlist}_${widget.isCourse}'),
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () => _toggleWatchlist(watchlistController),
                      tooltip:
                          isInWatchlist
                              ? 'Remove from Watchlist'
                              : 'Add to Watchlist',
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
    // Enhanced animation sequence based on type
    if (widget.isCourse) {
      // Course animation: rotation + scale
      _rotationController.forward().then((_) {
        _rotationController.reverse();
      });
    } else {
      // Book animation: bounce + scale
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }

    // Add haptic feedback
    HapticFeedback.mediumImpact();

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

    // Show enhanced feedback with animation
    Future.delayed(const Duration(milliseconds: 200), () {
      final isInWatchlist = watchlistController.isInWatchlist(
        widget.itemId,
        widget.itemType,
      );

      final bool isCourseType = widget.itemType == 'course';

      final String title =
          isInWatchlist
              ? (isCourseType ? '📚 Course Added!' : '📖 Book Added!')
              : (isCourseType ? '📚 Course Removed' : '📖 Book Removed');

      final Color bgColor =
          isCourseType
              ? (isInWatchlist
                  ? themes.SoftBlue.withOpacity(0.9)
                  : themes.SoftBlue.withOpacity(0.5))
              : (isInWatchlist
                  ? themes.MutedGreen.withOpacity(0.9)
                  : themes.SoftPink.withOpacity(0.9));

      final Color fgColor =
          isCourseType
              ? themes.DarkSlate
              : (isInWatchlist ? themes.DarkEmerald : themes.DeepCoral);

      final Icon leadingIcon =
          isCourseType
              ? Icon(Icons.school, color: themes.DarkSlate)
              : Icon(
                isInWatchlist ? Icons.check_circle : Icons.remove_circle,
                color: isInWatchlist ? themes.DarkEmerald : themes.DeepCoral,
              );

      Get.snackbar(
        title,
        isInWatchlist
            ? 'Added to your watchlist'
            : 'Removed from your watchlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: bgColor,
        colorText: fgColor,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: leadingIcon,
        shouldIconPulse: true,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.elasticOut,
        reverseAnimationCurve: Curves.easeInOut,
      );
    });
  }
}
