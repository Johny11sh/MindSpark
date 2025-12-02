// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../services/CacheManager.dart';
import '../../view/LogIn.dart';
import '../function/noDataLottie.dart';
import 'BookDetails.dart';
import '../../services/SharedPrefs.dart';
import '../../core/constants/ImageAssets.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../controller/NetworkController.dart';
import '../../locale/LocaleController.dart';
import '../../view/NavBar.dart';
import '../function/DynamicSearch.dart';
import '../constants/FontGlobals.dart';

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
  // final Map<int, Uint8List> subjectBooksImages = {};
  List<Map<String, dynamic>> cachedSubjectBooks = [];
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
      networkController.init();
      print('caching: ${cacheManager.isCacheEnabled.value}');
      print('connection: ${sharedPrefs.prefs.getBool('isConnected')}');
      (cacheManager.isCacheEnabled.value == false &&
              sharedPrefs.prefs.getBool('isConnected') == false)
          ? print('caching is disabled')
          : _loadInitialData();
    });
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    // await _loadCachedData();

    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getSubjectBooksData();
    } else {
      if (cacheManager.isCacheEnabled.value == true) {
        await _loadCachedData();
      }
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
          debugPrint(
            "Loaded ${subjectBooks.length} cached books for subject ${widget.subjectId}",
          );
        } catch (e) {
          debugPrint("Error parsing cached books data: $e");
          // Clear corrupted cache
          await sharedPrefs.prefs.remove(
            'cached_subject_books_${widget.subjectId}',
          );
        }
      } else {
        debugPrint("No cached books found for subject ${widget.subjectId}");
      }

      // Load images for subject books
      // await _loadSubjectBooksImages();
    } catch (e) {
      debugPrint("Error loading cached data: $e");
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
        debugPrint(
          "Cached ${subjectBooks.length} books for subject ${widget.subjectId}",
        );
      }
    } catch (e) {
      debugPrint("Error caching subject books: $e");
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
            subjectBooks = List<Map<String, dynamic>>.from(subjectBooksList);
          });
          if (cacheManager.isCacheEnabled.value == true) {
            await _cacheSubjectBooks();
          }
        }
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
            showErrorSnackbar(
              "Failed to load subject books: ${response.statusCode}",
            );
          } else {
            showErrorSnackbar(
              "Using cached data - API returned ${response.statusCode}",
            );
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body:
            (cacheManager.isCacheEnabled.value == false &&
                    sharedPrefs.prefs.getBool('isConnected') == false)
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        ImageAssets.noDataLottie,
                        width: 300,
                        height: 300,
                      ),
                      MaterialButton(
                        onPressed: () async {
                          setState(() {
                            cacheManager.init();
                            networkController.init();
                          });
                          await networkController.checkConnectivityManually();

                          print(
                            'caching: ${cacheManager.isCacheEnabled.value}',
                          );
                          print(
                            'connection: ${sharedPrefs.prefs.getBool('isConnected')}',
                          );
                          setState(() {});
                          if (sharedPrefs.prefs.getBool('isConnected') ==
                              true) {
                            await _loadInitialData();
                          } else {
                            if (cacheManager.isCacheEnabled.value == true) {
                              await _loadCachedData();
                              setState(() {});
                            }
                          }
                        },
                        child: Icon(
                          Icons.refresh_outlined,
                          size: 35,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                        ),
                      ),
                    ],
                  ),
                )
                : subjectBooks.isEmpty
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
                    await getSubjectBooksData();
                  },
                  child: Container(
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 40, 41, 61)
                            : Color.fromARGB(255, 210, 209, 224),
                    child: Column(
                      children: [
                        // Header section
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
                                          "${widget.subjectName} Books".tr,
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
                                            elements: subjectBooks,
                                            // elementsImages: subjectBooksImages,
                                            searchType: 'books',
                                            subjectName: widget.subjectName,
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

                        // Main content section with rounded container
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
                            child:
                                (subjectBooks.isEmpty)
                                    ? noDataLottie("No data available")
                                    : Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Text(
                                          "Choose a book".tr,
                                          style: TextStyle(
                                            fontFamily: globalFontFamily,
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        22
                                                    : 22 -
                                                        (globalFontSizeChange /
                                                            5),
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal,
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
                                        ),
                                        const SizedBox(height: 20),
                                        Expanded(
                                          child: GridView.builder(
                                            scrollDirection: Axis.vertical,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                ),
                                            controller: scrollController,
                                            itemCount: subjectBooks.length,
                                            itemBuilder: (context, i) {
                                              try {
                                                final book = subjectBooks[i];
                                                final bookName =
                                                    book["name"]?.toString() ??
                                                    "Unknown Book";

                                                return InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                BookDetails(
                                                                  BookData:
                                                                      book,
                                                                ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          left: 1,
                                                          right: 1,
                                                          top: 2,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    height: 120,
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        // Book Image
                                                        SizedBox(
                                                          height: 60,
                                                          width: 60,
                                                          child:
                                                              book['image'] !=
                                                                      null
                                                                  ? CachedNetworkImage(
                                                                    imageUrl:
                                                                        "$mainIP/${book["image"]}",
                                                                    height: 60,
                                                                    width: 60,
                                                                  )
                                                                  : Image.asset(
                                                                    ImageAssets
                                                                        .book,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                  ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),

                                                        // Book Name
                                                        Text(
                                                          bookName.tr,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                globalFontFamily,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            fontSize:
                                                                globalFontSizeChange <=
                                                                        17
                                                                    ? (globalFontSizeChange /
                                                                            5) +
                                                                        14
                                                                    : 14 -
                                                                        (globalFontSizeChange /
                                                                            5),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FontStyle
                                                                    .normal,
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
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),

                                                        const SizedBox(
                                                          height: 4,
                                                        ),

                                                        // Subject Name with Icon
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons.book,
                                                              size: 12,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                widget
                                                                    .subjectName,
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      globalFontFamily,
                                                                  fontSize:
                                                                      globalFontSizeChange >=
                                                                              17
                                                                          ? (globalFontSizeChange /
                                                                                  5) +
                                                                              10
                                                                          : 10 -
                                                                              (globalFontSizeChange /
                                                                                  5),
                                                                  color:
                                                                      Colors
                                                                          .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              } catch (e) {
                                                debugPrint(
                                                  "Error rendering book at index $i: $e",
                                                );
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                    left: 1,
                                                    right: 1,
                                                    top: 2,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  height: 120,
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Error".tr,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            globalFontFamily,
                                                        fontSize:
                                                            globalFontSizeChange <=
                                                                    17
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
      ),
    );
  }
}
