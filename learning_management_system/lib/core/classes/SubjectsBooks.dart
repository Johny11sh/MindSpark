// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../view/LogIn.dart';
import 'BookDetails.dart';
import '../../services/SharedPrefs.dart';
import '../../core/constants/ImageAssets.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../controller/NetworkController.dart';
import '../../locale/LocaleController.dart';
import '../../view/NavBar.dart';
import '../function/DynamicSearch.dart';

class SubjectsBooks extends StatefulWidget {
  final int subjectId;
  final String subjectName;
  
  const SubjectsBooks({
    super.key, 
    required this.subjectId, 
    required this.subjectName,
  });

  @override
  State<SubjectsBooks> createState() => _SubjectsBooksState();
}

class _SubjectsBooksState extends State<SubjectsBooks> {
  late SharedPrefs sharedPrefs;
  final ThemeController themeController = Get.find<ThemeController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final LocaleController localeController = Get.find<LocaleController>();
  ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> subjectBooks = [];
  final Map<int, Uint8List> subjectBooksImages = {};
  List<Map<String, dynamic>> cachedSubjectBooks = [];

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
      await getSubjectBooksData();
    }
  }

  Future<void> _loadCachedData() async {
    try {
      debugPrint("Loading cached data for subject ${widget.subjectId}");
      
      // Load subject books data
      final cachedSubjectBooksData = sharedPrefs.prefs.getString(
        'cached_subject_books_${widget.subjectId}',
      );
      if (cachedSubjectBooksData != null) {
        try {
          final List<dynamic> parsedSubjectBooksList = jsonDecode(
            cachedSubjectBooksData,
          );
          cachedSubjectBooks = List<Map<String, dynamic>>.from(
            parsedSubjectBooksList,
          );
          subjectBooks = List.from(cachedSubjectBooks);
          debugPrint("Loaded ${subjectBooks.length} cached books for subject ${widget.subjectId}");
        } catch (e) {
          debugPrint("Error parsing cached books data: $e");
          // Clear corrupted cache
          await sharedPrefs.prefs.remove('cached_subject_books_${widget.subjectId}');
        }
      } else {
        debugPrint("No cached books found for subject ${widget.subjectId}");
      }

      // Load images for subject books
      await _loadSubjectBooksImages();
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  Future<void> _loadSubjectBooksImages() async {
    try {
      for (var book in subjectBooks) {
        try {
          final bookId = book['id'] as int?;
          if (bookId != null) {
            final imageKey = 'subject_book_image_$bookId';
            final cachedImage = sharedPrefs.prefs.getString(imageKey);
            if (cachedImage != null && mounted) {
              setState(() {
                subjectBooksImages[bookId] = base64Decode(cachedImage);
              });
            }
          }
        } catch (e) {
          debugPrint("Error loading image for book: $e");
        }
      }
    } catch (e) {
      debugPrint("Error loading subject books images: $e");
    }
  }

  Future<void> _cacheSubjectBooks() async {
    try {
      if (subjectBooks.isNotEmpty) {
        await sharedPrefs.prefs.setString(
          'cached_subject_books_${widget.subjectId}',
          jsonEncode(subjectBooks),
        );
        cachedSubjectBooks = List.from(subjectBooks);
        debugPrint("Cached ${subjectBooks.length} books for subject ${widget.subjectId}");
      }
    } catch (e) {
      debugPrint("Error caching subject books: $e");
    }
  }

  Future<void> _cacheSubjectBookImage(
    int bookId,
    Uint8List imageBytes,
  ) async {
    try {
      await sharedPrefs.prefs.setString(
        'subject_book_image_$bookId',
        base64Encode(imageBytes),
      );
      debugPrint("Cached image for book $bookId");
    } catch (e) {
      debugPrint("Error caching subject book image: $e");
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

  Future<void> getSubjectBooksData() async {
    final token = sharedPrefs.prefs.getString('token') ?? '';
    if (token.isEmpty) {
      debugPrint("Token empty, redirecting to login");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => LogIn());
        showErrorSnackbar("Session expired. Please log in again.");
      });
      return;
    }

    try {
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/getsubjectresources/${widget.subjectId}';
      
      debugPrint("Fetching books for subject ID: ${widget.subjectId}");
      debugPrint("API URL: $APIurl");

      final response = await http
          .get(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("Subject books API response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> subjectBooksList =
            responseBody is List
                ? responseBody
                : (responseBody['resources'] ?? [responseBody]);

        debugPrint("Parsed books list: ${subjectBooksList.length} books");

        if (mounted) {
          setState(() {
            subjectBooks = List<Map<String, dynamic>>.from(
              subjectBooksList,
            );
          });
          await _cacheSubjectBooks();
        }

        await Future.wait(
          subjectBooksList.map((book) async {
            final bookId = book['id'] as int;
            final imageBytes = await getSubjectBookImage(book);
            if (imageBytes != null && mounted) {
              setState(() {
                subjectBooksImages[bookId] = imageBytes;
              });
              await _cacheSubjectBookImage(bookId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        debugPrint("Failed to load subject books: ${response.statusCode}");
        if (subjectBooks.isEmpty) {
          setState(() {
            subjectBooks = List.from(cachedSubjectBooks);
          });
          if (subjectBooks.isEmpty) {
            showErrorSnackbar("Failed to load subject books: ${response.statusCode}");
          } else {
            showErrorSnackbar("Using cached data - API returned ${response.statusCode}");
          }
        }
      }
    } on TimeoutException {
      debugPrint("Timeout loading subject books");
      if (subjectBooks.isEmpty) {
        setState(() {
          subjectBooks = List.from(cachedSubjectBooks);
        });
        if (subjectBooks.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      debugPrint("Error fetching subject books: $e");
      debugPrint("Error stack trace: ${StackTrace.current}");
      if (subjectBooks.isEmpty) {
        setState(() {
          subjectBooks = List.from(cachedSubjectBooks);
        });
        if (subjectBooks.isEmpty) {
          showErrorSnackbar("Failed to load subject books: $e");
        } else {
          showErrorSnackbar("Using cached data - $e");
        }
      }
    }
  }

  Future<Uint8List?> getSubjectBookImage(dynamic book) async {
    final bookId = book is Map ? book['id'] as int : book as int;
    final cachedImage = sharedPrefs.prefs.getString(
      'subject_book_image_$bookId',
    );
    if (cachedImage != null) {
      return base64Decode(cachedImage);
    }

    if (sharedPrefs.prefs.getBool('isConnected') == false) {
      return null;
    }

    try {
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) return null;

      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final url = '$baseUrl/api/getresourceimage/$bookId';
      
      debugPrint("Fetching image for book ID: $bookId");
      debugPrint("Image URL: $url");

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': "Bearer $token",
              'Accept': 'application/octet-stream',
            },
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("Image API response for book $bookId: ${response.statusCode}");

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 404) {
        debugPrint("Subject book image not found for ID: $bookId");
        return null;
      } else {
        debugPrint("Image fetch failed for book $bookId: ${response.statusCode}");
        return null;
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for subject book $bookId");
      return null;
    } catch (e) {
      debugPrint("Error fetching subject book image for $bookId: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: subjectBooks.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                  color: themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 40, 41, 61)
                      : Color.fromARGB(255, 210, 209, 224),
                ),
              )
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
                  await getSubjectBooksData();
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
                                  "${widget.subjectName} Books".tr,
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
                                showSearch(
                                  context: context,
                                  delegate: DynamicSearch(
                                    elements: subjectBooks,
                                    elementsImages: subjectBooksImages,
                                    searchType: 'books',
                                    subjectName: widget.subjectName,
                                    onItemTap: (book) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookDetails(
                                            BookData: book,
                                            bookImage: subjectBooksImages[book['id']],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
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
                              child: GridView.builder(
                                scrollDirection: Axis.vertical,
                                physics: AlwaysScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                controller: scrollController,
                                itemCount: subjectBooks.length,
                                itemBuilder: (context, i) {
                                  try {
                                    final book = subjectBooks[i];
                      final bookId = book["id"] as int? ?? 0;
                      Uint8List? imageBytes = subjectBooksImages[bookId];
                      final bookName = book["name"]?.toString() ?? "Unknown Book";

                                    return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetails(
                                  BookData: book,
                                  bookImage: subjectBooksImages[bookId],
                                ),
                              ),
                            );
                          },
                            child: Container(
                                        margin: EdgeInsets.only(
                                          left: 1,
                                          right: 1,
                                          top: 2,
                                        ),
                                        padding: EdgeInsets.all(10),
                              height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: themeController.initialTheme == Themes.customLightTheme
                                                ? Color.fromARGB(255, 40, 41, 61)
                                                : Color.fromARGB(255, 210, 209, 224),
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                children: [
                                  // Book Image
                                  SizedBox(
                                              height: 60,
                                              width: 60,
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
                                            SizedBox(height: 8),
                                            
                                            // Book Name
                                          Text(
                                            bookName.tr,
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal,
                                                color: themeController.initialTheme == Themes.customLightTheme
                                                  ? Color.fromARGB(255, 40, 41, 61)
                                                  : Color.fromARGB(255, 210, 209, 224),
                                            ),
                                            maxLines: 2,
                                              textAlign: TextAlign.center,
                                          ),
                                            
                                            SizedBox(height: 4),
                                            
                                            // Subject Name with Icon
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.book,
                                                  size: 12,
                                                color: Colors.blue,
                                              ),
                                                SizedBox(width: 2),
                                                Expanded(
                                                  child: Text(
                                                widget.subjectName,
                                                style: TextStyle(
                                                      fontSize: 10,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    );
                                  } catch (e) {
                                    debugPrint("Error rendering book at index $i: $e");
                                    return Container(
                                      margin: EdgeInsets.only(
                                        left: 1,
                                        right: 1,
                                        top: 2,
                                      ),
                                      padding: EdgeInsets.all(10),
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: themeController.initialTheme == Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                    ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
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