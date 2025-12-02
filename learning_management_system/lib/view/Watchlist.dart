// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controller/WatchlistController.dart';
import '../model/WatchlistModel.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'NavBar.dart';

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
  // Brand colors for Watchlist view
  final Color _mainColor = const Color(0xFF28293D); // background and buttons
  final Color _secondaryColor = const Color(
    0xFFD2D1DF,
  ); // text and inactive areas

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

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Obx(() {
        final isDark = themeController.initialTheme == Themes.customDarkTheme;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: null,
              color: isDark ? themes.WatchlistDarkBlue : _mainColor,
            ),
            child: Column(
              children: [
                _buildAppBar(isDark),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: isDark ? themes.WatchlistMidBlue : _secondaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: _buildBody(isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? themes.WatchlistMidBlue : _mainColor,
      flexibleSpace: null,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? themes.WatchlistAccentBlue : _secondaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: null,
            ),
            child: Icon(
              Icons.bookmark,
              color: isDark ? themes.LavenderGray : _mainColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Watchlist',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? themes.WatchlistTextBlue : _secondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Obx(
                  () => Text(
                    '${_watchlistController.allWatchlistItems.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark
                              ? themes.WatchlistSoftBlue
                              : _secondaryColor)
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _showFilterBottomSheet(),
          icon: Icon(
            Icons.filter_list,
            color: isDark ? themes.WatchlistTextBlue : _secondaryColor,
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
              backgroundColor: isDark ? themes.MutedGreen : _secondaryColor,
              colorText: isDark ? themes.DarkEmerald : _mainColor,
              duration: const Duration(seconds: 1),
            );
          },
          icon: Icon(
            Icons.refresh,
            color: isDark ? themes.WatchlistTextBlue : _secondaryColor,
          ),
          tooltip: 'Refresh watchlist',
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: isDark ? themes.WatchlistTextBlue : _secondaryColor,
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
                        color: isDark ? themes.WatchlistTextBlue : _mainColor,
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
        color: isDark ? themes.WatchlistMidBlue : _secondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? themes.WatchlistBorderBlue : _mainColor).withValues(
            alpha: 0.2,
          ),
          width: 1.0,
        ),
        boxShadow: null,
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
          color: (isDark ? themes.WatchlistTextBlue : _mainColor).withValues(
            alpha: 0.6,
          ),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: isDark ? themes.WatchlistTextBlue : _mainColor,
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
                    color: isDark ? themes.WatchlistTextBlue : _mainColor,
                  ),
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDark ? themes.WatchlistLightBlue : _secondaryColor,
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
                  ? (isDark ? themes.WatchlistSkyBlue : _mainColor)
                  : (isDark ? themes.WatchlistLightBlue : _secondaryColor),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? (isDark ? themes.WatchlistSkyBlue : _mainColor)
                    : (isDark ? themes.WatchlistBorderBlue : _mainColor)
                        .withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  isSelected
                      ? (isDark ? themes.WatchlistDarkBlue : _secondaryColor)
                      : (isDark ? themes.WatchlistTextBlue : _mainColor),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? (isDark ? themes.WatchlistDarkBlue : _secondaryColor)
                        : (isDark ? themes.WatchlistTextBlue : _mainColor),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/loading.json', width: 120, height: 120),
            const SizedBox(height: 16),
            Text(
              'Loading your watchlist...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:
                    Get.find<ThemeController>().initialTheme ==
                            Themes.customDarkTheme
                        ? Themes().WatchlistTextBlue
                        : _mainColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/TryAgain.json',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? themes.WatchlistTextBlue : _mainColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _watchlistController.generalError.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: (isDark ? themes.WatchlistSoftBlue : _mainColor)
                    .withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _watchlistController.refreshWatchlist(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? themes.WatchlistSkyBlue : _mainColor,
                foregroundColor:
                    isDark ? themes.WatchlistDarkBlue : _secondaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                color: isDark ? themes.WatchlistTextBlue : _mainColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding courses, lectures, and books to keep track of what you want to learn!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: (isDark ? themes.WatchlistSoftBlue : _mainColor)
                    .withValues(alpha: 0.85),
              ),
            ),
            // const SizedBox(height: 24),
            // ElevatedButton.icon(
            //   onPressed:
            //       () => Get.to(() => Library(), preventDuplicates: false),
            //   icon: const Icon(Icons.explore),
            //   label: const Text('Explore Content'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor:
            //         isDark ? themes.WatchlistSkyBlue : _mainColor,
            //     foregroundColor:
            //         isDark ? themes.WatchlistDarkBlue : _secondaryColor,
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 24,
            //       vertical: 12,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            // ),
          ],
        ),
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
        color: isDark ? themes.WatchlistMidBlue : _secondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? themes.WatchlistBorderBlue : _mainColor).withValues(
            alpha: 0.15,
          ),
          width: 1,
        ),
        boxShadow: null,
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
                _buildItemImage(item, isDark),
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

  Widget _buildItemImage(WatchlistModel item, bool isDark) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: (isDark ? themes.WatchlistLightBlue : _secondaryColor)
            .withValues(alpha: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            item.itemImage != null && item.itemImage!.isNotEmpty
                ? Image.network(
                  "$mainIP/${item.itemImage!}",
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        _getItemTypeIcon(item.itemType),
                        color: isDark ? themes.WatchlistTextBlue : _mainColor,
                        size: 24,
                      ),
                )
                : Icon(
                  _getItemTypeIcon(item.itemType),
                  color: isDark ? themes.WatchlistTextBlue : _mainColor,
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
                  color: isDark ? themes.WatchlistTextBlue : _mainColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              fit: FlexFit.loose,
              child: _buildStatusBadge(item.status ?? 'active'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Icon(
              _getItemTypeIcon(item.itemType),
              size: 14,
              color: (isDark ? themes.WatchlistSoftBlue : _mainColor)
                  .withValues(alpha: 0.8),
            ),
            Text(
              _getItemTypeDisplayName(item.itemType),
              style: TextStyle(
                fontSize: 12,
                color: (isDark ? themes.WatchlistSoftBlue : _mainColor)
                    .withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.access_time,
              size: 14,
              color: (isDark ? themes.WatchlistSoftBlue : _mainColor)
                  .withValues(alpha: 0.8),
            ),
            Text(
              _formatDate(item.addedAt),
              style: TextStyle(
                fontSize: 12,
                color: (isDark ? themes.WatchlistSoftBlue : _mainColor)
                    .withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: false,
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
          icon: Icon(
            Icons.delete_outline,
            color: isDark ? themes.WatchlistTextBlue : _mainColor,
            size: 20,
          ),
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
        badgeColor = Themes().DarkEmerald; // Completed: green
        statusText = 'Completed';
        break;
      case 'dropped':
        badgeColor = Themes().DeepCoral; // Dropped: red
        statusText = 'Dropped';
        break;
      default:
        badgeColor = Themes().WatchlistSkyBlue; // Active: blue
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
        color: isDark ? themes.WatchlistLightBlue : _secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? themes.WatchlistBorderBlue : _mainColor).withValues(
            alpha: 0.3,
          ),
        ),
        boxShadow: null,
      ),
      child: DropdownButton<String>(
        value: item.status ?? 'active',
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          size: 20,
          color: isDark ? themes.WatchlistTextBlue : _mainColor,
        ),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? themes.WatchlistTextBlue : _mainColor,
        ),
        dropdownColor: isDark ? themes.WatchlistLightBlue : _secondaryColor,
        items: [
          DropdownMenuItem(
            value: 'active',
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 16,
                  color: Themes().WatchlistSkyBlue,
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
                  color: Themes().DarkEmerald,
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
                Icon(
                  Icons.cancel_outlined,
                  size: 16,
                  color: Themes().DeepCoral,
                ),
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
      case 'resource':
        return Icons.description;
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
      case 'resource':
        return 'Resource';
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
        Get.to(('/course/${item.itemId}'));
        break;
      case 'lecture':
        Get.toNamed('/lecture/${item.itemId}');
        break;
      case 'book':
        Get.toNamed('/book/${item.itemId}');
        break;
      case 'resource':
        Get.toNamed('/resource/${item.itemId}');
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
              Icon(Icons.delete_outline, color: _mainColor, size: 24),
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
                backgroundColor: _mainColor,
                foregroundColor: _secondaryColor,
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
        backgroundColor: _secondaryColor,
        colorText: _mainColor,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error removing item: $e');
      Get.snackbar(
        'Error',
        'Failed to remove item from watchlist. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _secondaryColor,
        colorText: _mainColor,
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
        backgroundColor: _secondaryColor,
        colorText: _mainColor,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _secondaryColor,
        colorText: _mainColor,
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
        backgroundColor: _secondaryColor,
        colorText: _mainColor,
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
                Icon(Icons.delete_sweep_outlined, color: _mainColor, size: 24),
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
                  backgroundColor: _mainColor,
                  foregroundColor: _secondaryColor,
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
        backgroundColor: _secondaryColor,
        colorText: _mainColor,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _showFilterBottomSheet() {
    final themeController = Get.find<ThemeController>();
    final isDark = themeController.initialTheme == Themes.customDarkTheme;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _secondaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: _mainColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
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
                    color: _mainColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: _mainColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _mainColor,
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
                  isDark: isDark,
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
                  isDark: isDark,
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
                  isDark: isDark,
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
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
