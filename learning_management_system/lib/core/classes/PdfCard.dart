// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:learning_management_system/core/function/SnackBarFun.dart';
import 'package:learning_management_system/view/LogIn.dart';
import 'package:learning_management_system/view/NavBar.dart';
import 'package:learning_management_system/view/OnBoarding.dart';
import 'package:open_file/open_file.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../constants/FontGlobals.dart';

class PdfResource {
  final int id;
  final String title;
  final String description;
  final String pdfUrl;
  final String thumbnailUrl;
  final String category;
  final int pages;
  // final String author;
  final DateTime date;

  PdfResource({
    required this.id,
    required this.title,
    required this.description,
    required this.pdfUrl,
    required this.thumbnailUrl,
    required this.category,
    required this.pages,
    // required this.author,
    required this.date,
  });

  factory PdfResource.fromJson(Map<String, dynamic> json) {
    return PdfResource(
      id: json['id'] ?? '',
      title: json['title'] ?? 'no title',
      description: json['description'] ?? 'no caption',
      pdfUrl: json['pdfUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      category: json['category'] ?? 'All',
      pages: json['pages'] ?? 0,
      // author: json['author'] ?? 'unknown',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class PdfService {
  static Future<List<PdfResource>> fetchPdfs() async {
    final token = sharedPrefs.prefs.getString('token') ?? '';
    if (token.isEmpty) {
      debugPrint("Token empty, redirecting to login");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => LogIn());
        showErrorSnackbar("Session expired. Please log in again.");
      });
      throw Exception('Authentication required');
    }

    try {
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final url = '$baseUrl/api/getallexams';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': "Bearer $token",
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("Fetch PDFs API response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(
          utf8.decode(response.bodyBytes),
        );
        List<dynamic> dataList = [];
        if (decodedData is List) {
          dataList = decodedData;
        } else if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('exams')) {
            dataList = decodedData['exams'];
          } else if (decodedData.containsKey('data')) {
            dataList = decodedData['data'];
          } else if (decodedData.containsKey('pdfs')) {
            dataList = decodedData['pdfs'];
          } else {
            throw FormatException('Response contains map but no list found');
          }
        } else {
          throw FormatException('Unexpected response type');
        }

        return dataList.map((json) => PdfResource.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
        throw Exception('Unauthorized: Invalid token');
      } else {
        throw Exception('Failed to load PDFs: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('Could not connect to server');
    } on FormatException {
      throw Exception('Invalid server response');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

class PdfLibraryScreen extends StatefulWidget {
  const PdfLibraryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PdfLibraryScreenState createState() => _PdfLibraryScreenState();
}

class _PdfLibraryScreenState extends State<PdfLibraryScreen>
    with WidgetsBindingObserver {
  List<PdfResource> pdfs = [];
  String _selectedCategory = 'All';
  List<String> categories = ['All'];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  Brightness? _currentBrightness;
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPdfs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentBrightness = MediaQuery.of(context).platformBrightness;
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _currentBrightness = WidgetsBinding.instance.window.platformBrightness;
    });
  }

  Future<void> _loadPdfs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await PdfService.fetchPdfs();
      setState(() {
        pdfs = result;
        final uniqueCategories =
            pdfs.map((p) => p.category).whereType<String>().toSet().toList();
        categories = ['All', ...uniqueCategories];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  List<PdfResource> get filteredPdfs {
    final searchText = _searchController.text.toLowerCase();
    return pdfs.where((pdf) {
      final matchesCategory =
          _selectedCategory == 'All' || pdf.category == _selectedCategory;
      final matchesSearch =
          searchText.isEmpty ||
          pdf.title.toLowerCase().contains(searchText) ||
          pdf.description.toLowerCase().contains(searchText);
      // ||
      // pdf.author.toLowerCase().contains(searchText);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _openPdf(PdfResource pdf) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Loading file: ${pdf.title}',
            style: TextStyle(fontFamily: globalFontFamily),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor:
              themeController.initialTheme == Themes.customLightTheme
                  ? const Color.fromARGB(255, 40, 41, 61)
                  : const Color.fromARGB(255, 210, 209, 224),
        ),
      );

      final file = await DefaultCacheManager().getSingleFile(pdf.pdfUrl);
      final result = await OpenFile.open(file.path);

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to open file: ${result.message}',
              style: TextStyle(fontFamily: globalFontFamily),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: TextStyle(fontFamily: globalFontFamily),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Directionality(
      textDirection:
          Localizations.localeOf(context).languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     'Questions Library',
        //     style: TextStyle(color: secondaryColor),
        //   ),
        //   backgroundColor: primaryColor,
        //   iconTheme: IconThemeData(color: secondaryColor),
        //   actions: [
        //     IconButton(
        //       icon: Icon(Icons.search, color: secondaryColor),
        //       onPressed: () {
        //         showSearch(
        //           context: context,
        //           delegate: PdfSearchDelegate(
        //             pdfs: pdfs,
        //             onPdfSelected: _openPdf,
        //           ),
        //         );
        //       },
        //     ),
        //   ],
        // ),
        body: Container(
          color: primaryColor,
          child: Column(
            children: [
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: secondaryColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 35),
                    height: 100,
                    child: Text(
                          "Previous Exams Library",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            fontFamily: globalFontFamily,
                            color: secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                globalFontSizeChange <= 17
                                    ? (globalFontSizeChange / 5) + 23
                                    : 23 - (globalFontSizeChange / 5),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.loop())
                        .shimmer(
                          delay: Duration(seconds: 4),
                          duration: 800.ms,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Colors.grey.shade700
                                  : Colors.white54,
                        ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: secondaryColor),
                    onPressed: _loadPdfs,
                  ),
                ],
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
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search PDF files...',
                            hintStyle: TextStyle(color: primaryColor),
                            prefixIcon: Icon(Icons.search, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            filled: true,
                            fillColor: primaryColor.withOpacity(0.1),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 20,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: primaryColor,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                    : null,
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: ChoiceChip(
                                label: Text(
                                  categories[index],
                                  style: TextStyle(
                                    fontFamily: globalFontFamily,
                                    color:
                                        // _selectedCategory == categories[index]
                                        //     ?
                                        secondaryColor,
                                    // : primaryColor,
                                  ),
                                ),
                                selected:
                                    _selectedCategory == categories[index],
                                onSelected: (selected) {
                                  _filterByCategory(
                                    selected ? categories[index] : 'All',
                                  );
                                },
                                selectedColor: primaryColor,
                                backgroundColor: primaryColor.withOpacity(0.1),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(child: _buildContent()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _loadPdfs,
        //   backgroundColor: primaryColor,
        //   child: Icon(Icons.refresh, color: secondaryColor),
        // ),
      ),
    );
  }

  Widget _buildContent() {
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

    if (_isLoading) {
      return _buildLoadingIndicator(primaryColor);
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize:
                    globalFontSizeChange <= 17
                        ? (globalFontSizeChange / 5) + 18
                        : 18 - (globalFontSizeChange / 5),
                color: Colors.red,
                fontFamily: globalFontFamily,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadPdfs,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: secondaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(fontFamily: globalFontFamily),
              ),
            ),
          ],
        ),
      );
    }

    if (filteredPdfs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'No files found',
              style: TextStyle(
                fontFamily: globalFontFamily,
                fontSize:
                    globalFontSizeChange <= 17
                        ? (globalFontSizeChange / 5) + 18
                        : 18 - (globalFontSizeChange / 5),
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Try different search terms or category',
              style: TextStyle(
                fontFamily: globalFontFamily,
                fontSize:
                    globalFontSizeChange <= 17
                        ? (globalFontSizeChange / 5) + 14
                        : 14 - (globalFontSizeChange / 5),
                color: primaryColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPdfs,
      color: primaryColor,
      backgroundColor: secondaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredPdfs.length,
        itemBuilder: (context, index) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: PdfCard(
              key: ValueKey(filteredPdfs[index].id),
              pdf: filteredPdfs[index],
              onTap: () => _openPdf(filteredPdfs[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 20),
          Text(
            'Loading PDF files...',
            style: TextStyle(
              fontFamily: globalFontFamily,
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 16
                      : 16 - (globalFontSizeChange / 5),
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class PdfCard extends StatelessWidget {
  final PdfResource pdf;
  final VoidCallback onTap;
  final ThemeController themeController = Get.find<ThemeController>();

  PdfCard({super.key, required this.pdf, required this.onTap});

  @override
  Widget build(BuildContext context) {
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: pdf.id,
                  child: Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: primaryColor.withOpacity(0.2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: "$mainIP/${pdf.thumbnailUrl}",
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: primaryColor.withOpacity(0.1),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.picture_as_pdf,
                                size: 40,
                                color: primaryColor,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pdf.title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: globalFontFamily,
                          color: primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pdf.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: globalFontFamily,
                          color: primaryColor.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(
                            icon: Icons.category,
                            text: pdf.category,
                            primaryColor: primaryColor,
                          ),
                          _buildInfoChip(
                            icon: Icons.pages,
                            text: '${pdf.pages} pages',
                            primaryColor: primaryColor,
                          ),
                          // _buildInfoChip(
                          //   icon: Icons.person,
                          //   text: pdf.author,
                          //   primaryColor: primaryColor,
                          // ),
                          _buildInfoChip(
                            icon: Icons.calendar_today,
                            text: '${pdf.date.year}',
                            primaryColor: primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: globalFontFamily,
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 12
                      : 12 - (globalFontSizeChange / 5),
              color: primaryColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class PdfSearchDelegate extends SearchDelegate {
  final List<PdfResource> pdfs;
  final Function(PdfResource) onPdfSelected;
  final ThemeController themeController = Get.find<ThemeController>();

  PdfSearchDelegate({required this.pdfs, required this.onPdfSelected});

  @override
  ThemeData appBarTheme(BuildContext context) {
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

    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: secondaryColor),
      ),
      textTheme: Theme.of(context).textTheme.copyWith(
        titleLarge: TextStyle(
          color: secondaryColor,
          fontSize:
              globalFontSizeChange <= 17
                  ? (globalFontSizeChange / 5) + 18
                  : 18 - (globalFontSizeChange / 5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: secondaryColor.withOpacity(0.7)),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;
    final Color secondaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 210, 209, 224)
            : const Color.fromARGB(255, 40, 41, 61);

    return [
      IconButton(
        icon: Icon(Icons.clear, color: secondaryColor),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;
    final Color secondaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 210, 209, 224)
            : const Color.fromARGB(255, 40, 41, 61);

    return IconButton(
      icon: Icon(Icons.arrow_back, color: secondaryColor),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;
    final Color primaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);

    final results =
        query.isEmpty
            ? pdfs
            : pdfs.where((pdf) {
              final queryLower = query.toLowerCase();
              return pdf.title.toLowerCase().contains(queryLower) ||
                  pdf.description.toLowerCase().contains(queryLower) ||
                  pdf.category.toLowerCase().contains(queryLower);
              // ||
              // pdf.author.toLowerCase().contains(queryLower);
            }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'لم يتم العثور على نتائج',
          style: TextStyle(
            fontSize:
                globalFontSizeChange <= 17
                    ? (globalFontSizeChange / 5) + 18
                    : 18 - (globalFontSizeChange / 5),
            fontFamily: globalFontFamily,
            color: primaryColor.withOpacity(0.7),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.picture_as_pdf, color: primaryColor),
          title: Text(
            results[index].title,
            style: TextStyle(color: primaryColor, fontFamily: globalFontFamily),
          ),
          subtitle: Text(
            results[index].description,
            style: TextStyle(
              color: primaryColor.withOpacity(0.7),
              fontFamily: globalFontFamily,
            ),
          ),
          trailing: Text(
            results[index].category,
            style: TextStyle(color: primaryColor, fontFamily: globalFontFamily),
          ),
          onTap: () {
            close(context, null);
            onPdfSelected(results[index]);
          },
        );
      },
    );
  }
}
