// ignore_for_file: avoid_print, non_constant_identifier_names, file_names, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:like_button/like_button.dart';

import '../controller/FavoriteController.dart';
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
import 'OnBoarding.dart';

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
  final Map<int, Uint8List> coursesImages = {};
  bool isFavorite = false;

  // --- Most Recent Courses ---
  List<Map<String, dynamic>> recentCoursesData = [];
  final Map<int, Uint8List> recentCoursesImages = {};

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
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    // Try to load from cache first
    await _loadCachedCourses();

    // Then try to fetch fresh data if online
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getCoursesData();
      // await getTopRatedCoursesData();
      // await getRecentCoursesData();
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

        // Load cached images
        for (final course in teacherData) {
          final imageKey = 'course_image_${course['id']}';
          final imageString = sharedPrefs.prefs.getString(imageKey);
          if (imageString != null && mounted) {
            setState(() {
              coursesImages[course['id']] = base64Decode(imageString);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading cached courses: $e");
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

  Future<void> _cacheCourseImage(int courseId, Uint8List imageBytes) async {
    try {
      await sharedPrefs.prefs.setString(
        'course_image_$courseId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching course image: $e");
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

        // 5. State Management and caching
        if (mounted) {
          setState(() {
            teacherData = List<Map<String, dynamic>>.from(coursesList);
          });
          await _cacheCourses();
        }

        // 6. Parallel Image Loading and caching
        await Future.wait(
          coursesList.map((course) async {
            final courseId = course["id"] as int;
            final imageBytes = await getCoursesImage(course);
            if (imageBytes != null && mounted) {
              setState(() {
                coursesImages[courseId] = imageBytes;
              });
              await _cacheCourseImage(courseId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        // If API fails but we have cached data, don't throw error
        if (teacherData.isEmpty) {
          throw Exception("Failed to load courses: ${response.statusCode}");
        }
      }
    } on TimeoutException {
      // If we have cached data, just show a warning
      if (teacherData.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      // If we have cached data, just show a warning
      if (teacherData.isEmpty) {
        showErrorSnackbar("Failed to load courses");
      } else {
        showErrorSnackbar("Using cached data - ${e.toString()}");
      }
      debugPrint("Error fetching courses: $e");
    }
  }

  Future<Uint8List?> getCoursesImage(dynamic course) async {
    // First try to get from cache
    final courseId = course is Map ? course['id'] as int : course as int;
    final cachedImage = sharedPrefs.prefs.getString('course_image_$courseId');
    if (cachedImage != null) {
      return base64Decode(cachedImage);
    }

    // If not in cache and offline, return null
    if (sharedPrefs.prefs.getBool('isConnected') == false) {
      return null;
    }

    // Otherwise fetch from API
    try {
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) return null;

      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final url = '$baseUrl/api/getcourseimage/$courseId';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': "Bearer $token",
              'Accept': 'application/octet-stream',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 404) {
        debugPrint("course image not found for ID: $courseId");
        return null;
      } else {
        throw Exception("Image fetch failed: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for course $courseId");
      return null;
    } catch (e) {
      debugPrint("Error fetching course image: $e");
      return null;
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

  Future<void> _loadCachedRecentCourses() async {
    try {
      final cacheKey = 'cached_recent_courses_${widget.TeacherData['id']}';
      final cachedData = sharedPrefs.prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> parsedList = jsonDecode(cachedData);
        setState(() {
          recentCoursesData = List<Map<String, dynamic>>.from(parsedList);
        });
        // Load cached images
        for (final course in recentCoursesData) {
          final imageKey = 'recent_course_image_${course['id']}';
          final imageString = sharedPrefs.prefs.getString(imageKey);
          if (imageString != null && mounted) {
            setState(() {
              recentCoursesImages[course['id']] = base64Decode(imageString);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading cached recent courses: $e");
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

  Future<void> _cacheRecentCourseImage(
    int courseId,
    Uint8List imageBytes,
  ) async {
    try {
      await sharedPrefs.prefs.setString(
        'recent_course_image_$courseId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching recent course image: $e");
    }
  }

  Future<void> getRecentCoursesData() async {
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
      final APIurl =
          '$baseUrl/api/getteachercoursesrecent/${widget.TeacherData['id']}';
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
      debugPrint(
        "Recent Courses API response: " + response.statusCode.toString(),
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> coursesList =
            responseBody is List
                ? responseBody
                : (responseBody['courses'] ?? [responseBody]);
        if (mounted) {
          setState(() {
            recentCoursesData = List<Map<String, dynamic>>.from(coursesList);
          });
          await _cacheRecentCourses();
        }
        await Future.wait(
          coursesList.map((course) async {
            final courseId = course["id"] as int;
            final imageBytes = await getRecentCourseImage(course);
            if (imageBytes != null && mounted) {
              setState(() {
                recentCoursesImages[courseId] = imageBytes;
              });
              await _cacheRecentCourseImage(courseId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (recentCoursesData.isEmpty) {
          throw Exception(
            "Failed to load recent courses: " + response.statusCode.toString(),
          );
        }
      }
    } on TimeoutException {
      if (recentCoursesData.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      if (recentCoursesData.isEmpty) {
        showErrorSnackbar("Failed to load recent courses");
      } else {
        showErrorSnackbar("Using cached data - " + e.toString());
      }
      debugPrint("Error fetching recent courses: $e");
    }
  }

  Future<Uint8List?> getRecentCourseImage(dynamic course) async {
    final courseId = course is Map ? course['id'] as int : course as int;
    final cachedImage = sharedPrefs.prefs.getString(
      'recent_course_image_$courseId',
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
      final url = '$baseUrl/api/getcourseimage/$courseId';
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': "Bearer $token",
              'Accept': 'application/octet-stream',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 404) {
        debugPrint("Recent course image not found for ID: $courseId");
        return null;
      } else {
        throw Exception(
          "Image fetch failed: " + response.statusCode.toString(),
        );
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for recent course $courseId");
      return null;
    } catch (e) {
      debugPrint("Error fetching recent course image: $e");
      return null;
    }
  }

  // --- Top Rated Courses ---
  List<Map<String, dynamic>> topRatedCoursesData = [];
  final Map<int, Uint8List> topRatedCoursesImages = {};

  Future<void> _loadCachedTopRatedCourses() async {
    try {
      final cacheKey = 'cached_top_rated_courses_${widget.TeacherData['id']}';
      final cachedData = sharedPrefs.prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> parsedList = jsonDecode(cachedData);
        setState(() {
          topRatedCoursesData = List<Map<String, dynamic>>.from(parsedList);
        });
        // Load cached images
        for (final course in topRatedCoursesData) {
          final imageKey = 'top_rated_course_image_${course['id']}';
          final imageString = sharedPrefs.prefs.getString(imageKey);
          if (imageString != null && mounted) {
            setState(() {
              topRatedCoursesImages[course['id']] = base64Decode(imageString);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading cached top rated courses: $e");
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

  Future<void> _cacheTopRatedCourseImage(
    int courseId,
    Uint8List imageBytes,
  ) async {
    try {
      await sharedPrefs.prefs.setString(
        'top_rated_course_image_$courseId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching top rated course image: $e");
    }
  }

  Future<void> getTopRatedCoursesData() async {
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
      final APIurl =
          '$baseUrl/api/getteachercoursesrated/${widget.TeacherData['id']}';
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
      debugPrint(
        "Top Rated Courses API response: " + response.statusCode.toString(),
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> coursesList =
            responseBody is List
                ? responseBody
                : (responseBody['courses'] ?? [responseBody]);
        if (mounted) {
          setState(() {
            topRatedCoursesData = List<Map<String, dynamic>>.from(coursesList);
          });
          await _cacheTopRatedCourses();
        }
        await Future.wait(
          coursesList.map((course) async {
            final courseId = course["id"] as int;
            final imageBytes = await getTopRatedCourseImage(course);
            if (imageBytes != null && mounted) {
              setState(() {
                topRatedCoursesImages[courseId] = imageBytes;
              });
              await _cacheTopRatedCourseImage(courseId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (topRatedCoursesData.isEmpty) {
          throw Exception(
            "Failed to load top rated courses: " +
                response.statusCode.toString(),
          );
        }
      }
    } on TimeoutException {
      if (topRatedCoursesData.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      if (topRatedCoursesData.isEmpty) {
        showErrorSnackbar("Failed to load top rated courses");
      } else {
        showErrorSnackbar("Using cached data - " + e.toString());
      }
      debugPrint("Error fetching top rated courses: $e");
    }
  }

  Future<Uint8List?> getTopRatedCourseImage(dynamic course) async {
    final courseId = course is Map ? course['id'] as int : course as int;
    final cachedImage = sharedPrefs.prefs.getString(
      'top_rated_course_image_$courseId',
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
      final url = '$baseUrl/api/getcourseimage/$courseId';
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': "Bearer $token",
              'Accept': 'application/octet-stream',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 404) {
        debugPrint("Top rated course image not found for ID: $courseId");
        return null;
      } else {
        throw Exception(
          "Image fetch failed: " + response.statusCode.toString(),
        );
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for top rated course $courseId");
      return null;
    } catch (e) {
      debugPrint("Error fetching top rated course image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // appBar: AppBar(
        //   leading: IconButton(
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => Favorites()),
        //       );
        //     },
        //     icon: Icon(Icons.favorite),
        //   ),
        //   title: Text("Home Page".tr),
        //   centerTitle: true,
        //   actions: [
        //     IconButton(
        //       onPressed: () {
        //         showSearch(
        //           context: context,
        //           delegate: SearchCustom(teacherData, coursesImages),
        //         );
        //       },
        //       icon: Icon(Icons.search_outlined),
        //     ),
        //   ],
        // ),
        body:
            teacherData.isEmpty
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
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 30),
                        height: 100,
                        color:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 210, 209, 224)
                                : Color.fromARGB(255, 40, 41, 61),
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
                                    " Teachers Course ".tr,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall!.copyWith(
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
                                    delegate: SearchCustom(
                                      teacherData,
                                      coursesImages,
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.search_outlined,
                                  color: Color.fromARGB(255, 210, 209, 224),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            color:
                                themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 21),
                              Text(
                                "Choose a course".tr,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 210, 209, 224)
                                          : Color.fromARGB(255, 40, 41, 61),
                                ),
                              ),
                              SizedBox(height: 20),
                              Expanded(
                                child: GridView.builder(
                                  scrollDirection: Axis.vertical,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                      ),
                                  controller: scrollController,
                                  itemCount: teacherData.length,
                                  itemBuilder: (context, i) {
                                    int courseId = teacherData[i]["id"];
                                    Uint8List? imageBytes =
                                        coursesImages[courseId];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => CoursesLessons(
                                                  CoursesData: teacherData[i],
                                                  index: i,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: 1,
                                          right: 10,
                                        ),
                                        // padding: EdgeInsets.only(left: 10,right: 10),
                                        padding: EdgeInsets.all(10),
                                        height: 130,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color.fromARGB(
                                              255,
                                              40,
                                              41,
                                              61,
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
                                                  teacherData[i]["rating"] !=
                                                          null
                                                      ? Container(
                                                        height: 23,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Color(
                                                            0xFFCCF2E0,
                                                          ),
                                                          border: Border.all(
                                                            color:
                                                                Color.fromARGB(
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
                                                              size: 20,
                                                            ),
                                                            SizedBox(width: 2),
                                                            Text(
                                                              // "${subscribedCourses[i]["rating"]}",
                                                              double.parse(
                                                                teacherData[i]["rating"]
                                                                    .toString(),
                                                              ).toStringAsFixed(
                                                                1,
                                                              ),
                                                              style: TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                                fontSize: 16,
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
                                                      : SizedBox.shrink(),

                                                  GetBuilder<
                                                    FavoriteController
                                                  >(
                                                    builder: (controller) {
                                                      final isFav =
                                                          controller
                                                              .isFavoriteC[teacherData[i]["id"]
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
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(height: 34),
                                                  imageBytes != null
                                                      ? Image.asset(
                                                        ImageAssets.book,
                                                        height: 90,
                                                        width: 90,
                                                      )
                                                      : Image.asset(
                                                        ImageAssets.subject,
                                                      ),

                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "${teacherData[i]["name"]}"
                                                          .tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
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
                                          ],
                                        ),
                                      ),
                                    );
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

class SearchCustom extends SearchDelegate {
  final List elements;
  final Map<int, Uint8List> elementsImages;

  SearchCustom(this.elements, this.elementsImages);

  List? sortedItems;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.cleaning_services),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    sortedItems =
        elements
            .where(
              (element) =>
                  element["name"].toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return ListView.builder(
      itemCount: sortedItems!.length,
      itemBuilder: (context, index) {
        int elementsId = sortedItems![index]["id"];
        Uint8List? imageBytes =
            elementsImages[elementsId]; // Fetch from storeImages map

        return InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => CoursesLessons(
                      CoursesData: sortedItems![index],
                      index: index,
                    ),
              ),
            );
          },
          child: SizedBox(
            height: 100,
            child: Card(
              child: ListTile(
                leading:
                    imageBytes != null
                        ? Image.memory(
                          imageBytes,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              ImageAssets.course,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                        : Image.asset(
                          ImageAssets.course,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                title: Text(
                  sortedItems![index]["name"],
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 40, 41, 61)
                            : Color.fromARGB(255, 210, 209, 224),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    sortedItems =
        elements
            .where(
              (element) =>
                  element["name"].toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return ListView.builder(
      itemCount: sortedItems!.length,
      itemBuilder: (context, index) {
        int elementsId = sortedItems![index]["id"];
        Uint8List? imageBytes =
            elementsImages[elementsId]; // Fetch from storeImages map

        return SizedBox(
          height: 100,
          child: Card(
            child: ListTile(
              leading:
                  imageBytes != null
                      ? Image.memory(
                        imageBytes,
                        // height: 80,
                        // width:80,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            ImageAssets.course,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                      : Image.asset(
                        ImageAssets.course,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
              title: Center(
                child: Text(
                  sortedItems![index]["name"],
                  style: TextStyle(
                    fontSize: 20,
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 40, 41, 61)
                            : Color.fromARGB(255, 210, 209, 224),
                  ),
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CoursesLessons(
                          CoursesData: sortedItems![index],
                          index: index,
                        ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
