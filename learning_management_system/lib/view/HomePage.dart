// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:learning_management_system/controller/WatchlistController.dart';
import 'package:learning_management_system/core/classes/PdfCard.dart';
import 'package:learning_management_system/core/classes/SubjectsBooks.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';
import '../core/classes/Courses.dart';
import '../controller/FontController.dart';
import '../services/CacheManager.dart';
import 'LogIn.dart';
import 'SubjectTeachers.dart';
import 'Favorites.dart';
import 'CoursesLessons.dart';
import '../services/SharedPrefs.dart';
import '../core/constants/ImageAssets.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import '../controller/NetworkController.dart';
import '../locale/LocaleController.dart';
import '../controller/FavoriteController.dart';
import 'NavBar.dart';
import '../core/function/DynamicSearch.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController scrollController = ScrollController();
  late SharedPrefs sharedPrefs;

  final ThemeController themeController = Get.find<ThemeController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final LocaleController localeController = Get.find<LocaleController>();
  // final ProfileController profileController = Get.put(ProfileController());

  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> recommendedCourses = [];
  List<Map<String, dynamic>> TopRatedCourses = [];
  bool isFavorite = false;
  bool isLiterary = false;
  String subjectType = 'scientific';
  int numberOfListItems = 0;

  List<bool> isSelected = [true, false];

  List<Map<String, dynamic>> scientificSubjects = [];
  List<Map<String, dynamic>> literarySubjects = [];
  List<Map<String, dynamic>> cachedRecommendedCourses = [];
  List<Map<String, dynamic>> cachedTopRatedCourses = [];

  List<Map<String, dynamic>> recentCourses = [];
  List<Map<String, dynamic>> cachedRecentCourses = [];

  List<Map<String, dynamic>> subscribedCourses = [];
  List<Map<String, dynamic>> cachedSubscribedCourses = [];
  late FavoriteController favoriteController;
  late WatchlistController watchlistController;
  final CacheManager cacheManager = CacheManager();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _initSharedPreferences().then((_) => _loadInitialData());
    favoriteController = Get.put(FavoriteController());
    watchlistController = Get.put(WatchlistController());
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getSubjectsData(subjectType);
      await getCoursesData();
    } else {
      if (cacheManager.isCacheEnabled.value == true) {
        await _loadCachedData();
      }
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

  Future<void> getSubjectsData(String subjectType) async {
    // 1. Token Handling
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
      // 2. Configurable API URL
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/subjects/$subjectType';

      // 3. API Request
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

      debugPrint("Subjects API response: ${response.statusCode}");

      // 4. Response Handling
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Handle both array and object responses
        final List<dynamic> subjectsList =
            responseBody is List
                ? responseBody
                : (responseBody['subjects'] ?? [responseBody]);

        // 5. Update state and cache
        if (mounted) {
          setState(() {
            subjects = List<Map<String, dynamic>>.from(subjectsList);
          });
          if (cacheManager.isCacheEnabled.value == true) {
            await _cacheSubjectsData();
          }
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        // If API fails, use cached data for the current subject type
        if (subjects.isEmpty) {
          setState(() {
            subjects =
                subjectType == 'scientific'
                    ? scientificSubjects
                    : literarySubjects;
          });
          if (subjects.isEmpty) {
            throw Exception("Failed to load subjects: ${response.statusCode}");
          }
        }
      }
    } on TimeoutException {
      // If we have cached data, use it
      if (subjects.isEmpty) {
        setState(() {
          subjects =
              subjectType == 'scientific'
                  ? scientificSubjects
                  : literarySubjects;
        });
        if (subjects.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      // If we have cached data, use it
      if (subjects.isEmpty) {
        setState(() {
          subjects =
              subjectType == 'scientific'
                  ? scientificSubjects
                  : literarySubjects;
        });
        if (subjects.isEmpty) {
          showErrorSnackbar("Failed to load subjects");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching subjects: $e");
    }
  }

  Future<void> getCoursesData() async {
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
      final APIurl = '$baseUrl/api/getallhomepage';

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
        final List<dynamic> recommendedCoursesList =
            responseBody is List
                ? responseBody
                : (responseBody['recommended'] ?? [responseBody]);

        final List<dynamic> TopRatedCoursesList =
            responseBody is List
                ? responseBody
                : (responseBody['top_rated'] ?? [responseBody]);

        final List<dynamic> recentCoursesList =
            responseBody is List
                ? responseBody
                : (responseBody['recent'] ?? [responseBody]);

        final List<dynamic> subscribedCoursesList =
            responseBody is List
                ? responseBody
                : (responseBody['most_subscribed'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            recommendedCourses = List<Map<String, dynamic>>.from(
              recommendedCoursesList,
            );
            TopRatedCourses = List<Map<String, dynamic>>.from(
              TopRatedCoursesList,
            );
            recentCourses = List<Map<String, dynamic>>.from(recentCoursesList);
            subscribedCourses = List<Map<String, dynamic>>.from(
              subscribedCoursesList,
            );
          });
          if (cacheManager.isCacheEnabled.value == true) {
            await _cacheRecommendedCourses();
            await _cacheTopRatedCourses();
            await _cacheRecentCourses();
            await _cacheSubscribedCourses();
          }
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (recommendedCourses.isEmpty ||
            TopRatedCourses.isEmpty ||
            recentCourses.isEmpty ||
            subscribedCourses.isEmpty) {
          setState(() {
            recommendedCourses = List.from(cachedRecommendedCourses);
            TopRatedCourses = List.from(cachedTopRatedCourses);
            recentCourses = List.from(cachedRecentCourses);
            subscribedCourses = List.from(cachedSubscribedCourses);
          });
          if (recommendedCourses.isEmpty ||
              TopRatedCourses.isEmpty ||
              recentCourses.isEmpty ||
              subscribedCourses.isEmpty) {
            throw Exception(
              "Failed to load recommended courses: ${response.statusCode}",
            );
          }
        }
      }
    } on TimeoutException {
      if (recommendedCourses.isEmpty ||
          TopRatedCourses.isEmpty ||
          recentCourses.isEmpty ||
          subscribedCourses.isEmpty) {
        setState(() {
          recommendedCourses = List.from(cachedRecommendedCourses);
          TopRatedCourses = List.from(cachedTopRatedCourses);
          recentCourses = List.from(cachedRecentCourses);
          subscribedCourses = List.from(cachedSubscribedCourses);
        });
        if (recommendedCourses.isEmpty ||
            TopRatedCourses.isEmpty ||
            recentCourses.isEmpty ||
            subscribedCourses.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (recommendedCourses.isEmpty ||
          TopRatedCourses.isEmpty ||
          recentCourses.isEmpty ||
          subscribedCourses.isEmpty) {
        setState(() {
          recommendedCourses = List.from(cachedRecommendedCourses);
          TopRatedCourses = List.from(cachedTopRatedCourses);
          recentCourses = List.from(cachedRecentCourses);
          subscribedCourses = List.from(cachedSubscribedCourses);
        });
        if (recommendedCourses.isEmpty ||
            TopRatedCourses.isEmpty ||
            recentCourses.isEmpty ||
            subscribedCourses.isEmpty) {
          showErrorSnackbar("Failed to load recommended courses");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching recommended courses: $e");
    }
  }

  Future<void> _cacheSubjectsData() async {
    try {
      if (subjectType == 'scientific') {
        await sharedPrefs.prefs.setString(
          'cached_scientific_subjects',
          jsonEncode(subjects),
        );
        scientificSubjects = List.from(subjects);
      } else {
        await sharedPrefs.prefs.setString(
          'cached_literary_subjects',
          jsonEncode(subjects),
        );
        literarySubjects = List.from(subjects);
      }
    } catch (e) {
      debugPrint("Error caching subjects data: $e");
    }
  }

  Future<void> _cacheRecommendedCourses() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_recommended_courses',
        jsonEncode(recommendedCourses),
      );
      cachedRecommendedCourses = List.from(recommendedCourses);
    } catch (e) {
      debugPrint("Error caching recommended courses: $e");
    }
  }

  Future<void> _cacheTopRatedCourses() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_top_rated_courses',
        jsonEncode(TopRatedCourses),
      );
      cachedTopRatedCourses = List.from(TopRatedCourses);
    } catch (e) {
      debugPrint("Error caching top-rated courses: $e");
    }
  }

  Future<void> _cacheRecentCourses() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_recent_courses',
        jsonEncode(recentCourses),
      );
      cachedRecentCourses = List.from(recentCourses);
    } catch (e) {
      debugPrint("Error caching recent courses: $e");
    }
  }

  Future<void> _cacheSubscribedCourses() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_subscribed_courses',
        jsonEncode(subscribedCourses),
      );
      cachedSubscribedCourses = List.from(subscribedCourses);
    } catch (e) {
      debugPrint("Error caching subscribed courses: $e");
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load scientific subjects data
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

      // Load literary subjects data
      final cachedLiterarySubjects = sharedPrefs.prefs.getString(
        'cached_literary_subjects',
      );
      if (cachedLiterarySubjects != null) {
        final List<dynamic> parsedLiteraryList = jsonDecode(
          cachedLiterarySubjects,
        );
        literarySubjects = List<Map<String, dynamic>>.from(parsedLiteraryList);
      }

      // Load recommended subjects data
      final cachedRecommended = sharedPrefs.prefs.getString(
        'cached_recommended_courses',
      );
      if (cachedRecommended != null) {
        final List<dynamic> parsedRecommendedList = jsonDecode(
          cachedRecommended,
        );
        cachedRecommendedCourses = List<Map<String, dynamic>>.from(
          parsedRecommendedList,
        );
        recommendedCourses = List.from(cachedRecommendedCourses);
      }

      // Load top-rated subjects data
      final cachedTopRated = sharedPrefs.prefs.getString(
        'cached_top_rated_courses',
      );
      if (cachedTopRated != null) {
        final List<dynamic> parsedTopRatedList = jsonDecode(cachedTopRated);
        cachedTopRatedCourses = List<Map<String, dynamic>>.from(
          parsedTopRatedList,
        );
        TopRatedCourses = List.from(cachedTopRatedCourses);
      }

      final cachedRecent = sharedPrefs.prefs.getString('cached_recent_courses');
      if (cachedRecent != null) {
        final List<dynamic> parsedRecentList = jsonDecode(cachedRecent);
        cachedRecentCourses = List<Map<String, dynamic>>.from(parsedRecentList);
        recentCourses = List.from(cachedRecentCourses);
      }

      final cachedSubscribed = sharedPrefs.prefs.getString(
        'cached_subscribed_courses',
      );
      if (cachedSubscribed != null) {
        final List<dynamic> parsedSubscribedList = jsonDecode(cachedSubscribed);
        cachedSubscribedCourses = List<Map<String, dynamic>>.from(
          parsedSubscribedList,
        );
        subscribedCourses = List.from(cachedSubscribedCourses);
      }

      // Load recent courses data
      // await _loadCachedRecentCourses();
      // Load subscribed courses data
      // await _loadCachedSubscribedCourses();

      // Set initial subjects based on current subjectType
      setState(() {
        subjects =
            subjectType == 'scientific' ? scientificSubjects : literarySubjects;
      });

      // Load images for all subject types
      // await Future.wait([
      //   _loadImagesForSubjects(scientificSubjects),
      //   _loadImagesForSubjects(literarySubjects),
      //   _loadRecommendedCoursesImages(),
      //   _loadTopRatedCoursesImages(),
      //   _loadRecentCoursesImages(),
      //   _loadSubscribedCoursesImages(),
      // ]);
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              : subjects.isEmpty
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
                  await getSubjectsData(subjectType);
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
                        height: 80,
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
                                    right: Get.width / 40,
                                  ),
                                  child: Text(
                                    "Home Page".tr,
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
                                      elements: subjects,
                                      // elementsImages: subjectsImages,
                                      searchType: 'subjects',
                                      onItemTap: (subject) {
                                        if (isSelected[0]) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => SubjectTeachers(
                                                    SubjectData: subject,
                                                  ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => SubjectsBooks(
                                                    subjectId: subject['id'],
                                                    subjectName:
                                                        subject['name'],
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.search_outlined,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 210, 209, 224)
                                          : Color.fromARGB(255, 40, 41, 61),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
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
                            scrollDirection: Axis.vertical,
                            physics: AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 30),
                              Center(
                                child: ToggleButtons(
                                  isSelected: isSelected,
                                  direction: Axis.horizontal,
                                  constraints: BoxConstraints(
                                    minWidth: Get.width / 3,
                                    maxWidth: Get.width / 3,
                                  ),
                                  borderWidth: 3,
                                  borderRadius: BorderRadius.circular(25),
                                  borderColor:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  selectedBorderColor:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  fillColor:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  selectedColor:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  onPressed: (int newIndex) {
                                    setState(() {
                                      for (
                                        int index = 0;
                                        index < isSelected.length;
                                        index++
                                      ) {
                                        isSelected[index] = index == newIndex;
                                      }
                                      isLiterary = newIndex == 1;
                                      subjectType =
                                          isLiterary
                                              ? 'literary'
                                              : 'scientific';
                                      subjects =
                                          subjectType == 'scientific'
                                              ? scientificSubjects
                                              : literarySubjects;
                                    });
                                    if (sharedPrefs.prefs.getBool(
                                          'isConnected',
                                        ) ==
                                        true) {
                                      getSubjectsData(subjectType);
                                    }
                                  },
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          isSelected[0] = true;
                                          isSelected[1] = false;
                                          isLiterary = false;
                                          subjectType = "scientific";
                                          subjects = scientificSubjects;
                                        });
                                        if (sharedPrefs.prefs.getBool(
                                              'isConnected',
                                            ) ==
                                            true) {
                                          getSubjectsData(subjectType);
                                        }
                                      },
                                      child: Text(
                                        "Scientific".tr,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              FontController()
                                                  .currentFontFamily,
                                          fontSize: 18,
                                          color:
                                              themeController.initialTheme ==
                                                      Themes.customLightTheme
                                                  ? isSelected[0]
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
                                                      )
                                                  : isSelected[0]
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
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          isSelected[1] = true;
                                          isSelected[0] = false;
                                          isLiterary = true;
                                          subjectType = "literary";
                                          subjects = literarySubjects;
                                        });
                                        if (sharedPrefs.prefs.getBool(
                                              'isConnected',
                                            ) ==
                                            true) {
                                          getSubjectsData(subjectType);
                                        }
                                      },
                                      child: Text(
                                        "Literary".tr,
                                        style: TextStyle(
                                          fontFamily:
                                              FontController()
                                                  .currentFontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                          color:
                                              themeController.initialTheme ==
                                                      Themes.customLightTheme
                                                  ? isSelected[0]
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
                                                      )
                                                  : isSelected[0]
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Center(
                                child: Text(
                                  "Subjects".tr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        FontController().currentFontFamily,
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
                                child: GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                      ),
                                  controller: scrollController,
                                  itemCount: subjects.length,
                                  itemBuilder: (context, i) {
                                    int uniId = subjects[i]["id"];
                                    // Uint8List? imageBytes =
                                    //     subjectsImages[uniId];

                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => SubjectTeachers(
                                                  SubjectData: subjects[i],
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          right: 11,
                                          left: 1,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          // color: Colors.red,
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
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child:
                                                  subjects[i]["image"] != null
                                                      ? CachedNetworkImage(
                                                        imageUrl:
                                                            "$mainIP/${subjects[i]["image"]}",
                                                      )
                                                      // ? Image.network(
                                                      //   subjects[i]["image"],
                                                      // )
                                                      : Image.asset(
                                                        ImageAssets.book,
                                                      ),
                                            ),
                                            const SizedBox(height: 10),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                "${subjects[i]["name"]}".tr,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                      FontController()
                                                          .currentFontFamily,
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
                                  "Recommended Courses".tr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        FontController().currentFontFamily,
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
                                  itemCount: recommendedCourses.length + 1,
                                  itemBuilder: (context, i) {
                                    if (i == recommendedCourses.length) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => Courses(
                                                    courses: recommendedCourses,

                                                    title:
                                                        "Recommended Courses",
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

                                    int uniId = recommendedCourses[i]["id"];
                                    // Uint8List? imageBytes =
                                    //     recommendedCoursesImages[uniId];

                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => CoursesLessons(
                                                  CoursesData:
                                                      recommendedCourses[i],
                                                  index: i,
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
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 5,
                                              left: 5,
                                              right: 5,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  recommendedCourses[i]["rating"] !=
                                                          null
                                                      ? Container(
                                                        height: 23,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Color(
                                                            0xFFCCF2E0,
                                                          ),
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
                                                              size: 20,
                                                            ),
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              // "${recommendedCourses[i]["rating"]}",
                                                              double.parse(
                                                                recommendedCourses[i]["rating"]
                                                                    .toString(),
                                                              ).toStringAsFixed(
                                                                1,
                                                              ),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    FontController()
                                                                        .currentFontFamily,
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
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
                                                      )
                                                      : const SizedBox.shrink(),

                                                  // Like button on the right
                                                  GetBuilder<
                                                    FavoriteController
                                                  >(
                                                    builder: (controller) {
                                                      final isFav =
                                                          controller
                                                              .isFavoriteC[recommendedCourses[i]["id"]
                                                              .toString()] ??
                                                          false;

                                                      return LikeButton(
                                                        size: 30,
                                                        isLiked: isFav,
                                                        likeBuilder: (
                                                          bool isLiked,
                                                        ) {
                                                          return Icon(
                                                            isLiked
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border_outlined,
                                                            color: Colors.red,
                                                            size: 30,
                                                          );
                                                        },
                                                        onTap: (
                                                          bool isLiked,
                                                        ) async {
                                                          controller
                                                              .toggleFavoriteC(
                                                                recommendedCourses[i]["id"]
                                                                    .toString(),
                                                              );
                                                          return !isLiked;
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(height: 36),
                                                  recommendedCourses[i]["image"] !=
                                                          null
                                                      ? CachedNetworkImage(
                                                        imageUrl:
                                                            "$mainIP/${recommendedCourses[i]["image"]}",
                                                        height: 90,
                                                        width: 90,
                                                      )
                                                      // ? Image.network(
                                                      //   recommendedCourses[i]["image"],
                                                      //   height: 90,
                                                      //   width: 90,
                                                      // )
                                                      : Image.asset(
                                                        ImageAssets.subject,
                                                      ),

                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "${recommendedCourses[i]["name"]}"
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
                                  "Top Rated Courses".tr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    fontFamily:
                                        FontController().currentFontFamily,
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
                                  itemCount: TopRatedCourses.length + 1,
                                  itemBuilder: (context, i) {
                                    if (i == TopRatedCourses.length) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => Courses(
                                                    courses: TopRatedCourses,
                                                    title: "Top Courses",
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

                                    int uniId = TopRatedCourses[i]["id"];
                                    // Uint8List? imageBytes =
                                    //     TopRatedCoursesImages[uniId];

                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => CoursesLessons(
                                                  CoursesData:
                                                      recommendedCourses[i],
                                                  index: i,
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
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 5,
                                              left: 5,
                                              right: 5,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  TopRatedCourses[i]["rating"] !=
                                                          null
                                                      ? Container(
                                                        height: 23,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Color(
                                                            0xFFCCF2E0,
                                                          ),
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
                                                              size: 20,
                                                            ),
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              // "${recommendedCourses[i]["rating"]}",
                                                              double.parse(
                                                                TopRatedCourses[i]["rating"]
                                                                    .toString(),
                                                              ).toStringAsFixed(
                                                                1,
                                                              ),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    FontController()
                                                                        .currentFontFamily,
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
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
                                                      )
                                                      : const SizedBox.shrink(),
                                                  const SizedBox.shrink(),

                                                  GetBuilder<
                                                    FavoriteController
                                                  >(
                                                    builder: (controller) {
                                                      final isFav =
                                                          controller
                                                              .isFavoriteC[TopRatedCourses[i]["id"]
                                                              .toString()] ??
                                                          false;

                                                      return LikeButton(
                                                        size: 30,
                                                        isLiked: isFav,
                                                        likeBuilder: (
                                                          bool isLiked,
                                                        ) {
                                                          return Icon(
                                                            isLiked
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border_outlined,
                                                            color: Colors.red,
                                                            size: 30,
                                                          );
                                                        },
                                                        onTap: (
                                                          bool isLiked,
                                                        ) async {
                                                          controller
                                                              .toggleFavoriteC(
                                                                TopRatedCourses[i]["id"]
                                                                    .toString(),
                                                              );
                                                          return !isLiked;
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(height: 35),
                                                  TopRatedCourses[i]["image"] !=
                                                          null
                                                      ? CachedNetworkImage(
                                                        imageUrl:
                                                            "$mainIP/${TopRatedCourses[i]["image"]}",
                                                        height: 90,
                                                        width: 90,
                                                      )
                                                      // ? Image.network(
                                                      //   TopRatedCourses[i]["image"],
                                                      //   height: 90,
                                                      //   width: 90,
                                                      // )
                                                      : Image.asset(
                                                        ImageAssets.subject,
                                                      ),

                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "${TopRatedCourses[i]["name"]}"
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
                                  "Most Recent Courses".tr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        FontController().currentFontFamily,
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
                                  itemCount: recentCourses.length + 1,
                                  itemBuilder: (context, i) {
                                    if (i == recentCourses.length) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => Courses(
                                                    courses: recentCourses,
                                                    title: "recent Courses",
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

                                    int uniId = recentCourses[i]["id"];
                                    // Uint8List? imageBytes =
                                    //     recentCoursesImages[uniId];

                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => CoursesLessons(
                                                  CoursesData: recentCourses[i],
                                                  index: i,
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
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 5,
                                              left: 5,
                                              right: 5,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  recentCourses[i]["rating"] !=
                                                          null
                                                      ? Container(
                                                        height: 23,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Color(
                                                            0xFFCCF2E0,
                                                          ),
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
                                                              size: 20,
                                                            ),
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              // "${recentCourses[i]["rating"]}",
                                                              double.parse(
                                                                recentCourses[i]["rating"]
                                                                    .toString(),
                                                              ).toStringAsFixed(
                                                                1,
                                                              ),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    FontController()
                                                                        .currentFontFamily,
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
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
                                                      )
                                                      : const SizedBox.shrink(),
                                                  const SizedBox.shrink(),

                                                  GetBuilder<
                                                    FavoriteController
                                                  >(
                                                    builder: (controller) {
                                                      final isFav =
                                                          controller
                                                              .isFavoriteC[recentCourses[i]["id"]
                                                              .toString()] ??
                                                          false;

                                                      return LikeButton(
                                                        size: 30,
                                                        isLiked: isFav,
                                                        likeBuilder: (
                                                          bool isLiked,
                                                        ) {
                                                          return Icon(
                                                            isLiked
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border_outlined,
                                                            color: Colors.red,
                                                            size: 30,
                                                          );
                                                        },
                                                        onTap: (
                                                          bool isLiked,
                                                        ) async {
                                                          controller
                                                              .toggleFavoriteC(
                                                                recentCourses[i]["id"]
                                                                    .toString(),
                                                              );
                                                          return !isLiked;
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(height: 34),
                                                  recentCourses[i]["image"] !=
                                                          null
                                                      ? CachedNetworkImage(
                                                        imageUrl:
                                                            "$mainIP/${recentCourses[i]["image"]}",
                                                        height: 90,
                                                        width: 90,
                                                        // fit: BoxFit.contain,
                                                      )
                                                      // ? Image.network(
                                                      //   recentCourses[i]["image"],
                                                      //   height: 90,
                                                      //   width: 90,
                                                      // )
                                                      : Image.asset(
                                                        ImageAssets.subject,
                                                      ),

                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "${recentCourses[i]["name"]}"
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
                                  "Most Subscribed Courses".tr,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        FontController().currentFontFamily,
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
                                  itemCount: subscribedCourses.length + 1,
                                  itemBuilder: (context, i) {
                                    if (i == subscribedCourses.length) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => Courses(
                                                    courses: subscribedCourses,
                                                    title:
                                                        "Most Subscribed Courses",
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

                                    int uniId = subscribedCourses[i]["id"];
                                    // Uint8List? imageBytes =
                                    //     subscribedCoursesImages[uniId];

                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => CoursesLessons(
                                                  CoursesData:
                                                      subscribedCourses[i],
                                                  index: i,
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
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 5,
                                              left: 5,
                                              right: 5,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  subscribedCourses[i]["rating"] !=
                                                          null
                                                      ? Container(
                                                        height: 23,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Color(
                                                            0xFFCCF2E0,
                                                          ),
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
                                                              size: 20,
                                                            ),
                                                            const SizedBox(
                                                              width: 2,
                                                            ),
                                                            Text(
                                                              // "${subscribedCourses[i]["rating"]}",
                                                              double.parse(
                                                                subscribedCourses[i]["rating"]
                                                                    .toString(),
                                                              ).toStringAsFixed(
                                                                1,
                                                              ),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    FontController()
                                                                        .currentFontFamily,
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
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
                                                      )
                                                      : const SizedBox.shrink(),
                                                  const SizedBox.shrink(),

                                                  GetBuilder<
                                                    FavoriteController
                                                  >(
                                                    builder: (controller) {
                                                      final isFav =
                                                          controller
                                                              .isFavoriteC[subscribedCourses[i]["id"]
                                                              .toString()] ??
                                                          false;

                                                      return LikeButton(
                                                        size: 30,
                                                        isLiked: isFav,
                                                        likeBuilder: (
                                                          bool isLiked,
                                                        ) {
                                                          return Icon(
                                                            isLiked
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border_outlined,
                                                            color: Colors.red,
                                                            size: 30,
                                                          );
                                                        },
                                                        onTap: (
                                                          bool isLiked,
                                                        ) async {
                                                          controller
                                                              .toggleFavoriteC(
                                                                subscribedCourses[i]["id"]
                                                                    .toString(),
                                                              );
                                                          return !isLiked;
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(height: 34),
                                                  subscribedCourses[i]['image'] !=
                                                          null
                                                      ? CachedNetworkImage(
                                                        imageUrl:
                                                            "$mainIP/${subscribedCourses[i]["image"]}",
                                                        height: 90,
                                                        width: 90,
                                                      )
                                                      // ? Image.network(
                                                      //   subscribedCourses[i]['image'],
                                                      //   height: 90,
                                                      //   width: 90,
                                                      // )
                                                      : Image.asset(
                                                        ImageAssets.subject,
                                                      ),

                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "${subscribedCourses[i]["name"]}"
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
                              Container(
                                padding: EdgeInsets.only(
                                  left: 110,
                                  right: 110,
                                  top: 30,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => PdfLibraryScreen(),
                                      ),
                                    );
                                  },
                                  child: Card(
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        "Previous Exams".tr,
                                        style: TextStyle(
                                          fontFamily:
                                              FontController()
                                                  .currentFontFamily,
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
                                      ),
                                    ),
                                  ),
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
      // ),
    );
  }
}
