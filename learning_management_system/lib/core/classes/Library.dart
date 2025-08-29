// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../../services/CacheManager.dart';
import '../../controller/FontController.dart';
import 'Books.dart';
import '../../controller/NetworkController.dart';
import '../../locale/LocaleController.dart';
import '../../services/SharedPrefs.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../view/Favorites.dart';
import '../../view/LogIn.dart';
import '../../view/NavBar.dart';
import '../constants/ImageAssets.dart';
import 'BookDetails.dart';
import 'SubjectsBooks.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final CacheManager cacheManager = CacheManager();

  ScrollController scrollController = ScrollController();
  late SharedPrefs sharedPrefs;

  List<Map<String, dynamic>> recommendedBooks = [];
  List<Map<String, dynamic>> topRatedBooks = [];

  List<Map<String, dynamic>> recentBooks = [];

  List<Map<String, dynamic>> cachedRecommendedBooks = [];
  List<Map<String, dynamic>> cachedTopRatedBooks = [];
  List<Map<String, dynamic>> cachedRecentBooks = [];
  List<Map<String, dynamic>> cachedLiterarySubjects = [];
  List<Map<String, dynamic>> cachedScientificSubjects = [];

  List<Map<String, dynamic>> scientificSubjects = [];
  List<Map<String, dynamic>> literarySubjects = [];

  @override
  void initState() {
    super.initState();
    _initSharedPreferences().then((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await Future.wait([getBooksData()]);
    } else {
      if (cacheManager.isCacheEnabled.value == true) {
        await _loadCachedData();
      }
    }
  }

  Future<void> _loadCachedData() async {
    try {
      final cachedScientificSubjects = sharedPrefs.prefs.getString(
        'cached_scientific_subjects',
      );
      if (cachedScientificSubjects != null) {
        final List<dynamic> parsedScientificList = jsonDecode(
          cachedScientificSubjects,
        );
        scientificSubjects = List<Map<String, dynamic>>.from(
          parsedScientificList,
        );
      }

      final cachedLiterarySubjects = sharedPrefs.prefs.getString(
        'cached_literary_subjects',
      );
      if (cachedLiterarySubjects != null) {
        final List<dynamic> parsedLiteraryList = jsonDecode(
          cachedLiterarySubjects,
        );
        literarySubjects = List<Map<String, dynamic>>.from(parsedLiteraryList);
      }

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

      // Load top-rated books data
      final cachedTopRated = sharedPrefs.prefs.getString(
        'cached_top_rated_books',
      );
      if (cachedTopRated != null) {
        final List<dynamic> parsedTopRatedList = jsonDecode(cachedTopRated);
        cachedTopRatedBooks = List<Map<String, dynamic>>.from(
          parsedTopRatedList,
        );
        topRatedBooks = List.from(cachedTopRatedBooks);
      }

      final cachedRecent = sharedPrefs.prefs.getString('cached_recent_books');
      if (cachedRecent != null) {
        final List<dynamic> parsedRecentList = jsonDecode(cachedRecent);
        cachedRecentBooks = List<Map<String, dynamic>>.from(parsedRecentList);
        recentBooks = List.from(cachedRecentBooks);
      }

      // Load images for all types in parallel
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  Future<void> getBooksData() async {
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
      final APIurl = '$baseUrl/api/getallresourcespage';

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
        print("StatusCode                     200");

        final responseBody = jsonDecode(response.body);
        final List<dynamic> recommendedBooksList =
            responseBody is List
                ? responseBody
                : (responseBody['recommended'] ?? [responseBody]);

        final List<dynamic> topRatedBooksList =
            responseBody is List
                ? responseBody
                : (responseBody['top_rated'] ?? [responseBody]);

        final List<dynamic> recentBooksList =
            responseBody is List
                ? responseBody
                : (responseBody['recent'] ?? [responseBody]);

        final List<dynamic> scientificSubjectsList =
            responseBody is List
                ? responseBody
                : (responseBody['scientificSubjects'] ?? [responseBody]);

        final List<dynamic> literarySubjectsList =
            responseBody is List
                ? responseBody
                : (responseBody['literarySubjects'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            recommendedBooks = List<Map<String, dynamic>>.from(
              recommendedBooksList,
            );
            topRatedBooks = List<Map<String, dynamic>>.from(topRatedBooksList);
            recentBooks = List<Map<String, dynamic>>.from(recentBooksList);
            scientificSubjects = List<Map<String, dynamic>>.from(
              scientificSubjectsList,
            );
            literarySubjects = List<Map<String, dynamic>>.from(
              literarySubjectsList,
            );
          });
          if (cacheManager.isCacheEnabled.value == true) {
            await _cacheSubjectsData();
            await _cacheRecommendedBooks();
            await _cacheTopRatedBooks();
            await _cacheRecentBooks();
          }
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        print("StatusCode             not        200 ${response.statusCode}");

        if (recommendedBooks.isEmpty ||
            topRatedBooks.isEmpty ||
            recentBooks.isEmpty ||
            scientificSubjects.isEmpty ||
            literarySubjects.isEmpty) {
          setState(() {
            recommendedBooks = List.from(cachedRecommendedBooks);
            topRatedBooks = List.from(cachedTopRatedBooks);
            recentBooks = List.from(cachedRecentBooks);
            scientificSubjects = List.from(cachedScientificSubjects);
            literarySubjects = List.from(cachedLiterarySubjects);
          });
          if (recommendedBooks.isEmpty ||
              topRatedBooks.isEmpty ||
              recentBooks.isEmpty ||
              scientificSubjects.isEmpty ||
              literarySubjects.isEmpty) {
            showErrorSnackbar("Request timeout. Please try again.");
          } else {
            showErrorSnackbar("Using cached data - connection is slow");
          }
        }
      }
    } on TimeoutException {
      if (recommendedBooks.isEmpty ||
          topRatedBooks.isEmpty ||
          recentBooks.isEmpty ||
          scientificSubjects.isEmpty ||
          literarySubjects.isEmpty) {
        setState(() {
          recommendedBooks = List.from(cachedRecommendedBooks);
          topRatedBooks = List.from(cachedTopRatedBooks);
          recentBooks = List.from(cachedRecentBooks);
          scientificSubjects = List.from(cachedScientificSubjects);
          literarySubjects = List.from(cachedLiterarySubjects);
        });
        if (recommendedBooks.isEmpty ||
            topRatedBooks.isEmpty ||
            recentBooks.isEmpty ||
            scientificSubjects.isEmpty ||
            literarySubjects.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (recommendedBooks.isEmpty ||
          topRatedBooks.isEmpty ||
          recentBooks.isEmpty ||
          scientificSubjects.isEmpty ||
          literarySubjects.isEmpty) {
        setState(() {
          recommendedBooks = List.from(cachedRecommendedBooks);
          topRatedBooks = List.from(cachedTopRatedBooks);
          recentBooks = List.from(cachedRecentBooks);
          scientificSubjects = List.from(cachedScientificSubjects);
          literarySubjects = List.from(cachedLiterarySubjects);
        });
        if (recommendedBooks.isEmpty ||
            topRatedBooks.isEmpty ||
            recentBooks.isEmpty ||
            scientificSubjects.isEmpty ||
            literarySubjects.isEmpty) {
          showErrorSnackbar("Failed to load recommended books");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching recommended books: $e");
    }
  }

  Future<void> _cacheSubjectsData() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_scientific_subjects',
        jsonEncode(scientificSubjects),
      );
      // scientificSubjects = List.from(cachedScientificSubjects);

      await sharedPrefs.prefs.setString(
        'cached_literary_subjects',
        jsonEncode(literarySubjects),
      );
      // literarySubjects = List.from(cachedLiterarySubjects);
    } catch (e) {
      debugPrint("Error caching subjects data: $e");
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
      debugPrint("Error caching top-rated books: $e");
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

  void showErrorSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: TextStyle(fontFamily: FontController().currentFontFamily),
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red[800]!,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body:
            (cacheManager.isCacheEnabled.value == false &&
                    sharedPrefs.prefs.getBool('isConnected') == false)
                ? Center(
                  child: Lottie.asset(
                    ImageAssets.noDataLottie,
                    width: 300,
                    height: 300,
                  ),
                )
                : (scientificSubjects.isEmpty && literarySubjects.isEmpty)
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
                    await Future.wait([
                      // getSubjectsData('scientific'),
                      // getSubjectsData('literary'),
                      getBooksData(),
                      // getTopRatedBooksData(),
                      // getRecentBooksData(),
                    ]);
                  },
                  child: Container(
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 40, 41, 61)
                            : Color.fromARGB(255, 210, 209, 224),
                    child: Column(
                      // scrollDirection: Axis.vertical,
                      // physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 30),
                          height: 100,
                          // color: Colors.red,
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: IconButton(
                                  onPressed: () {
                                    Get.to(Favorites());
                                  },
                                  icon: Icon(Icons.favorite, color: Colors.red),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: Get.width / 8,
                                    ),

                                    child: Text(
                                      "Library".tr,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall!.copyWith(
                                        fontFamily:
                                            FontController().currentFontFamily,
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
                                        fontSize: 23,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 30),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 20),
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
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                Center(
                                  child: Text(
                                    "Scientific Subjects".tr,
                                    style: TextStyle(
                                      fontFamily:
                                          FontController().currentFontFamily,
                                      fontSize: 24,
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
                                ),
                                const SizedBox(height: 15),
                                SizedBox(
                                  // margin: const EdgeInsets.only(left: 10),
                                  height: 150,
                                  child:
                                      scientificSubjects.isEmpty
                                          ? Center(
                                            child: Text(
                                              "No scientific subjects found",
                                              style: TextStyle(
                                                fontFamily:
                                                    FontController()
                                                        .currentFontFamily,
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
                                            ),
                                          )
                                          : ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            itemCount:
                                                scientificSubjects.length,
                                            itemBuilder: (context, index) {
                                              int subjectId =
                                                  scientificSubjects[index]['id'];

                                              // Uint8List? imageBytes =
                                              //     subjectsImages[subjectId];

                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  right: 10,
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => SubjectsBooks(
                                                              subjectId:
                                                                  subjectId,
                                                              subjectName:
                                                                  scientificSubjects[index]["name"],
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              left: 1,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              10,
                                                            ),
                                                        height: 120,
                                                        width: 120,
                                                        decoration: BoxDecoration(
                                                          // color: Colors.red,
                                                          border: Border.all(
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
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                15,
                                                              ),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            scientificSubjects[index]["image"] !=
                                                                    null
                                                                ? CachedNetworkImage(
                                                                  imageUrl:
                                                                      "$mainIP/${scientificSubjects[index]["image"]}",
                                                                  height: 60,
                                                                  width: 60,
                                                                )
                                                                // Image.asset(
                                                                //   // ImageAssets.UserDarkMode,
                                                                //   ImageAssets
                                                                //       .book,
                                                                //   height: 70,
                                                                //   width: 70,
                                                                // )
                                                                : Image.asset(
                                                                  // ImageAssets.UserDarkMode,
                                                                  ImageAssets
                                                                      .book,
                                                                  height: 70,
                                                                  width: 70,
                                                                ),
                                                            // const const SizedBox(
                                                            //   height: 10,
                                                            // ),
                                                            Text(
                                                              "${scientificSubjects[index]["name"]}"
                                                                  .tr,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    FontController()
                                                                        .currentFontFamily,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
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
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                ),
                                // const SizedBox(height: 30),
                                // Literary Subjects Section
                                Center(
                                  child: Text(
                                    "Literary Subjects".tr,
                                    style: TextStyle(
                                      fontFamily:
                                          FontController().currentFontFamily,
                                      fontSize: 24,
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
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 120,
                                  child:
                                      literarySubjects.isEmpty
                                          ? Center(
                                            child: Text(
                                              "No literary subjects found",
                                              style: TextStyle(
                                                fontFamily:
                                                    FontController()
                                                        .currentFontFamily,
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
                                            ),
                                          )
                                          : ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            itemCount: literarySubjects.length,
                                            itemBuilder: (context, index) {
                                              int subjectId =
                                                  literarySubjects[index]["id"];
                                              // Uint8List? imageBytes =
                                              //     subjectsImages[subjectId];

                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  right: 10,
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => SubjectsBooks(
                                                              subjectId:
                                                                  subjectId,
                                                              subjectName:
                                                                  literarySubjects[index]["name"],
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          left: 1,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    height: 120,
                                                    width: 120,
                                                    decoration: BoxDecoration(
                                                      // color: Colors.red,
                                                      border: Border.all(
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        literarySubjects[index]["image"] !=
                                                                null
                                                            ? CachedNetworkImage(
                                                              imageUrl:
                                                                  "$mainIP/${literarySubjects[index]["image"]}",
                                                              height: 60,
                                                              width: 60,
                                                            )
                                                            // Image.asset(
                                                            //   ImageAssets.book,
                                                            //   height: 70,
                                                            //   width: 70,
                                                            // )
                                                            : Icon(
                                                              Icons.science,
                                                              size: 30,
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
                                                        // const const SizedBox(
                                                        //   height: 10,
                                                        // ),
                                                        Text(
                                                          "${literarySubjects[index]["name"]}"
                                                              .tr,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                FontController()
                                                                    .currentFontFamily,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                ),
                                const SizedBox(height: 25),
                                Center(
                                  child: Text(
                                    "Recommended Books".tr,
                                    style: TextStyle(
                                      fontFamily:
                                          FontController().currentFontFamily,
                                      fontSize: 24,
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
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 180,
                                  child: GridView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 1,
                                        ),
                                    controller: scrollController,
                                    itemCount: recommendedBooks.length + 1,
                                    itemBuilder: (context, i) {
                                      if (i == recommendedBooks.length) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => Books(
                                                      books: recommendedBooks,
                                                      // BooksImages:
                                                      //     recommendedBooksImages,
                                                      title:
                                                          "Recommended Books",
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  child: Icon(
                                                    Icons
                                                        .arrow_circle_right_outlined,
                                                    size: 40,
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
                                                ),
                                                Text(
                                                  "More".tr,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        FontController()
                                                            .currentFontFamily,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal,
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
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      int uniId = recommendedBooks[i]["id"];
                                      // Uint8List? imageBytes =
                                      //     recommendedBooksImages[uniId];

                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => BookDetails(
                                                    BookData:
                                                        recommendedBooks[i],
                                                    // bookImage:
                                                    //     recommendedBooksImages[uniId],
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 1,
                                            right: 10,
                                          ),
                                          // padding: const EdgeInsets.only(left: 10,right: 10),
                                          padding: const EdgeInsets.all(10),
                                          height: 130,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            border: Border.all(
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
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              if (recommendedBooks[i]["rating"] !=
                                                  null)
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Container(
                                                    height: 23,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          // vertical: ,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      // color: Color(0XFF89EBB8),
                                                      // color: Color(0XFF76C49A),
                                                      // color: Color(0xFF94DDB3),
                                                      color: Color(0xFFCCF2E0),
                                                      border: Border.all(
                                                        color:
                                                            themeController
                                                                        .initialTheme ==
                                                                    Themes
                                                                        .customLightTheme
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color: Color(
                                                            0XFFE6D827,
                                                          ),
                                                          // color:Color(0XFFEA4468),
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          // "${recommendedBooks[i]["rating"]}",
                                                          double.parse(
                                                            recommendedBooks[i]["rating"]
                                                                .toString(),
                                                          ).toStringAsFixed(1),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                FontController()
                                                                    .currentFontFamily,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontSize: 16,
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  40,
                                                                  41,
                                                                  61,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(height: 24),
                                                    recommendedBooks[i]["image"] !=
                                                            null
                                                        ? CachedNetworkImage(
                                                          imageUrl:
                                                              "$mainIP/${recommendedBooks[i]["image"]}",
                                                          height: 60,
                                                          width: 60,
                                                        )
                                                        : Image.asset(
                                                          ImageAssets.subject,
                                                        ),

                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        "${recommendedBooks[i]["name"]}"
                                                            .tr,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              FontController()
                                                                  .currentFontFamily,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 30),
                                Center(
                                  child: Text(
                                    "Top Rated Books".tr,
                                    style: TextStyle(
                                      fontFamily:
                                          FontController().currentFontFamily,
                                      fontSize: 22,
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
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 180,
                                  child: GridView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 1,
                                        ),
                                    controller: scrollController,
                                    itemCount: topRatedBooks.length + 1,
                                    itemBuilder: (context, i) {
                                      if (i == topRatedBooks.length) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => Books(
                                                      books: topRatedBooks,
                                                      // BooksImages:
                                                      //     topRatedBooksImages,
                                                      title: "Top Rated Books",
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  child: Icon(
                                                    Icons
                                                        .arrow_circle_right_outlined,
                                                    size: 40,
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
                                                ),
                                                Text(
                                                  "More".tr,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        FontController()
                                                            .currentFontFamily,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal,
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
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      int uniId = topRatedBooks[i]["id"];
                                      // Uint8List? imageBytes =
                                      //     topRatedBooksImages[uniId];

                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => BookDetails(
                                                    BookData: topRatedBooks[i],
                                                    // bookImage:
                                                    //     topRatedBooksImages[uniId],
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 1,
                                            right: 10,
                                          ),
                                          // padding: const EdgeInsets.only(left: 10,right: 10),
                                          padding: const EdgeInsets.all(10),
                                          height: 130,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            border: Border.all(
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
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              if (topRatedBooks[i]["rating"] !=
                                                  null)
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Container(
                                                    height: 23,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          // vertical: ,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      // color: Color(0XFF89EBB8),
                                                      // color: Color(0XFF76C49A),
                                                      // color: Color(0xFF94DDB3),
                                                      color: Color(0xFFCCF2E0),
                                                      border: Border.all(
                                                        color:
                                                            themeController
                                                                        .initialTheme ==
                                                                    Themes
                                                                        .customLightTheme
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color: Color(
                                                            0XFFE6D827,
                                                          ),
                                                          // color:Color(0XFFEA4468),
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          double.parse(
                                                            topRatedBooks[i]["rating"]
                                                                .toString(),
                                                          ).toStringAsFixed(1),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                FontController()
                                                                    .currentFontFamily,
                                                            fontSize: 16,
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  40,
                                                                  41,
                                                                  61,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(height: 24),
                                                    topRatedBooks[i]["image"] !=
                                                            null
                                                        ? CachedNetworkImage(
                                                          imageUrl:
                                                              "$mainIP/${topRatedBooks[i]["image"]}",
                                                          height: 60,
                                                          width: 60,
                                                        )
                                                        : Image.asset(
                                                          ImageAssets.subject,
                                                        ),

                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        "${topRatedBooks[i]["name"]}"
                                                            .tr,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              FontController()
                                                                  .currentFontFamily,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 30),
                                Center(
                                  child: Text(
                                    "Most Recent Books".tr,
                                    style: TextStyle(
                                      fontFamily:
                                          FontController().currentFontFamily,
                                      fontSize: 22,
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
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 180,
                                  child: GridView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 1,
                                        ),
                                    controller: scrollController,
                                    itemCount: recentBooks.length + 1,
                                    itemBuilder: (context, i) {
                                      if (i == recentBooks.length) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => Books(
                                                      books: recentBooks,
                                                      // BooksImages:
                                                      //     recentBooksImages,
                                                      title: "Recent Books",
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Card(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  child: Icon(
                                                    Icons
                                                        .arrow_circle_right_outlined,
                                                    size: 40,
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
                                                ),
                                                Text(
                                                  "More".tr,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        FontController()
                                                            .currentFontFamily,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal,
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
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      int uniId = recentBooks[i]["id"];
                                      // Uint8List? imageBytes =
                                      //     recentBooksImages[uniId];

                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => BookDetails(
                                                    BookData: recentBooks[i],
                                                    // bookImage:
                                                    //     recentBooksImages[uniId],
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 1,
                                            right: 10,
                                          ),
                                          // padding: const EdgeInsets.only(left: 10,right: 10),
                                          padding: const EdgeInsets.all(10),
                                          height: 130,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            border: Border.all(
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
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              if (recentBooks[i]["rating"] !=
                                                  null)
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Container(
                                                    height: 23,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          // vertical: ,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      // color: Color(0XFF89EBB8),
                                                      // color: Color(0XFF76C49A),
                                                      // color: Color(0xFF94DDB3),
                                                      color: Color(0xFFCCF2E0),
                                                      border: Border.all(
                                                        color:
                                                            themeController
                                                                        .initialTheme ==
                                                                    Themes
                                                                        .customLightTheme
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color: Color(
                                                            0XFFE6D827,
                                                          ),
                                                          // color:Color(0XFFEA4468),
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          // "4.3",
                                                          double.parse(
                                                            recentBooks[i]["rating"]
                                                                .toString(),
                                                          ).toStringAsFixed(1),

                                                          style: TextStyle(
                                                            fontFamily:
                                                                FontController()
                                                                    .currentFontFamily,
                                                            fontSize: 16,
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  40,
                                                                  41,
                                                                  61,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(height: 24),
                                                    recentBooks[i]["image"] !=
                                                            null
                                                        ? CachedNetworkImage(
                                                          imageUrl:
                                                              "$mainIP/${recentBooks[i]["image"]}",
                                                          height: 60,
                                                          width: 60,
                                                        )
                                                        : Image.asset(
                                                          ImageAssets.subject,
                                                        ),

                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        "${recentBooks[i]["name"]}"
                                                            .tr,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              FontController()
                                                                  .currentFontFamily,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 30),
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
