// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/WatchlistModel.dart';
import '../services/WatchlistService.dart';
import '../services/SharedPrefs.dart';

class WatchlistController extends GetxController {
  final WatchlistService _watchlistService = WatchlistService();
  final SharedPrefs _sharedPrefs = SharedPrefs.instance;

  static const String _cacheKey = 'cached_watchlist_items';

  // Observable lists
  final RxList<WatchlistModel> watchlistLectures = <WatchlistModel>[].obs;
  final RxList<WatchlistModel> watchlistCourses = <WatchlistModel>[].obs;
  final RxList<WatchlistModel> watchlistResources = <WatchlistModel>[].obs;
  final RxList<WatchlistModel> allWatchlistItems = <WatchlistModel>[].obs;

  // Loading states
  final RxBool isLoadingLectures = false.obs;
  final RxBool isLoadingCourses = false.obs;
  final RxBool isLoadingResources = false.obs;
  final RxBool isLoadingAll = false.obs;

  // Error states
  final RxString lecturesError = ''.obs;
  final RxString coursesError = ''.obs;
  final RxString resourcesError = ''.obs;
  final RxString generalError = ''.obs;

  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxString selectedType = 'all'.obs;
  final RxString selectedStatus = 'all'.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  static const int itemsPerPage = 20;

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    _loadWatchlistData();
  }

  @override
  void onReady() {
    super.onReady();
    refreshWatchlist();
  }

  void _loadFromCache() {
    try {
      final cached = _sharedPrefs.prefs.getString(_cacheKey);
      if (cached != null && cached.isNotEmpty) {
        final List<dynamic> list = jsonDecode(cached);
        final items = list.map((e) => WatchlistModel.fromJson(e)).toList();
        allWatchlistItems.assignAll(items);
      }
    } catch (_) {}
  }

  void _saveToCache() {
    try {
      final data = allWatchlistItems.map((e) => e.toJson()).toList();
      _sharedPrefs.prefs.setString(_cacheKey, jsonEncode(data));
    } catch (_) {}
  }

  Future<void> _loadWatchlistData() async {
    try {
      isLoadingAll.value = true;
      generalError.value = '';
      await Future.wait([
        _loadWatchlistLectures(),
        _loadWatchlistCourses(),
        _loadWatchlistResources(),
      ]);
      _combineAndFilterItems();
    } catch (e) {
      generalError.value = e.toString();
    } finally {
      isLoadingAll.value = false;
    }
  }

  Future<void> _loadWatchlistLectures() async {
    try {
      isLoadingLectures.value = true;
      lecturesError.value = '';
      final lectures = await _watchlistService.getWatchlistLectures();
      watchlistLectures.value = lectures;
    } catch (e) {
      lecturesError.value = e.toString();
    } finally {
      isLoadingLectures.value = false;
    }
  }

  Future<void> _loadWatchlistCourses() async {
    try {
      isLoadingCourses.value = true;
      coursesError.value = '';
      final courses = await _watchlistService.getWatchlistCourses();
      watchlistCourses.value = courses;
    } catch (e) {
      coursesError.value = e.toString();
    } finally {
      isLoadingCourses.value = false;
    }
  }

  Future<void> _loadWatchlistResources() async {
    try {
      isLoadingResources.value = true;
      resourcesError.value = '';
      final resources = await _watchlistService.getWatchlistResources();
      watchlistResources.value = resources;
    } catch (e) {
      resourcesError.value = e.toString();
    } finally {
      isLoadingResources.value = false;
    }
  }

  void _combineAndFilterItems() {
    final allItems = <WatchlistModel>[];
    allItems.addAll(watchlistLectures);
    allItems.addAll(watchlistCourses);
    allItems.addAll(watchlistResources);

    // Exclude PDF-like items from the combined list
    allItems.retainWhere((item) {
      final type = (item.itemType ?? '').toLowerCase();
      final title = (item.itemTitle ?? '').toLowerCase();
      final image = (item.itemImage ?? '').toLowerCase();
      final looksPdf =
          type == 'pdf' ||
          title.endsWith('.pdf') ||
          title.contains(' pdf') ||
          image.endsWith('.pdf');
      return !looksPdf;
    });

    allItems.sort(
      (a, b) =>
          (b.addedAt ?? DateTime.now()).compareTo(a.addedAt ?? DateTime.now()),
    );
    allWatchlistItems.value = allItems;
    _saveToCache();
  }

  Future<void> refreshWatchlist() async {
    currentPage.value = 1;
    hasMoreData.value = true;
    await _loadWatchlistData();
  }

  Future<void> toggleLectureWatchlist(
    String lectureId,
    String lectureTitle,
    String lectureImage,
  ) async {
    try {
      print('Attempting to toggle lecture watchlist: $lectureId');

      // Check if item is already in watchlist
      final existingIndex = watchlistLectures.indexWhere(
        (item) => item.itemId == lectureId,
      );
      final isCurrentlyInWatchlist = existingIndex >= 0;

      // Optimistically update UI first
      if (isCurrentlyInWatchlist) {
        print('Removing lecture from watchlist: $lectureId');
        watchlistLectures.removeAt(existingIndex);
      } else {
        print('Adding lecture to watchlist: $lectureId');
        final newItem = WatchlistModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: await _getCurrentUserId(),
          itemId: lectureId,
          itemType: 'lecture',
          itemTitle: lectureTitle,
          itemImage: lectureImage,
          addedAt: DateTime.now(),
          status: 'active',
        );
        watchlistLectures.add(newItem);
      }
      _combineAndFilterItems();

      // Make API call
      final success = await _watchlistService.toggleWatchlistLecture(lectureId);
      print('Toggle lecture result: $success');

      if (!success) {
        // Revert the change if API call failed
        if (isCurrentlyInWatchlist) {
          // Add back if we removed it
          final newItem = WatchlistModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: await _getCurrentUserId(),
            itemId: lectureId,
            itemType: 'lecture',
            itemTitle: lectureTitle,
            itemImage: lectureImage,
            addedAt: DateTime.now(),
            status: 'active',
          );
          watchlistLectures.add(newItem);
        } else {
          // Remove if we added it
          final newIndex = watchlistLectures.indexWhere(
            (item) => item.itemId == lectureId,
          );
          if (newIndex >= 0) {
            watchlistLectures.removeAt(newIndex);
          }
        }
        _combineAndFilterItems();
        print('Failed to toggle lecture watchlist: API returned false');
        generalError.value = 'Failed to update watchlist. Please try again.';
      }
    } catch (e) {
      print('Error toggling lecture watchlist: $e');
      generalError.value = e.toString();
    }
  }

  Future<void> toggleCourseWatchlist(
    String courseId,
    String courseTitle,
    String courseImage,
  ) async {
    try {
      print('Attempting to toggle course watchlist: $courseId');

      // Check if item is already in watchlist
      final existingIndex = watchlistCourses.indexWhere(
        (item) => item.itemId == courseId,
      );
      final isCurrentlyInWatchlist = existingIndex >= 0;

      // Optimistically update UI first
      if (isCurrentlyInWatchlist) {
        print('Removing course from watchlist: $courseId');
        watchlistCourses.removeAt(existingIndex);
      } else {
        print('Adding course to watchlist: $courseId');
        final newItem = WatchlistModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: await _getCurrentUserId(),
          itemId: courseId,
          itemType: 'course',
          itemTitle: courseTitle,
          itemImage: courseImage,
          addedAt: DateTime.now(),
          status: 'active',
        );
        watchlistCourses.add(newItem);
      }
      _combineAndFilterItems();

      // Make API call
      final success = await _watchlistService.toggleWatchlistCourse(courseId);
      print('Toggle course result: $success');

      if (!success) {
        // Revert the change if API call failed
        if (isCurrentlyInWatchlist) {
          // Add back if we removed it
          final newItem = WatchlistModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: await _getCurrentUserId(),
            itemId: courseId,
            itemType: 'course',
            itemTitle: courseTitle,
            itemImage: courseImage,
            addedAt: DateTime.now(),
            status: 'active',
          );
          watchlistCourses.add(newItem);
        } else {
          // Remove if we added it
          final newIndex = watchlistCourses.indexWhere(
            (item) => item.itemId == courseId,
          );
          if (newIndex >= 0) {
            watchlistCourses.removeAt(newIndex);
          }
        }
        _combineAndFilterItems();
        print('Failed to toggle course watchlist: API returned false');
        generalError.value = 'Failed to update watchlist. Please try again.';
      }
    } catch (e) {
      print('Error toggling course watchlist: $e');
      generalError.value = e.toString();
    }
  }

  Future<void> toggleResourceWatchlist(
    String resourceId,
    String resourceTitle,
    String resourceImage,
  ) async {
    try {
      print('Attempting to toggle resource (book) watchlist: $resourceId');

      // Check if item is already in watchlist
      final existingIndex = watchlistCourses.indexWhere(
        (item) => item.itemId == resourceId,
      );
      final isCurrentlyInWatchlist = existingIndex >= 0;

      // Optimistically update UI first
      if (isCurrentlyInWatchlist) {
        print('Removing resource from watchlist: $resourceId');
        watchlistCourses.removeAt(existingIndex);
      } else {
        print('Adding resource to watchlist: $resourceId');
        final newItem = WatchlistModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: await _getCurrentUserId(),
          itemId: resourceId,
          itemType: 'book', // Treat resources as books
          itemTitle: resourceTitle,
          itemImage: resourceImage,
          addedAt: DateTime.now(),
          status: 'active',
        );
        watchlistCourses.add(newItem);
      }
      _combineAndFilterItems();

      // Use the resource API endpoint
      final success = await _watchlistService.toggleWatchlistResource(
        resourceId,
      );
      print('Toggle resource result: $success');

      if (!success) {
        // Revert the change if API call failed
        if (isCurrentlyInWatchlist) {
          // Add back if we removed it
          final newItem = WatchlistModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: await _getCurrentUserId(),
            itemId: resourceId,
            itemType: 'book', // Treat resources as books
            itemTitle: resourceTitle,
            itemImage: resourceImage,
            addedAt: DateTime.now(),
            status: 'active',
          );
          watchlistCourses.add(newItem);
        } else {
          // Remove if we added it
          final newIndex = watchlistCourses.indexWhere(
            (item) => item.itemId == resourceId,
          );
          if (newIndex >= 0) {
            watchlistCourses.removeAt(newIndex);
          }
        }
        _combineAndFilterItems();
        print('Failed to toggle resource watchlist: API returned false');
        generalError.value = 'Failed to update watchlist. Please try again.';
      }
    } catch (e) {
      print('Error toggling resource watchlist: $e');
      generalError.value = e.toString();
    }
  }

  Future<void> updateItemStatus(String itemId, String newStatus) async {
    try {
      print('Updating item status: $itemId to $newStatus');

      // Update locally first for immediate UI feedback
      _updateItemStatusInLists(itemId, newStatus);
      _combineAndFilterItems();
      _saveToCache();

      // Try to update on backend
      final success = await _watchlistService.updateWatchlistItemStatus(
        itemId,
        newStatus,
      );

      if (!success) {
        print('Failed to update status on backend');
        Get.snackbar(
          'Warning',
          'Status updated locally but failed to sync with server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
        );
      }
    } catch (e) {
      print('Error updating item status: $e');
      Get.snackbar(
        'Warning',
        'Status updated locally but failed to sync with server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
    }
  }

  Future<void> removeFromWatchlist(String itemId) async {
    try {
      print('Removing item from watchlist: $itemId');

      // Remove from local lists first for immediate UI feedback

      watchlistLectures.removeWhere((item) => item.id == itemId);
      watchlistCourses.removeWhere((item) => item.id == itemId);
      allWatchlistItems.removeWhere((item) => item.id == itemId);

      print('Removed item from all lists: $itemId');

      _saveToCache();
      _combineAndFilterItems(); // Recombine to ensure consistency

      // Try to remove from backend
      final success = await _watchlistService.removeFromWatchlist(itemId);
      print('Backend removal result: $success');

      if (!success) {
        // If backend removal failed, show error but keep local removal
        Get.snackbar(
          'Warning',
          'Item removed locally but failed to sync with server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[800],
        );
      }
    } catch (e) {
      print('Error removing item from watchlist: $e');
      // Even if there's an error, keep the local removal for better UX
      Get.snackbar(
        'Warning',
        'Item removed locally but failed to sync with server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
    }
  }

  Future<void> clearAll() async {
    // Try to clear on backend if possible; otherwise clear locally
    try {
      // Best-effort: iterate and remove; ignore failures
      final ids =
          allWatchlistItems.map((e) => e.id).whereType<String>().toList();
      for (final id in ids) {
        try {
          await _watchlistService.removeFromWatchlist(id);
        } catch (_) {}
      }
    } catch (_) {}
    watchlistLectures.clear();
    watchlistCourses.clear();
    watchlistResources.clear();
    allWatchlistItems.clear();
    _saveToCache();
  }

  void _updateItemStatusInLists(String itemId, String newStatus) {
    final lectureIndex = watchlistLectures.indexWhere(
      (item) => item.id == itemId,
    );
    if (lectureIndex >= 0) {
      watchlistLectures[lectureIndex] = watchlistLectures[lectureIndex]
          .copyWith(status: newStatus);
    }
    final courseIndex = watchlistCourses.indexWhere(
      (item) => item.id == itemId,
    );
    if (courseIndex >= 0) {
      watchlistCourses[courseIndex] = watchlistCourses[courseIndex].copyWith(
        status: newStatus,
      );
    }
    final resourceIndex = watchlistResources.indexWhere(
      (item) => item.id == itemId,
    );
    if (resourceIndex >= 0) {
      watchlistResources[resourceIndex] = watchlistResources[resourceIndex]
          .copyWith(status: newStatus);
    }
  }

  List<WatchlistModel> getFilteredItems() {
    List<WatchlistModel> filteredItems = List.from(allWatchlistItems);
    if (searchQuery.value.isNotEmpty) {
      filteredItems =
          filteredItems
              .where(
                (item) =>
                    item.itemTitle?.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ??
                    false,
              )
              .toList();
    }
    if (selectedType.value != 'all') {
      filteredItems =
          filteredItems
              .where((item) => item.itemType == selectedType.value)
              .toList();
    }
    if (selectedStatus.value != 'all') {
      filteredItems =
          filteredItems
              .where((item) => item.status == selectedStatus.value)
              .toList();
    }
    return filteredItems;
  }

  List<WatchlistModel> getPaginatedItems() {
    final filteredItems = getFilteredItems();
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    if (startIndex >= filteredItems.length) return [];
    return filteredItems.sublist(
      startIndex,
      endIndex.clamp(0, filteredItems.length),
    );
  }

  Future<void> loadMoreItems() async {
    if (isLoadingAll.value || !hasMoreData.value) return;
    final filteredItems = getFilteredItems();
    final totalPages = (filteredItems.length / itemsPerPage).ceil();
    if (currentPage.value < totalPages) {
      currentPage.value++;
    } else {
      hasMoreData.value = false;
    }
  }

  bool isInWatchlist(String itemId, String itemType) {
    if (itemType == 'lecture') {
      return watchlistLectures.any((item) => item.itemId == itemId);
    } else if (itemType == 'course' ||
        itemType == 'book' ||
        itemType == 'resource') {
      return watchlistCourses.any((item) => item.itemId == itemId);
    }
    return false;
  }

  Future<String?> _getCurrentUserId() async {
    return _sharedPrefs.prefs.getString('userId');
  }

  void clearErrors() {
    lecturesError.value = '';
    coursesError.value = '';
    resourcesError.value = '';
    generalError.value = '';
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedType.value = 'all';
    selectedStatus.value = 'all';
    currentPage.value = 1;
    hasMoreData.value = true;
  }

  // Test method to add items locally (for testing when API is not available)
  void addToWatchlistLocally(
    String itemId,
    String itemType,
    String itemTitle,
    String itemImage,
  ) {
    try {
      print('Adding item locally to watchlist: $itemId ($itemType)');

      final newItem = WatchlistModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'test_user', // For local testing
        itemId: itemId,
        itemType: itemType,
        itemTitle: itemTitle,
        itemImage: itemImage,
        addedAt: DateTime.now(),
        status: 'active',
      );

      if (itemType == 'lecture') {
        final existingIndex = watchlistLectures.indexWhere(
          (item) => item.itemId == itemId,
        );
        if (existingIndex >= 0) {
          watchlistLectures.removeAt(existingIndex);
          print('Removed lecture from local watchlist: $itemId');
        } else {
          watchlistLectures.add(newItem);
          print('Added lecture to local watchlist: $itemId');
        }
      } else if (itemType == 'course') {
        final existingIndex = watchlistCourses.indexWhere(
          (item) => item.itemId == itemId,
        );
        if (existingIndex >= 0) {
          watchlistCourses.removeAt(existingIndex);
          print('Removed course from local watchlist: $itemId');
        } else {
          watchlistCourses.add(newItem);
          print('Added course to local watchlist: $itemId');
        }
      }

      _combineAndFilterItems();
      print('Local watchlist updated successfully');
    } catch (e) {
      print('Error adding item locally: $e');
      generalError.value = e.toString();
    }
  }
}
