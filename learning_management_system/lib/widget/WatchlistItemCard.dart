// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../controller/FontController.dart';
import '../model/WatchlistModel.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import '../core/constants/ImageAssets.dart';

class WatchlistItemCard extends StatefulWidget {
  final WatchlistModel item;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final Function(String)? onStatusChanged;
  final bool showActions;

  const WatchlistItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onRemove,
    this.onStatusChanged,
    this.showActions = true,
  });

  @override
  State<WatchlistItemCard> createState() => _WatchlistItemCardState();
}

class _WatchlistItemCardState extends State<WatchlistItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
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

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isDeleting ? null : widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageSection(primaryColor),
                        const SizedBox(height: 12),
                        _buildContentSection(primaryColor),
                        if (widget.showActions)
                          _buildActionsSection(primaryColor, secondaryColor),
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
  }

  Widget _buildImageSection(Color primaryColor) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: primaryColor.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            widget.item.itemImage != null && widget.item.itemImage!.isNotEmpty
                ? CachedNetworkImage(
                  imageUrl: widget.item.itemImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder:
                      (context, url) => Container(
                        color: primaryColor.withOpacity(0.1),
                        child: Icon(
                          _getItemTypeIcon(),
                          size: 50,
                          color: primaryColor.withOpacity(0.5),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: primaryColor.withOpacity(0.1),
                        child: Icon(
                          _getItemTypeIcon(),
                          size: 50,
                          color: primaryColor.withOpacity(0.5),
                        ),
                      ),
                )
                : Container(
                  color: primaryColor.withOpacity(0.1),
                  child: Icon(
                    _getItemTypeIcon(),
                    size: 50,
                    color: primaryColor.withOpacity(0.5),
                  ),
                ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getItemTypeDisplayName(),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: FontController().currentFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(Color primaryColor) {
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
                  fontFamily: FontController().currentFontFamily,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildStatusBadge(primaryColor),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 14,
              color: primaryColor.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              _formatDate(),
              style: TextStyle(
                fontSize: 12,
                color: primaryColor.withOpacity(0.7),
                fontFamily: FontController().currentFontFamily,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsSection(Color primaryColor, Color secondaryColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(child: _buildStatusDropdown(primaryColor, secondaryColor)),
          const SizedBox(width: 8),
          _buildDeleteButton(primaryColor),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Color primaryColor) {
    Color badgeColor;
    String statusText;

    switch (widget.item.status) {
      case 'completed':
        badgeColor = Colors.green;
        statusText = 'Completed';
        break;
      case 'dropped':
        badgeColor = Colors.red;
        statusText = 'Dropped';
        break;
      default:
        badgeColor = primaryColor;
        statusText = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontFamily: FontController().currentFontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(Color primaryColor, Color secondaryColor) {
    if (widget.onStatusChanged == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: DropdownButton<String>(
        value: widget.item.status ?? 'active',
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, size: 20, color: primaryColor),
        style: TextStyle(fontSize: 12, color: primaryColor),
        dropdownColor: secondaryColor,
        items: [
          DropdownMenuItem(
            value: 'active',
            child: Text(
              'Active',
              style: TextStyle(fontFamily: FontController().currentFontFamily),
            ),
          ),
          DropdownMenuItem(
            value: 'completed',
            child: Text(
              'Completed',
              style: TextStyle(fontFamily: FontController().currentFontFamily),
            ),
          ),
          DropdownMenuItem(
            value: 'dropped',
            child: Text(
              'Dropped',
              style: TextStyle(fontFamily: FontController().currentFontFamily),
            ),
          ),
        ],
        onChanged: (String? newValue) {
          if (newValue != null && widget.onStatusChanged != null) {
            widget.onStatusChanged!(newValue);
          }
        },
      ),
    );
  }

  Widget _buildDeleteButton(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: IconButton(
        onPressed: _isDeleting ? null : _showRemoveDialog,
        icon:
            _isDeleting
                ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                )
                : Icon(Icons.delete_outline, color: Colors.red, size: 20),
        tooltip: _isDeleting ? 'Removing...' : 'Remove from watchlist',
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  IconData _getItemTypeIcon() {
    switch (widget.item.itemType) {
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

  String _getItemTypeDisplayName() {
    switch (widget.item.itemType) {
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

  String _formatDate() {
    if (widget.item.addedAt == null) return 'Unknown date';

    final now = DateTime.now();
    final difference = now.difference(widget.item.addedAt!);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(widget.item.addedAt!);
    }
  }

  void _showRemoveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red[600], size: 24),
              const SizedBox(width: 8),
              Text(
                'Remove from Watchlist',
                style: TextStyle(
                  fontFamily: FontController().currentFontFamily,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove "${widget.item.itemTitle}" from your watchlist?',
            style: TextStyle(fontFamily: FontController().currentFontFamily),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: FontController().currentFontFamily,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleRemove();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Remove',
                style: TextStyle(
                  fontFamily: FontController().currentFontFamily,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRemove() async {
    if (widget.onRemove == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      widget.onRemove!();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove item from watchlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }
}
