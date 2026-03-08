// ignore_for_file: avoid_print, non_constant_identifier_names, file_names, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';

import '../controller/FavoriteController.dart';
import '../core/constants/FontGlobals.dart';
import '../core/function/noDataLottie.dart';
import '../services/CacheManager.dart';
import '../view/LogIn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../controller/NetworkController.dart';
import '../core/constants/ImageAssets.dart';
import '../locale/LocaleController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'Favorites.dart';
import 'NavBar.dart';
import 'CoursesLessons.dart';
import '../services/SharedPrefs.dart';
// import 'OnBoarding.dart';
import '../core/function/DynamicSearch.dart';

class TeachersCourses extends StatefulWidget {
  final Map<String, dynamic> TeacherData;

  const TeachersCourses({super.key, required this.TeacherData});

  @override
  State<TeachersCourses> createState() => _TeachersCoursesState();
}

class _TeachersCoursesState extends State<TeachersCourses> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final NetworkController networkController = Get.find<NetworkController>();
  ScrollController scrollController = ScrollController();
  late SharedPrefs sharedPrefs;
  late FavoriteController favoriteController;

  List<Map<String, dynamic>> teacherData = [];
  // final Map<int, Uint8List> coursesImages = {};
  bool isFavorite = false;

  // --- Most Recent Courses ---
  List<Map<String, dynamic>> recentCoursesData = [];
  // final Map<int, Uint8List> recentCoursesImages = {};

  List<Map<String, dynamic>> topRatedCoursesData = [];

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
    favoriteController = Get.put(FavoriteController());
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    // Try to load from cache first
    // await _loadCachedCourses();

    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getCoursesData();
    } else {
      if (cacheManager.isCacheEnabled.value == true) {
        await _loadCachedCourses();
      }
    }
  }

  Future<void> _loadCachedCourses() async {
    try {
      final cacheKey = 'cached_courses_${widget.TeacherData['id']}';
      final cachedData = sharedPrefs.prefs.getString(cacheKey);

      if (cachedData != null) {
        final List<dynamic> parsedList = jsonDecode(cachedData);
        setState(() {
          teacherData = List<Map<String, dynamic>>.from(parsedList);
        });

        final cacheKey2 =
            'cached_top_rated_courses_${widget.TeacherData['id']}';
        final cachedData2 = sharedPrefs.prefs.getString(cacheKey2);
        if (cachedData2 != null) {
          final List<dynamic> parsedList = jsonDecode(cachedData2);
          setState(() {
            topRatedCoursesData = List<Map<String, dynamic>>.from(parsedList);
          });
        }

        final cacheKey3 = 'cached_recent_courses_${widget.TeacherData['id']}';
        final cachedData3 = sharedPrefs.prefs.getString(cacheKey3);
        if (cachedData3 != null) {
          final List<dynamic> parsedList = jsonDecode(cachedData3);
          setState(() {
            recentCoursesData = List<Map<String, dynamic>>.from(parsedList);
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading cached courses: $e");
    }
  }

  Future<void> getCoursesData() async {
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
      final APIurl =
          '$baseUrl/api/getteachercourses/${widget.TeacherData['id']}';

      // 3. API Request with timeout
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

      debugPrint("courses API response: ${response.statusCode}");

      // 4. Response Handling
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Handle both array and object responses
        final List<dynamic> coursesList =
            responseBody is List
                ? responseBody
                : (responseBody['courses'] ?? [responseBody]);

        final List<dynamic> recentCoursesList =
            responseBody is List
                ? responseBody
                : (responseBody['recent'] ?? [responseBody]);

        final List<dynamic> topRatedCoursesList =
            responseBody is List
                ? responseBody
                : (responseBody['top_rated'] ?? [responseBody]);

        // 5. State Management and caching
        if (mounted) {
          setState(() {
            teacherData = List<Map<String, dynamic>>.from(coursesList);
            recentCoursesData = List<Map<String, dynamic>>.from(
              recentCoursesList,
            );
            topRatedCoursesData = List<Map<String, dynamic>>.from(
              topRatedCoursesList,
            );
          });
          if (cacheManager.isCacheEnabled.value == true) {
            await _cacheCourses();
            await _cacheRecentCourses();
            await _cacheTopRatedCourses();
          }
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        // If API fails but we have cached data, don't throw error
        if (teacherData.isEmpty ||
            recentCoursesData.isEmpty ||
            topRatedCoursesData.isEmpty) {
          throw Exception("Failed to load courses: ${response.statusCode}");
        }
      }
    } on TimeoutException {
      // If we have cached data, just show a warning
      if (teacherData.isEmpty ||
          recentCoursesData.isEmpty ||
          topRatedCoursesData.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      // If we have cached data, just show a warning
      if (teacherData.isEmpty ||
          recentCoursesData.isEmpty ||
          topRatedCoursesData.isEmpty) {
        showErrorSnackbar("Failed to load courses");
      } else {
        showErrorSnackbar("Using cached data - ${e.toString()}");
      }
      debugPrint("Error fetching courses: $e");
    }
  }

  Future<void> _cacheCourses() async {
    try {
      final cacheKey = 'cached_courses_${widget.TeacherData['id']}';
      await sharedPrefs.prefs.setString(cacheKey, jsonEncode(teacherData));
    } catch (e) {
      debugPrint("Error caching courses: $e");
    }
  }

  Future<void> _cacheRecentCourses() async {
    try {
      final cacheKey = 'cached_recent_courses_${widget.TeacherData['id']}';
      await sharedPrefs.prefs.setString(
        cacheKey,
        jsonEncode(recentCoursesData),
      );
    } catch (e) {
      debugPrint("Error caching recent courses: $e");
    }
  }

  Future<void> _cacheTopRatedCourses() async {
    try {
      final cacheKey = 'cached_top_rated_courses_${widget.TeacherData['id']}';
      await sharedPrefs.prefs.setString(
        cacheKey,
        jsonEncode(topRatedCoursesData),
      );
    } catch (e) {
      debugPrint("Error caching top rated courses: $e");
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
            (cacheManager.isCacheEnabled.value == false &&
                        sharedPrefs.prefs.getBool('isConnected') == false) ||
                    (widget.TeacherData.isEmpty && teacherData.isEmpty)
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
                              await _loadCachedCourses();
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
                : teacherData.isEmpty
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
                    await getCoursesData();
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
                                          "Teacher Courses".tr,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall!.copyWith(
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
                                            fontFamily: globalFontFamily,
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
                                            elements: teacherData,
                                            // elementsImages: coursesImages,
                                            searchType: 'courses',
                                            onItemTap: (course) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          CoursesLessons(
                                                            CoursesData: course,
                                                            index: teacherData
                                                                .indexOf(
                                                                  course,
                                                                ),
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
                            child:
                                (teacherData.isEmpty)
                                    ? noDataLottie("No data available")
                                    : Column(
                                      children: [
                                        const SizedBox(height: 21),
                                        Text(
                                          "Choose a course".tr,
                                          style: TextStyle(
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        24
                                                    : 24 -
                                                        (globalFontSizeChange /
                                                            5),
                                            fontWeight: FontWeight.bold,
                                            fontFamily: globalFontFamily,
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
                                                  mainAxisSpacing: 10,
                                                  crossAxisSpacing: 10,
                                                ),
                                            controller: scrollController,
                                            itemCount: teacherData.length,
                                            itemBuilder: (context, i) {
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => CoursesLessons(
                                                            CoursesData:
                                                                teacherData[i],
                                                            index: i,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            left: 1,
                                                            right: 10,
                                                          ),
                                                      // padding: const EdgeInsets.only(left: 10,right: 10),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            10,
                                                          ),
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
                                                        borderRadius:
                                                            BorderRadius.circular(
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
                                                                teacherData[i]["rating"] !=
                                                                        null
                                                                    ? Container(
                                                                      height:
                                                                          23,
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            6,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        color: Color(
                                                                          0xFFCCF2E0,
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
                                                                            size:
                                                                                20,
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                2,
                                                                          ),
                                                                          Text(
                                                                            // "${subscribedCourses[i]["rating"]}",
                                                                            double.parse(
                                                                              teacherData[i]["rating"].toString(),
                                                                            ).toStringAsFixed(
                                                                              1,
                                                                            ),
                                                                            style: TextStyle(
                                                                              overflow:
                                                                                  TextOverflow.clip,
                                                                              fontSize:
                                                                                  globalFontSizeChange >=
                                                                                          17
                                                                                      ? (globalFontSizeChange /
                                                                                              5) +
                                                                                          16
                                                                                      : 16 -
                                                                                          (globalFontSizeChange /
                                                                                              5),
                                                                              fontFamily:
                                                                                  globalFontFamily,
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
                                                                        ],
                                                                      ),
                                                                    )
                                                                    : const SizedBox.shrink(),

                                                                GetBuilder<
                                                                  FavoriteController
                                                                >(
                                                                  builder: (
                                                                    controller,
                                                                  ) {
                                                                    final isFav =
                                                                        controller
                                                                            .isFavoriteC[teacherData[i]["id"]
                                                                            .toString()] ??
                                                                        false;

                                                                    return LikeButton(
                                                                      size: 30,
                                                                      isLiked:
                                                                          isFav,
                                                                      likeBuilder: (
                                                                        bool
                                                                        isLiked,
                                                                      ) {
                                                                        return Icon(
                                                                              isLiked
                                                                                  ? Icons.favorite
                                                                                  : Icons.favorite_border_outlined,
                                                                              color:
                                                                                  Colors.red,
                                                                              size:
                                                                                  30,
                                                                            )
                                                                            .animate(
                                                                              onPlay: (
                                                                                controller,
                                                                              ) {
                                                                                if (isLiked) {
                                                                                  controller.repeat(
                                                                                    reverse:
                                                                                        true,
                                                                                  );
                                                                                }
                                                                              },
                                                                            )
                                                                            .scaleXY(
                                                                              begin:
                                                                                  isLiked
                                                                                      ? 1.2
                                                                                      : 1,
                                                                              end:
                                                                                  isLiked
                                                                                      ? 0.9
                                                                                      : 1,
                                                                              duration:
                                                                                  800.ms,
                                                                              curve:
                                                                                  Curves.easeInOut,
                                                                            );
                                                                      },
                                                                      onTap: (
                                                                        bool
                                                                        isLiked,
                                                                      ) async {
                                                                        controller.toggleFavoriteC(
                                                                          teacherData[i]["id"]
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
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const SizedBox(
                                                                  height: 34,
                                                                ),
                                                                teacherData[i]["image"] !=
                                                                        null
                                                                    ? CachedNetworkImage(
                                                                      imageUrl:
                                                                          "$mainIP/${teacherData[i]["image"]}",
                                                                      height:
                                                                          60,
                                                                      width: 60,
                                                                    )
                                                                    : Image.asset(
                                                                      ImageAssets
                                                                          .subject,
                                                                    ),

                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Text(
                                                                        "${teacherData[i]["name"]}"
                                                                            .tr,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              globalFontSizeChange >=
                                                                                      17
                                                                                  ? (globalFontSizeChange /
                                                                                          5) +
                                                                                      16
                                                                                  : 16 -
                                                                                      (globalFontSizeChange /
                                                                                          5),
                                                                          fontFamily:
                                                                              globalFontFamily,
                                                                          fontWeight:
                                                                              FontWeight.w500,
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
                                                                      )
                                                                      .animate()
                                                                      .fadeIn(
                                                                        delay:
                                                                            200.ms,
                                                                      )
                                                                      .slideY(
                                                                        begin:
                                                                            0.5,
                                                                        end: 0,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                    .animate(
                                                      delay: (i * 100).ms,
                                                    )
                                                    .fadeIn(duration: 400.ms)
                                                    .slideY(
                                                      begin: 0.5,
                                                      end: 0,
                                                      curve: Curves.easeOutBack,
                                                      duration: 500.ms,
                                                    )
                                                    .scaleXY(
                                                      begin: 0.8,
                                                      end: 1,
                                                      duration: 600.ms,
                                                      curve: Curves.elasticOut,
                                                    ),
                                              );
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
        // ),
      ),
    );
  }
}
