// ignore_for_file: file_names, must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../services/CacheManager.dart';
import '../../view/LogIn.dart';
import '../../view/NavBar.dart';
import '../function/DynamicSearch.dart';
import 'BookDetails.dart';
import '../../services/SharedPrefs.dart';
import '../../core/constants/ImageAssets.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../controller/NetworkController.dart';
import '../../locale/LocaleController.dart';
import '../../core/function/loadingLottie.dart';
import '../constants/FontGlobals.dart';

class Books extends StatefulWidget {
  // List<Map<String, dynamic>> books = [];
  String title;
  Books({
    super.key,
    //  required this.books,
    required this.title,
  });

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  late SharedPrefs sharedPrefs;
  final ThemeController themeController = Get.find<ThemeController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final LocaleController localeController = Get.find<LocaleController>();

  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> cachedBooks = [];

  List<Map<String, dynamic>> recommendedBooks = [];
  List<Map<String, dynamic>> cachedRecommendedBooks = [];

  List<Map<String, dynamic>> topRatedBooks = [];
  List<Map<String, dynamic>> cachedTopRatedBooks = [];

  List<Map<String, dynamic>> recentBooks = [];
  List<Map<String, dynamic>> cachedRecentBooks = [];
  final CacheManager cacheManager = CacheManager();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _initSharedPreferences().then((_) {
      cacheManager.init();
      networkController.onInit();
      print('caching: ${cacheManager.isCacheEnabled.value}');
      print('connection: ${sharedPrefs.prefs.getBool('isConnected')}');
      (cacheManager.isCacheEnabled.value == false &&
              sharedPrefs.prefs.getBool('isConnected') == false)
          ? print('caching is disabled')
          : _loadInitialData();
    });
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
      final APIurl = '$baseUrl/api/getallresourcesrecommended';

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
                : (responseBody['resources'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            recommendedBooks = List<Map<String, dynamic>>.from(
              recommendedBooksList,
            );
            books = List.from(recommendedBooks);
            print(recommendedBooks);
            print("                   000                 0000             00");
            print(books);
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
          books = List.from(recommendedBooks);

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
        books = List.from(recommendedBooks);

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
        books = List.from(recommendedBooks);

        if (recommendedBooks.isEmpty) {
          showErrorSnackbar("Failed to load recommended books");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching recommended books: $e");
    }
  }

  Future<void> getTopRatedBooksData() async {
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
      final APIurl = '$baseUrl/api/getallresourcesrated';

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
        final List<dynamic> topRatedBooksList =
            responseBody is List
                ? responseBody
                : (responseBody['resources'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            topRatedBooks = List<Map<String, dynamic>>.from(topRatedBooksList);
          });
          books = List.from(topRatedBooks);

          await _cacheTopRatedBooks();
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (topRatedBooks.isEmpty) {
          setState(() {
            topRatedBooks = List.from(cachedTopRatedBooks);
          });
          books = List.from(topRatedBooks);

          if (topRatedBooks.isEmpty) {
            throw Exception(
              "Failed to load top rated books: ${response.statusCode}",
            );
          }
        }
      }
    } on TimeoutException {
      if (topRatedBooks.isEmpty) {
        setState(() {
          topRatedBooks = List.from(cachedTopRatedBooks);
        });
        books = List.from(topRatedBooks);

        if (topRatedBooks.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (topRatedBooks.isEmpty) {
        setState(() {
          topRatedBooks = List.from(cachedTopRatedBooks);
        });
        books = List.from(topRatedBooks);

        if (topRatedBooks.isEmpty) {
          showErrorSnackbar("Failed to load top rated books");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching top rated books: $e");
    }
  }

  Future<void> getRecentBooksData() async {
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
      final APIurl = '$baseUrl/api/getallresourcesrecent';

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
        final List<dynamic> recentBooksList =
            responseBody is List
                ? responseBody
                : (responseBody['resources'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            recentBooks = List<Map<String, dynamic>>.from(recentBooksList);
          });
          books = List.from(recentBooks);

          await _cacheRecentBooks();
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (recentBooks.isEmpty) {
          setState(() {
            recentBooks = List.from(cachedRecentBooks);
          });
          books = List.from(recentBooks);

          if (recentBooks.isEmpty) {
            throw Exception(
              "Failed to load recent books: ${response.statusCode}",
            );
          }
        }
      }
    } on TimeoutException {
      if (recentBooks.isEmpty) {
        setState(() {
          recentBooks = List.from(cachedRecentBooks);
        });
        books = List.from(recentBooks);

        if (recentBooks.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (recentBooks.isEmpty) {
        setState(() {
          recentBooks = List.from(cachedRecentBooks);
        });
        books = List.from(recentBooks);

        if (recentBooks.isEmpty) {
          showErrorSnackbar("Failed to load recent books");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching recent books: $e");
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

  Future<void> _cacheTopRatedBooks() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_top_rated_books',
        jsonEncode(topRatedBooks),
      );
      cachedTopRatedBooks = List.from(topRatedBooks);
    } catch (e) {
      debugPrint("Error caching top rated books: $e");
    }
  }

  Future<void> _cacheRecentBooks() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_recent_books',
        jsonEncode(recentBooks),
      );
      cachedRecentBooks = List.from(recentBooks);
    } catch (e) {
      debugPrint("Error caching recent books: $e");
    }
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    // await _cacheBooks();

    await _loadCachedData();
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      if (widget.title == "Recommended Books".tr) {
        await getRecommendedBooksData();
        if (recommendedBooks.isNotEmpty) {
          setState(() {
            books = List.from(recommendedBooks);
          });
        }
      } else if (widget.title == "Top Rated Books".tr) {
        await getTopRatedBooksData();
        if (topRatedBooks.isNotEmpty) {
          setState(() {
            books = List.from(topRatedBooks);
          });
        }
      } else if (widget.title == "Recent Books".tr) {
        await getRecentBooksData();
        if (recentBooks.isNotEmpty) {
          setState(() {
            books = List.from(recentBooks);
          });
        }
      }
    }
  }

  Future<void> _loadCachedData() async {
    try {
      final cachedRecommended = sharedPrefs.prefs.getString(
        'cached_recommended_books',
      );
      if (cachedRecommended != null) {
        final List<dynamic> parsedRecommendedList = jsonDecode(
          cachedRecommended,
        );
        cachedBooks = List<Map<String, dynamic>>.from(parsedRecommendedList);
        books = List.from(cachedBooks);
      }
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }

    try {
      final cachedTopRatedBooks = sharedPrefs.prefs.getString(
        'cached_top_rated_books',
      );
      if (cachedTopRatedBooks != null) {
        final List<dynamic> parsedTopRatedList = jsonDecode(
          cachedTopRatedBooks,
        );
        cachedBooks = List<Map<String, dynamic>>.from(parsedTopRatedList);
        books = List.from(cachedBooks);
      }
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }

    try {
      final cachedRecentBooks = sharedPrefs.prefs.getString(
        'cached_recent_books',
      );
      if (cachedRecentBooks != null) {
        final List<dynamic> parsedRecentList = jsonDecode(cachedRecentBooks);
        cachedBooks = List<Map<String, dynamic>>.from(parsedRecentList);
        books = List.from(cachedBooks);
      }
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  void showErrorSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: TextStyle(fontFamily: globalFontFamily),
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red[800]!,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body:
            books.isEmpty
                ? loadingLottie()
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
                    // await getRecommendedBooksData();
                  },
                  child: Container(
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 40, 41, 61)
                            : Color.fromARGB(255, 210, 209, 224),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 30),
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
                                    color:
                                        themeController.initialTheme ==
                                                Themes.customLightTheme
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
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall!.copyWith(
                                            fontFamily: globalFontFamily,
                                            color:
                                                themeController.initialTheme ==
                                                        Themes.customLightTheme
                                                    ? Color.fromARGB(
                                                      255,
                                                      210,
                                                      209,
                                                      224,
                                                    )
                                                    : Color.fromARGB(
                                                      255,
                                                      40,
                                                      41,
                                                      61,
                                                    ),
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        23
                                                    : 23 -
                                                        (globalFontSizeChange /
                                                            5),
                                          ),
                                        )
                                        .animate(
                                          onPlay:
                                              (controller) => controller.loop(),
                                        )
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
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                      onPressed: () {
                                        showSearch(
                                          context: context,
                                          delegate: DynamicSearch(
                                            elements: books,
                                            // elementsImages: subjectBooksImages,
                                            searchType: 'books',
                                            subjectName: widget.title,
                                            onItemTap: (book) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => BookDetails(
                                                        BookData: book,
                                                        // bookImage:
                                                        //     subjectBooksImages[book['id']],
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.search_outlined,
                                        color:
                                            themeController.initialTheme ==
                                                    Themes.customLightTheme
                                                ? Color.fromARGB(
                                                  255,
                                                  210,
                                                  209,
                                                  224,
                                                )
                                                : Color.fromARGB(
                                                  255,
                                                  40,
                                                  41,
                                                  61,
                                                ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 300.ms)
                                    .slideX(begin: 0.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            decoration: BoxDecoration(
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 210, 209, 224)
                                      : Color.fromARGB(255, 40, 41, 61),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(60),
                                topRight: Radius.circular(60),
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  "Choose a book".tr,
                                  style: TextStyle(
                                    fontFamily: globalFontFamily,
                                    fontSize:
                                        globalFontSizeChange <= 17
                                            ? (globalFontSizeChange / 5) + 22
                                            : 22 - (globalFontSizeChange / 5),
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
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
                                const SizedBox(height: 20),
                                Expanded(
                                  child: ListView.builder(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount: books.length,
                                    itemBuilder: (context, i) {
                                      try {
                                        final book = books[i];
                                        final bookName =
                                            book["name"]?.toString() ??
                                            "Unknown Book";
                                        final author =
                                            book["author"]?.toString();
                                        return Center(
                                          child: Container(
                                                width:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.9,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => BookDetails(
                                                              BookData: book,
                                                              // bookImage:
                                                              //     widget
                                                              //         .BooksImages[bookId],
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Card(
                                                    elevation: 4,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                    ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            16,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          // Image Section
                                                          Container(
                                                            width: 60,
                                                            height: 60,
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    themeController.initialTheme ==
                                                                            Themes.customLightTheme
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
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    9,
                                                                  ),
                                                              child:
                                                                  books[i]['image'] !=
                                                                          null
                                                                      ? CachedNetworkImage(
                                                                        imageUrl:
                                                                            "$mainIP/${books[i]['image']}",
                                                                        height:
                                                                            60,
                                                                        width:
                                                                            60,
                                                                      )
                                                                      : Image.asset(
                                                                        ImageAssets
                                                                            .book,
                                                                        fit:
                                                                            BoxFit.cover,
                                                                      ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 16,
                                                          ),
                                                          // Content Section
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  bookName.tr,
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        globalFontFamily,
                                                                    fontSize:
                                                                        globalFontSizeChange >=
                                                                                17
                                                                            ? (globalFontSizeChange /
                                                                                    5) +
                                                                                16
                                                                            : 16 -
                                                                                (globalFontSizeChange /
                                                                                    5),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color:
                                                                        themeController.initialTheme ==
                                                                                Themes.customLightTheme
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
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .star_outlined,
                                                                      size: 14,
                                                                      color:
                                                                          Colors
                                                                              .amber,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 4,
                                                                    ),
                                                                    Text(
                                                                      book['rating']
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            globalFontSizeChange >=
                                                                                    17
                                                                                ? (globalFontSizeChange /
                                                                                        5) +
                                                                                    12
                                                                                : 12 -
                                                                                    (globalFontSizeChange /
                                                                                        5),
                                                                        fontFamily:
                                                                            globalFontFamily,
                                                                        color:
                                                                            Colors.amber,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  "By: $author"
                                                                      .tr
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        globalFontSizeChange >=
                                                                                17
                                                                            ? (globalFontSizeChange /
                                                                                    5) +
                                                                                14
                                                                            : 14 -
                                                                                (globalFontSizeChange /
                                                                                    5),
                                                                    fontFamily:
                                                                        globalFontFamily,
                                                                    color:
                                                                        themeController.initialTheme ==
                                                                                Themes.customLightTheme
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
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ).animate().fadeIn(
                                                                  delay: 100.ms,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .animate(delay: (i * 50).ms)
                                              .fadeIn(duration: 400.ms)
                                              .slideX(
                                                begin: 0.5,
                                                end: 0,
                                                curve: Curves.easeOutBack,
                                                duration: 300.ms,
                                              )
                                              .scaleXY(
                                                begin: 0.8,
                                                end: 1,
                                                duration: 400.ms,
                                                curve: Curves.elasticOut,
                                              ),
                                        );
                                      } catch (e) {
                                        debugPrint(
                                          "Error rendering book at index $i: $e",
                                        );
                                        return Container(
                                          margin: const EdgeInsets.all(8),
                                          child: Center(
                                            child: Text(
                                              "Error".tr,
                                              style: TextStyle(
                                                fontFamily: globalFontFamily,
                                                fontSize:
                                                    globalFontSizeChange <= 17
                                                        ? (globalFontSizeChange /
                                                                5) +
                                                            12
                                                        : 12 -
                                                            (globalFontSizeChange /
                                                                5),
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
