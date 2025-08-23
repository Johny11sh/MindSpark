// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controller/WatchlistController.dart';
import '../controller/FontController.dart';
import '../model/WatchlistModel.dart';
import '../widget/WatchlistItemCard.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import '../core/classes/Library.dart';

class Watchlist extends StatefulWidget {
  const Watchlist({super.key});

  @override
  State<Watchlist> createState() => _WatchlistState();
}

class _WatchlistState extends State<Watchlist> with TickerProviderStateMixin {
  late WatchlistController _watchlistController;
  late AnimationController _refreshAnimationController;
  late AnimationController _searchAnimationController;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _watchlistController = Get.put(WatchlistController());

    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    _searchAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _watchlistController.loadMoreItems();
    }
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

    return Scaffold(
      body: Container(
        color: primaryColor,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 25),
              height: 100,
              child: Center(
                child: Text(
                  'My Watchlist',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSearchSection(primaryColor, secondaryColor),
                    Expanded(
                      child: _buildWatchlistContent(
                        primaryColor,
                        secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => Library(), preventDuplicates: false),
        backgroundColor: primaryColor,
        child: Icon(Icons.explore, color: secondaryColor),
      ),
    );
  }

  Widget _buildSearchSection(Color primaryColor, Color secondaryColor) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSearchBar(primaryColor, secondaryColor),
          const SizedBox(height: 12),
          _buildQuickFilters(primaryColor, secondaryColor),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color primaryColor, Color secondaryColor) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => _watchlistController.searchQuery.value = value,
      decoration: InputDecoration(
        hintText: 'Search your watchlist...',
        hintStyle: TextStyle(color: primaryColor.withOpacity(0.7)),
        prefixIcon: Icon(Icons.search, color: primaryColor),
        suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _watchlistController.searchQuery.value = '';
                  },
                  icon: Icon(Icons.clear, color: primaryColor),
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        filled: true,
        fillColor: primaryColor.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildQuickFilters(Color primaryColor, Color secondaryColor) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterChip(
            label: 'All',
            icon: Icons.all_inclusive,
            isSelected: _watchlistController.selectedType.value == 'all',
            onTap: () => _watchlistController.selectedType.value = 'all',
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip(
            label: 'Courses',
            icon: Icons.school,
            isSelected: _watchlistController.selectedType.value == 'course',
            onTap: () => _watchlistController.selectedType.value = 'course',
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip(
            label: 'Books',
            icon: Icons.book,
            isSelected: _watchlistController.selectedType.value == 'book',
            onTap: () => _watchlistController.selectedType.value = 'book',
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : primaryColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? secondaryColor : primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? secondaryColor : primaryColor,
                fontFamily: FontController().currentFontFamily,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistContent(Color primaryColor, Color secondaryColor) {
    return Obx(() {
      if (_watchlistController.isLoadingAll.value) {
        return _buildLoadingState(primaryColor);
      }

      if (_watchlistController.generalError.value.isNotEmpty) {
        return _buildErrorState(primaryColor, secondaryColor);
      }

      final filteredItems = _watchlistController.getFilteredItems();

      if (filteredItems.isEmpty) {
        return _buildEmptyState(primaryColor, secondaryColor);
      }

      return _buildWatchlistList(filteredItems, primaryColor, secondaryColor);
    });
  }

  Widget _buildLoadingState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading your watchlist...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: FontController().currentFontFamily,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Color primaryColor, Color secondaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: primaryColor),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: FontController().currentFontFamily,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _watchlistController.generalError.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: FontController().currentFontFamily,
              color: primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _watchlistController.refreshWatchlist();
            },
            icon: Icon(Icons.refresh, color: secondaryColor),
            label: Text(
              'Try Again',
              style: TextStyle(
                fontFamily: FontController().currentFontFamily,
                color: secondaryColor,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor, Color secondaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 60,
            color: primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your watchlist is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: FontController().currentFontFamily,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding courses, lectures, and books to keep track of what you want to learn!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: FontController().currentFontFamily,
              color: primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => Library(), preventDuplicates: false),
            icon: Icon(Icons.explore, color: secondaryColor),
            label: Text(
              'Explore Content',
              style: TextStyle(
                fontFamily: FontController().currentFontFamily,
                color: secondaryColor,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistList(
    List<WatchlistModel> items,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount:
          items.length + (_watchlistController.hasMoreData.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _buildLoadMoreIndicator(primaryColor);
        }

        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onItemTap(item),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildItemImage(item, primaryColor),
                    const SizedBox(width: 16),
                    Expanded(child: _buildItemContent(item, primaryColor)),
                    _buildItemActions(item, primaryColor, secondaryColor),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemImage(WatchlistModel item, Color primaryColor) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: primaryColor.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            item.itemImage != null && item.itemImage!.isNotEmpty
                ? Image.network(
                  item.itemImage!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        _getItemTypeIcon(item.itemType),
                        color: primaryColor.withOpacity(0.5),
                        size: 24,
                      ),
                )
                : Icon(
                  _getItemTypeIcon(item.itemType),
                  color: primaryColor.withOpacity(0.5),
                  size: 24,
                ),
      ),
    );
  }

  Widget _buildItemContent(WatchlistModel item, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.itemTitle ?? 'Untitled',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontController().currentFontFamily,
                  color: primaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildStatusBadge(item.status ?? 'active', primaryColor),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              _getItemTypeIcon(item.itemType),
              size: 14,
              color: primaryColor.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              _getItemTypeDisplayName(item.itemType),
              style: TextStyle(
                fontSize: 12,
                color: primaryColor.withOpacity(0.7),
                fontFamily: FontController().currentFontFamily,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.access_time,
              size: 14,
              color: primaryColor.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              _formatDate(item.addedAt),
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

  Widget _buildItemActions(
    WatchlistModel item,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Column(
      children: [
        IconButton(
          onPressed: () => _showRemoveDialog(item),
          icon: Icon(Icons.delete_outline, color: primaryColor, size: 20),
          tooltip: 'Remove from watchlist',
        ),
        _buildStatusDropdown(item, primaryColor, secondaryColor),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color primaryColor) {
    Color badgeColor;
    String statusText;

    switch (status) {
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
          fontSize: 10,
          fontFamily: FontController().currentFontFamily,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(
    WatchlistModel item,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: DropdownButton<String>(
        value: item.status ?? 'active',
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, size: 20, color: primaryColor),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        dropdownColor: secondaryColor,
        items: [
          DropdownMenuItem(
            value: 'active',
            child: Row(
              children: [
                Icon(Icons.play_circle_outline, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Active',
                  style: TextStyle(
                    fontFamily: FontController().currentFontFamily,
                  ),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'completed',
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Completed',
                  style: TextStyle(
                    fontFamily: FontController().currentFontFamily,
                  ),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'dropped',
            child: Row(
              children: [
                Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Dropped',
                  style: TextStyle(
                    fontFamily: FontController().currentFontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
        onChanged: (String? newValue) {
          if (newValue != null && newValue != item.status) {
            _onStatusChanged(item, newValue);
          }
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator(Color primaryColor) {
    return Obx(() {
      if (_watchlistController.isLoadingAll.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CircularProgressIndicator(color: primaryColor),
          ),
        );
      }
      return const SizedBox.shrink();
    });
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

  void _onItemTap(WatchlistModel item) {
    switch (item.itemType) {
      case 'course':
        Get.toNamed('/course/${item.itemId}');
        break;
      case 'lecture':
        Get.toNamed('/lecture/${item.itemId}');
        break;
      case 'book':
        Get.toNamed('/book/${item.itemId}');
        break;
      default:
        Get.snackbar(
          'Coming Soon',
          'This feature is not yet available',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }

  void _showRemoveDialog(WatchlistModel item) {
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
            'Are you sure you want to remove "${item.itemTitle}" from your watchlist?',
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
              onPressed: () {
                Navigator.of(context).pop();
                _onItemRemove(item);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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

  void _onItemRemove(WatchlistModel item) async {
    try {
      print('Attempting to remove item: ${item.id}');
      await _watchlistController.removeFromWatchlist(item.id!);
      Get.snackbar(
        'Removed',
        '${item.itemTitle} has been removed from your watchlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error removing item: $e');
      Get.snackbar(
        'Error',
        'Failed to remove item from watchlist. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _onStatusChanged(WatchlistModel item, String newStatus) async {
    try {
      await _watchlistController.updateItemStatus(item.id!, newStatus);
      Get.snackbar(
        'Status Updated',
        '${item.itemTitle} status changed to $newStatus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _showClearAllDialog() async {
    if (_watchlistController.allWatchlistItems.isEmpty) {
      Get.snackbar(
        'Watchlist',
        'Your watchlist is already empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.delete_sweep_outlined,
                  color: Colors.red[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Clear All',
                  style: TextStyle(
                    fontFamily: FontController().currentFontFamily,
                  ),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to remove all items from your watchlist? This action cannot be undone.',
              style: TextStyle(fontFamily: FontController().currentFontFamily),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: FontController().currentFontFamily,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontFamily: FontController().currentFontFamily,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _watchlistController.clearAll();
      Get.snackbar(
        'Watchlist',
        'All items have been removed from your watchlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _showFilterBottomSheet() {
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

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Options',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: FontController().currentFontFamily,
                    color: primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: FontController().currentFontFamily,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(
                  label: 'All',
                  icon: Icons.all_inclusive,
                  isSelected:
                      _watchlistController.selectedStatus.value == 'all',
                  onTap: () {
                    _watchlistController.selectedStatus.value = 'all';
                    Get.back();
                  },
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                ),
                _buildFilterChip(
                  label: 'Active',
                  icon: Icons.play_circle_outline,
                  isSelected:
                      _watchlistController.selectedStatus.value == 'active',
                  onTap: () {
                    _watchlistController.selectedStatus.value = 'active';
                    Get.back();
                  },
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                ),
                _buildFilterChip(
                  label: 'Completed',
                  icon: Icons.check_circle_outline,
                  isSelected:
                      _watchlistController.selectedStatus.value == 'completed',
                  onTap: () {
                    _watchlistController.selectedStatus.value = 'completed';
                    Get.back();
                  },
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                ),
                _buildFilterChip(
                  label: 'Dropped',
                  icon: Icons.cancel_outlined,
                  isSelected:
                      _watchlistController.selectedStatus.value == 'dropped',
                  onTap: () {
                    _watchlistController.selectedStatus.value = 'dropped';
                    Get.back();
                  },
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
