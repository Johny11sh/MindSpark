// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/ImageAssets.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';

class DynamicSearch extends SearchDelegate {
  final List elements;
  final Map<int, Uint8List> elementsImages;
  final String searchType; // 'subjects', 'books', 'courses', 'teachers', 'lessons'
  final Function(Map<String, dynamic>) onItemTap;
  final String? subjectName; // For books and lessons context

  DynamicSearch({
    required this.elements,
    required this.elementsImages,
    required this.searchType,
    required this.onItemTap,
    this.subjectName,
  });

  List? sortedItems;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: Icon(
          Icons.clear,
          color: Get.find<ThemeController>().initialTheme == Themes.customLightTheme
              ? Color.fromARGB(255, 40, 41, 61)
              : Color.fromARGB(255, 210, 209, 224),
        ),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(
        Icons.arrow_back,
        color: Get.find<ThemeController>().initialTheme == Themes.customLightTheme
            ? Color.fromARGB(255, 40, 41, 61)
            : Color.fromARGB(255, 210, 209, 224),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    sortedItems = elements
        .where(
          (element) =>
              element["name"].toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    if (sortedItems!.isEmpty) {
      return _buildNoResults(context);
    }

    return Container(
      color: themeController.initialTheme == Themes.customLightTheme
          ? Color.fromARGB(255, 210, 209, 224)
          : Color.fromARGB(255, 40, 41, 61),
      child: Column(
        children: [
          // Search Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getSearchIcon(),
                  color: themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 210, 209, 224)
                      : Color.fromARGB(255, 40, 41, 61),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  "${_getSearchTitle()} (${sortedItems!.length})".tr,
                  style: TextStyle(
                    color: themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 210, 209, 224)
                        : Color.fromARGB(255, 40, 41, 61),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          
          // Results List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: sortedItems!.length,
              itemBuilder: (context, index) {
                int elementsId = sortedItems![index]["id"];
                Uint8List? imageBytes = elementsImages[elementsId];

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: _buildSearchCard(
                    context,
                    sortedItems![index],
                    imageBytes,
                    themeController,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    sortedItems = elements
        .where(
          (element) =>
              element["name"].toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    if (query.isEmpty) {
      return _buildInitialState(context);
    }

    if (sortedItems!.isEmpty) {
      return _buildNoResults(context);
    }

    return Container(
      color: themeController.initialTheme == Themes.customLightTheme
          ? Color.fromARGB(255, 210, 209, 224)
          : Color.fromARGB(255, 40, 41, 61),
      child: Column(
        children: [
          // Search Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getSearchIcon(),
                  color: themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 210, 209, 224)
                      : Color.fromARGB(255, 40, 41, 61),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  "${_getSearchTitle()} (${sortedItems!.length})".tr,
                  style: TextStyle(
                    color: themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 210, 209, 224)
                        : Color.fromARGB(255, 40, 41, 61),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          
          // Results List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: sortedItems!.length,
              itemBuilder: (context, index) {
                int elementsId = sortedItems![index]["id"];
                Uint8List? imageBytes = elementsImages[elementsId];

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: _buildSearchCard(
                    context,
                    sortedItems![index],
                    imageBytes,
                    themeController,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(
    BuildContext context,
    Map<String, dynamic> item,
    Uint8List? imageBytes,
    ThemeController themeController,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          onItemTap(item);
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Image Section
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 40, 41, 61)
                        : Color.fromARGB(255, 210, 209, 224),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: imageBytes != null
                      ? Image.memory(
                          imageBytes,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _getDefaultImage();
                          },
                        )
                      : _getDefaultImage(),
                ),
              ),
              SizedBox(width: 16),
              
              // Content Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["name"]?.toString() ?? "Unknown",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 40, 41, 61)
                            : Color.fromARGB(255, 210, 209, 224),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    
                    // Additional info based on type
                    if (searchType == 'books' && subjectName != null)
                      Row(
                        children: [
                          Icon(
                            Icons.book,
                            size: 14,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            subjectName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else if (searchType == 'teachers' && item["major"] != null)
                      Text(
                        item["major"].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else if (searchType == 'courses' && item["description"] != null)
                      Text(
                        item["description"].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 40, 41, 61)
                    : Color.fromARGB(255, 210, 209, 224),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return Container(
      color: themeController.initialTheme == Themes.customLightTheme
          ? Color.fromARGB(255, 210, 209, 224)
          : Color.fromARGB(255, 40, 41, 61),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getSearchIcon(),
              size: 80,
              color: themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
            ),
            SizedBox(height: 20),
            Text(
              "Search ${_getSearchTitle()}".tr,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 40, 41, 61)
                    : Color.fromARGB(255, 210, 209, 224),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Type to start searching...".tr,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return Container(
      color: themeController.initialTheme == Themes.customLightTheme
          ? Color.fromARGB(255, 210, 209, 224)
          : Color.fromARGB(255, 40, 41, 61),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Text(
              "No ${_getSearchTitle()} found".tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 40, 41, 61)
                    : Color.fromARGB(255, 210, 209, 224),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Try different keywords".tr,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDefaultImage() {
    switch (searchType) {
      case 'subjects':
        return Image.asset(
          ImageAssets.subject,
          fit: BoxFit.cover,
        );
      case 'books':
        return Image.asset(
          ImageAssets.book,
          fit: BoxFit.cover,
        );
      case 'teachers':
        return Image.asset(
          ImageAssets.teacher,
          fit: BoxFit.cover,
        );
      case 'courses':
        return Image.asset(
          ImageAssets.course,
          fit: BoxFit.cover,
        );
      case 'lessons':
        return Image.asset(
          ImageAssets.lecture,
          fit: BoxFit.cover,
        );
      default:
        return Image.asset(
          ImageAssets.subject,
          fit: BoxFit.cover,
        );
    }
  }

  IconData _getSearchIcon() {
    switch (searchType) {
      case 'subjects':
        return Icons.subject;
      case 'books':
        return Icons.book;
      case 'teachers':
        return Icons.person;
      case 'courses':
        return Icons.school;
      case 'lessons':
        return Icons.note;
      default:
        return Icons.search;
    }
  }

  String _getSearchTitle() {
    switch (searchType) {
      case 'subjects':
        return 'Subjects';
      case 'books':
        return 'Books';
      case 'teachers':
        return 'Teachers';
      case 'courses':
        return 'Courses';
      case 'lessons':
        return 'Lessons';
      default:
        return 'Items';
    }
  }
} 