// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/WatchlistModel.dart';
import '../controller/WatchlistController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';

class WatchlistItemCard extends StatefulWidget {
  final WatchlistModel item;
  final VoidCallback? onRemove;
  final VoidCallback? onStatusChange;
  final bool showActions;
  final EdgeInsets? margin;

  const WatchlistItemCard({
    super.key,
    required this.item,
    this.onRemove,
    this.onStatusChange,
    this.showActions = true,
    this.margin,
  });

  @override
  State<WatchlistItemCard> createState() => _WatchlistItemCardState();
}

class _WatchlistItemCardState extends State<WatchlistItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;
  bool _isHovered = false;
  late Themes themes;

  @override
  void initState() {
    super.initState();
    themes = Themes();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
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
                margin:
                widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? themes.MidnightBlue : themes.SoftCream,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onItemTap,
                    onTapDown: (_) => setState(() => _isPressed = true),
                    onTapUp: (_) => setState(() => _isPressed = false),
                    onTapCancel: () => setState(() => _isPressed = false),
                    onHover: (hovered) => setState(() => _isHovered = hovered),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color:
                        _isPressed
                            ? Colors.black.withValues(alpha: 0.05)
                            : Colors.transparent,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageSection(isDark),
                          const SizedBox(width: 16),
                          Expanded(child: _buildContentSection(isDark)),
                          if (widget.showActions) _buildActionsSection(isDark),
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

  Widget _buildImageSection(bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? themes.DarkSlate : themes.WarmBeige,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
        widget.item.itemImage != null && widget.item.itemImage!.isNotEmpty
            ? Image.network(
          widget.item.itemImage!,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
              _buildPlaceholderIcon(isDark),
        )
            : _buildPlaceholderIcon(isDark),
      ),
    );
  }

  Widget _buildPlaceholderIcon(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? themes.DarkSlate : themes.WarmBeige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getItemTypeIcon(widget.item.itemType),
        size: 32,
        color: isDark ? themes.LavenderGray : themes.MutedPurple,
      ),
    );
  }

  Widget _buildContentSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.item.itemTitle ?? 'Untitled',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : themes.DarkSlate,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildStatusBadge(),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              _getItemTypeIcon(widget.item.itemType),
              size: 14,
              color: isDark ? themes.LavenderGray : themes.MutedPurple,
            ),
            const SizedBox(width: 4),
            Text(
              _getItemTypeDisplayName(widget.item.itemType),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? themes.LavenderGray : themes.MutedPurple,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.access_time,
              size: 14,
              color: isDark ? themes.LavenderGray : themes.MutedPurple,
            ),
            const SizedBox(width: 4),
            Text(
              _formatDate(widget.item.addedAt),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? themes.LavenderGray : themes.MutedPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // if (widget.item.itemDescription != null &&
        //     widget.item.itemDescription!.isNotEmpty)
        //   Text(
        //     widget.item.itemDescription!,
        //     style: TextStyle(
        //       fontSize: 12,
        //       color: isDark ? themes.LavenderGray : themes.MutedPurple,
        //     ),
        //     maxLines: 2,
        //     overflow: TextOverflow.ellipsis,
        //   ),
      ],
    );
  }

  Widget _buildActionsSection(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.showActions)
          IconButton(
            onPressed: _onRemove,
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: isDark ? themes.DeepCoral : themes.DeepCoral,
            ),
            tooltip: 'Remove from watchlist',
          ),
        _buildStatusDropdown(isDark),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;

    switch (widget.item.status) {
      case 'completed':
        badgeColor = themes.DarkEmerald;
        statusText = 'Completed';
        break;
      case 'dropped':
        badgeColor = themes.DeepCoral;
        statusText = 'Dropped';
        break;
      default:
        badgeColor = themes.MutedPurple;
        statusText = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? themes.DarkSlate : themes.SoftCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? themes.LavenderGray : themes.MutedPurple,
        ),
      ),
      child: DropdownButton<String>(
        value: widget.item.status ?? 'active',
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          size: 20,
          color: isDark ? Colors.white : themes.MutedPurple,
        ),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : themes.DarkSlate,
        ),
        dropdownColor: isDark ? themes.MidnightBlue : themes.SoftCream,
        items: [
          DropdownMenuItem(
            value: 'active',
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 16,
                  color: themes.MutedPurple,
                ),
                const SizedBox(width: 8),
                const Text('Active'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'completed',
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: themes.DarkEmerald,
                ),
                const SizedBox(width: 8),
                const Text('Completed'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'dropped',
            child: Row(
              children: [
                Icon(Icons.cancel_outlined, size: 16, color: themes.DeepCoral),
                const SizedBox(width: 8),
                const Text('Dropped'),
              ],
            ),
          ),
        ],
        onChanged: (String? newValue) {
          if (newValue != null && newValue != widget.item.status) {
            _onStatusChanged(newValue);
          }
        },
      ),
    );
  }

  IconData _getItemTypeIcon(String? itemType) {
    switch (itemType) {
      case 'course':
        return Icons.school;
      case 'lecture':
        return Icons.video_library;
      case 'book':
        return Icons.book;
      case 'teacher':
        return Icons.person;
      default:
        return Icons.star;
    }
  }

  String _getItemTypeDisplayName(String? itemType) {
    switch (itemType) {
      case 'course':
        return 'Course';
      case 'lecture':
        return 'Lecture';
      case 'book':
        return 'Book';
      case 'teacher':
        return 'Teacher';
      default:
        return 'Item';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _onItemTap() {
    switch (widget.item.itemType) {
      case 'course':
        Get.toNamed('/course/${widget.item.itemId}');
        break;
      case 'lecture':
        Get.toNamed('/lecture/${widget.item.itemId}');
        break;
      case 'book':
        Get.toNamed('/book/${widget.item.itemId}');
        break;
      default:
        Get.snackbar(
          'Coming Soon',
          'This feature is not yet available',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }

  void _onRemove() {
    final watchlistController = Get.find<WatchlistController>();
    watchlistController.removeFromWatchlist(widget.item.id!);

    if (widget.onRemove != null) {
      widget.onRemove!();
    }
  }

  void _onStatusChanged(String newStatus) async {
    final watchlistController = Get.find<WatchlistController>();
    await watchlistController.updateItemStatus(widget.item.id!, newStatus);

    if (widget.onStatusChange != null) {
      widget.onStatusChange!();
    }
  }

  void _playAnimation() {
    _animationController.reset();
    _animationController.forward();
  }
}
