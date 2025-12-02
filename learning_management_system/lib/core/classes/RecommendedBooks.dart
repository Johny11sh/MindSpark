// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
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

class RecommendedBooks extends StatefulWidget {
  const RecommendedBooks({super.key});

  @override
  State<RecommendedBooks> createState() => _RecommendedBooksState();
}

class _RecommendedBooksState extends State<RecommendedBooks> {
  late SharedPrefs sharedPrefs;
  final ThemeController themeController = Get.find<ThemeController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final LocaleController localeController = Get.find<LocaleController>();

  List<Map<String, dynamic>> recommendedBooks = [];
  // final Map<int, Uint8List> recommendedBooksImages = {};
  List<Map<String, dynamic>> cachedRecommendedBooks = [];

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
      await getRecommendedBooksData();
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load recommended books data
      final cachedRecommended = sharedPrefs.prefs.getString(
        'cached_recommended_books',
      );
      if (cachedRecommended != null) {
        final List<dynamic> parsedRecommendedList = jsonDecode(
          cachedRecommended,
        );
        cachedRecommendedBooks = List<Map<String, dynamic>>.from(
          parsedRecommendedList,
        );
        recommendedBooks = List.from(cachedRecommendedBooks);
      }

      // Load images for recommended books
      // await _loadRecommendedBooksImages();
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  Future<void> _cacheRecommendedBooks() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_recommended_books',
        jsonEncode(recommendedBooks),
      );
      cachedRecommendedBooks = List.from(recommendedBooks);
    } catch (e) {
      debugPrint("Error caching recommended books: $e");
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

  Future<void> getRecommendedBooksData() async {
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
      final APIurl = '$baseUrl/api/recommended-books';

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

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> recommendedBooksList =
            responseBody is List
                ? responseBody
                : (responseBody['books'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            recommendedBooks = List<Map<String, dynamic>>.from(
              recommendedBooksList,
            );
          });
          await _cacheRecommendedBooks();
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (recommendedBooks.isEmpty) {
          setState(() {
            recommendedBooks = List.from(cachedRecommendedBooks);
          });
          if (recommendedBooks.isEmpty) {
            throw Exception(
              "Failed to load recommended books: ${response.statusCode}",
            );
          }
        }
      }
    } on TimeoutException {
      if (recommendedBooks.isEmpty) {
        setState(() {
          recommendedBooks = List.from(cachedRecommendedBooks);
        });
        if (recommendedBooks.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (recommendedBooks.isEmpty) {
        setState(() {
          recommendedBooks = List.from(cachedRecommendedBooks);
        });
        if (recommendedBooks.isEmpty) {
          showErrorSnackbar("Failed to load recommended books");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching recommended books: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Recommended Books".tr),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body:
            recommendedBooks.isEmpty
                ? Center(
                  child: CircularProgressIndicator(
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 40, 41, 61)
                            : Color.fromARGB(255, 210, 209, 224),
                  ),
                )
                : RefreshIndicator(
                  color:
                      themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 40, 41, 61)
                          : Color.fromARGB(255, 210, 209, 224),
                  backgroundColor:
                      themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 210, 209, 224)
                          : Color.fromARGB(255, 46, 48, 97),
                  onRefresh: () async {
                    await networkController.checkConnectivityManually();
                    await getRecommendedBooksData();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        recommendedBooks.length + 1, // +1 for bottom spacing
                    itemBuilder: (context, index) {
                      if (index == recommendedBooks.length) {
                        // Bottom spacing item
                        return SizedBox(height: 30);
                      }

                      // int bookId = recommendedBooks[index]["id"];
                      // Uint8List? imageBytes = recommendedBooksImages[bookId];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => BookDetails(
                                      BookData: recommendedBooks[index],
                                      // bookImage: recommendedBooksImages[bookId],
                                    ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            child: SizedBox(
                              height: 120,
                              child: Row(
                                children: [
                                  // Book Image
                                  SizedBox(
                                    width: 120,
                                    height: 120,
                                    child:
                                        recommendedBooks[index]["image"] != null
                                            ? CachedNetworkImage(
                                              imageUrl:
                                                  "$mainIP/${recommendedBooks[index]["image"]}",
                                              height: 60,
                                              width: 60,
                                            )
                                            : Image.asset(
                                              ImageAssets.subject,
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                                  // Book Details
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${recommendedBooks[index]["name"]}"
                                                .tr,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  themeController
                                                              .initialTheme ==
                                                          Themes
                                                              .customLightTheme
                                                      ? Color.fromARGB(
                                                        255,
                                                        40,
                                                        41,
                                                        61,
                                                      )
                                                      : Color.fromARGB(
                                                        255,
                                                        210,
                                                        209,
                                                        224,
                                                      ),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Book ID: ${recommendedBooks[index]["id"]}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  themeController
                                                              .initialTheme ==
                                                          Themes
                                                              .customLightTheme
                                                      ? Color.fromARGB(
                                                        255,
                                                        40,
                                                        41,
                                                        61,
                                                      ).withValues(alpha: 0.7)
                                                      : Color.fromARGB(
                                                        255,
                                                        210,
                                                        209,
                                                        224,
                                                      ).withValues(alpha: 0.7),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Recommended",
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
                                  ),
                                  // Arrow Icon
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
