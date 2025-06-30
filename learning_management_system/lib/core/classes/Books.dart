// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
// import '../../view/LogIn.dart';
import 'BookDetails.dart';
import '../../services/SharedPrefs.dart';
import '../../core/constants/ImageAssets.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../controller/NetworkController.dart';
import '../../locale/LocaleController.dart';
import '../../view/NavBar.dart';
import '../../core/function/loadingLottie.dart';

class Books extends StatefulWidget {
  List<Map<String, dynamic>> books = [];
  Map<int, Uint8List> BooksImages = {};
  String title;
   Books({super.key, required this.books, required this.BooksImages,required this.title});

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  late SharedPrefs sharedPrefs;
  final ThemeController themeController = Get.find<ThemeController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final LocaleController localeController = Get.find<LocaleController>();

  List<Map<String, dynamic>> cachedBooks = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _initSharedPreferences().then((_) => _loadInitialData());
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    // Try to load from cache first
    await _loadCachedData();

    // Then try to fetch fresh data if online
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      // await getBooksData();
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load  books data
      final cachedRecommended = sharedPrefs.prefs.getString(
        'cached_books',
      );
      if (cachedRecommended != null) {
        final List<dynamic> parsedRecommendedList = jsonDecode(
          cachedRecommended,
        );
        cachedBooks = List<Map<String, dynamic>>.from(
          parsedRecommendedList,
        );
        widget.books = List.from(cachedBooks);
      }

      // Load images for recommended books
      await _loadRecommendedBooksImages();
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  Future<void> _loadRecommendedBooksImages() async {
    for (var book in widget.books) {
      final imageKey = 'book_image_${book['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          widget.BooksImages[book['id']] = base64Decode(cachedImage);
        });
      }
    }
  }

  Future<void> _cacheRecommendedBooks() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_books',
        jsonEncode(widget.books),
      );
      cachedBooks = List.from(widget.books);
    } catch (e) {
      debugPrint("Error caching books: $e");
    }
  }

  Future<void> _cacheRecommendedBookImage(
    int bookId,
    Uint8List imageBytes,
  ) async {
    try {
      await sharedPrefs.prefs.setString(
        'book_image_$bookId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching book image: $e");
    }
  }

  void showErrorSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(message),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red[800]!,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.books.isEmpty
          ? loadingLottie()
          : RefreshIndicator(
              color: themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
              backgroundColor: themeController.initialTheme ==
                      Themes.customLightTheme
                  ? Color.fromARGB(255, 210, 209, 224)
                  : Color.fromARGB(255, 46, 48, 97),
              onRefresh: () async {
                await networkController.checkConnectivityManually();
                // await getRecommendedBooksData();
              },
              child: Container(
                color: themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 40, 41, 61)
                    : Color.fromARGB(255, 210, 209, 224),
                child: Column(
                  children: [
                    // Header section
                    Container(
                      padding: EdgeInsets.only(top: 30),
                      height: 100,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back_outlined,
                                color: themeController.initialTheme == Themes.customLightTheme
                                    ? Color.fromARGB(255, 210, 209, 224)
                                    : Color.fromARGB(255, 40, 41, 61),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: Get.width / 40,
                                ),
                                child: Text(
                                  widget.title.tr,
                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: themeController.initialTheme == Themes.customLightTheme
                                        ? Color.fromARGB(255, 210, 209, 224)
                                        : Color.fromARGB(255, 40, 41, 61),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              onPressed: () {
                                // Optionally add search here if needed
                              },
                              icon: Icon(
                                Icons.search_outlined,
                                color: themeController.initialTheme == Themes.customLightTheme
                                    ? Color.fromARGB(255, 210, 209, 224)
                                    : Color.fromARGB(255, 40, 41, 61),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    // Main content section with rounded container
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                          color: themeController.initialTheme == Themes.customLightTheme
                              ? Color.fromARGB(255, 210, 209, 224)
                              : Color.fromARGB(255, 40, 41, 61),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60),
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Text(
                              "Choose a book".tr,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                color: themeController.initialTheme == Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                              ),
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              child: ListView.builder(
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: widget.books.length,
                                itemBuilder: (context, i) {
                                  try {
                                    final book = widget.books[i];
                                    final bookId = book["id"] as int? ?? 0;
                                    Uint8List? imageBytes = widget.BooksImages[bookId];
                                    final bookName = book["name"]?.toString() ?? "Unknown Book";
                                    final author = book["author"]?.toString();
                                    return Center(
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.9,
                                        margin: EdgeInsets.symmetric(vertical: 8),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => BookDetails(
                                                  BookData: book,
                                                  bookImage: widget.BooksImages[bookId],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
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
                                                                return Image.asset(
                                                                  ImageAssets.book,
                                                                  fit: BoxFit.cover,
                                                                );
                                                              },
                                                            )
                                                          : Image.asset(
                                                              ImageAssets.book,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 16),
                                                  // Content Section
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          bookName.tr,
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
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.star_outlined,
                                                              size: 14,
                                                              color: Colors.amber,
                                                            ),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              "${book['rating'].toString()}",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.amber,
                                                                fontWeight: FontWeight.w500,
                                                              ),
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
                                      ),
                                    );
                                  } catch (e) {
                                    debugPrint("Error rendering book at index $i: $e");
                                    return Container(
                                      margin: EdgeInsets.all(8),
                                      child: Center(
                                        child: Text(
                                          "Error".tr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 