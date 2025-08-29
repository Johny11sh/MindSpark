// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controller/WatchlistController.dart';
import '../model/WatchlistModel.dart';
import '../widget/WatchlistItemCard.dart';
import '../themes/ThemeController.dart';
import '../core/classes/Library.dart';
import '../themes/Themes.dart';

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
  late Themes themes;

  @override
  void initState() {
    super.initState();
    themes = Themes();
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
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.initialTheme.brightness == Brightness.dark;

      return Scaffold(
        backgroundColor: isDark ? themes.DarkSlate : themes.SoftCream,
        appBar: _buildAppBar(isDark),
        body: _buildBody(isDark),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? themes.MidnightBlue : themes.SoftCream,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themes.MutedPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.bookmark, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Watchlist',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Obx(
                    () => Text(
                  '${_watchlistController.allWatchlistItems.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? themes.LavenderGray : themes.MutedPurple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showFilterBottomSheet(),
          icon: Icon(
            Icons.filter_list,
            color: isDark ? Colors.white : themes.MutedPurple,
          ),
          tooltip: 'Filter options',
        ),
        IconButton(
          onPressed: () async {
            _refreshAnimationController.repeat();
            await _watchlistController.refreshWatchlist();
            _refreshAnimationController.stop();
            Get.snackbar(
              'Watchlist',
              'Watchlist refreshed successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: themes.MutedGreen,
              colorText: themes.DarkEmerald,
              duration: const Duration(seconds: 1),
            );
          },
          icon: Icon(
            Icons.refresh,
            color: isDark ? Colors.white : themes.MutedPurple,
          ),
          tooltip: 'Refresh watchlist',
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDark ? Colors.white : themes.MutedPurple,
          ),
          onSelected: (value) async {
            if (value == 'clear_all') {
              await _showClearAllDialog();
            }
          },
          itemBuilder:
              (context) => [
            PopupMenuItem(
              value: 'clear_all',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_sweep_outlined,
                    color: themes.DeepCoral,
                  ),
                  const SizedBox(width: 8),
                  const Text('Clear All'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(bool isDark) {
    return Column(
      children: [
        _buildSearchSection(isDark),
        Expanded(child: _buildWatchlistContent(isDark)),
      ],
    );
  }

  Widget _buildSearchSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          _buildSearchBar(isDark),
          const SizedBox(height: 12),
          _buildQuickFilters(isDark),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => _watchlistController.searchQuery.value = value,
      decoration: InputDecoration(
        hintText: 'Search your watchlist...',
        hintStyle: TextStyle(
          color: isDark ? themes.LavenderGray : themes.MutedPurple,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: isDark ? themes.LavenderGray : themes.MutedPurple,
        ),
        suffixIcon:
        _searchController.text.isNotEmpty
            ? IconButton(
          onPressed: () {
            _searchController.clear();
            _watchlistController.searchQuery.value = '';
          },
          icon: Icon(
            Icons.clear,
            color: isDark ? themes.LavenderGray : themes.MutedPurple,
          ),
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDark ? themes.DarkSlate : themes.WarmBeige,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildQuickFilters(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterChip(
            label: 'All',
            icon: Icons.all_inclusive,
            isSelected: _watchlistController.selectedType.value == 'all',
            onTap: () => _watchlistController.selectedType.value = 'all',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip(
            label: 'Courses',
            icon: Icons.school,
            isSelected: _watchlistController.selectedType.value == 'course',
            onTap: () => _watchlistController.selectedType.value = 'course',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip(
            label: 'Books',
            icon: Icons.book,
            isSelected: _watchlistController.selectedType.value == 'book',
            onTap: () => _watchlistController.selectedType.value = 'book',
            isDark: isDark,
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
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color:
          isSelected
              ? themes.MutedPurple
              : isDark
              ? themes.DarkSlate
              : themes.WarmBeige,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? themes.MutedPurple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : themes.MutedPurple,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : themes.MutedPurple,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistContent(bool isDark) {
    return Obx(() {
      if (_watchlistController.isLoadingAll.value) {
        return _buildLoadingState();
      }

      if (_watchlistController.generalError.value.isNotEmpty) {
        return _buildErrorState(isDark);
      }

      final filteredItems = _watchlistController.getFilteredItems();

      if (filteredItems.isEmpty) {
        return _buildEmptyState(isDark);
      }

      return _buildWatchlistList(filteredItems, isDark);
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/loading.json', width: 120, height: 120),
          const SizedBox(height: 16),
          const Text(
            'Loading your watchlist...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/TryAgain.json', width: 120, height: 120),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : themes.DarkSlate,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _watchlistController.generalError.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : themes.MutedPurple,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _watchlistController.refreshWatchlist(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: themes.MutedPurple,
              foregroundColor: Colors.white,
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/noData.json', width: 120, height: 120),
          const SizedBox(height: 16),
          Text(
            'Your watchlist is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : themes.DarkSlate,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding courses, lectures, and books to keep track of what you want to learn!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : themes.MutedPurple,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => Library(), preventDuplicates: false),
            icon: const Icon(Icons.explore),
            label: const Text('Explore Content'),
            style: ElevatedButton.styleFrom(
              backgroundColor: themes.MutedPurple,
              foregroundColor: Colors.white,
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

  Widget _buildWatchlistList(List<WatchlistModel> items, bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount:
      items.length + (_watchlistController.hasMoreData.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _buildLoadMoreIndicator();
        }

        final item = items[index];
        return _buildWatchlistItem(item, isDark);
      },
    );
  }

  Widget _buildWatchlistItem(WatchlistModel item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: () => _onItemTap(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildItemImage(item),
                const SizedBox(width: 16),
                Expanded(child: _buildItemContent(item, isDark)),
                _buildItemActions(item, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage(WatchlistModel item) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: themes.LavenderGray,
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
            color: themes.LavenderGray,
            size: 24,
          ),
        )
            : Icon(
          _getItemTypeIcon(item.itemType),
          color: themes.LavenderGray,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildItemContent(WatchlistModel item, bool isDark) {
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
                  color: isDark ? Colors.white : themes.DarkSlate,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildStatusBadge(item.status ?? 'active'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              _getItemTypeIcon(item.itemType),
              size: 14,
              color: themes.LavenderGray,
            ),
            const SizedBox(width: 4),
            Text(
              _getItemTypeDisplayName(item.itemType),
              style: TextStyle(fontSize: 12, color: themes.LavenderGray),
            ),
            const SizedBox(width: 12),
            Icon(Icons.access_time, size: 14, color: themes.LavenderGray),
            const SizedBox(width: 4),
            Text(
              _formatDate(item.addedAt),
              style: TextStyle(fontSize: 12, color: themes.LavenderGray),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemActions(WatchlistModel item, bool isDark) {
    return Column(
      children: [
        IconButton(
          onPressed: () => _showRemoveDialog(item),
          icon: Icon(Icons.delete_outline, color: themes.DeepCoral, size: 20),
          tooltip: 'Remove from watchlist',
        ),
        _buildStatusDropdown(item, isDark),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String statusText;

    switch (status) {
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

  Widget _buildStatusDropdown(WatchlistModel item, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? themes.DarkSlate : themes.SoftCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themes.LavenderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: item.status ?? 'active',
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
          if (newValue != null && newValue != item.status) {
            _onStatusChanged(item, newValue);
          }
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (_watchlistController.isLoadingAll.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
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
              Icon(Icons.delete_outline, color: themes.DeepCoral, size: 24),
              const SizedBox(width: 8),
              const Text('Remove from Watchlist'),
            ],
          ),
          content: Text(
            'Are you sure you want to remove "${item.itemTitle}" from your watchlist?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _onItemRemove(item);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themes.DeepCoral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Remove'),
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
        backgroundColor: themes.SoftPink,
        colorText: themes.DeepCoral,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error removing item: $e');
      Get.snackbar(
        'Error',
        'Failed to remove item from watchlist. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: themes.SoftPink,
        colorText: themes.DeepCoral,
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
        backgroundColor: themes.MutedGreen,
        colorText: themes.DarkEmerald,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: themes.SoftPink,
        colorText: themes.DeepCoral,
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
        backgroundColor: themes.PalePeach,
        colorText: themes.DeepRust,
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
              color: themes.DeepCoral,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Clear All'),
          ],
        ),
        content: const Text(
          'Are you sure you want to remove all items from your watchlist? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: themes.DeepCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Clear All'),
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
        backgroundColor: themes.MutedGreen,
        colorText: themes.DarkEmerald,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? themes.MidnightBlue : themes.SoftCream,
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
                    color: Get.isDarkMode ? Colors.white : themes.DarkSlate,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Get.isDarkMode ? Colors.white : themes.DarkSlate,
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
                  isDark: Get.isDarkMode,
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
                  isDark: Get.isDarkMode,
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
                  isDark: Get.isDarkMode,
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
                  isDark: Get.isDarkMode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
