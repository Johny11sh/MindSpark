// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../view/LogIn.dart';
import '../../view/CoursesLessons.dart';
import '../../services/SharedPrefs.dart';
import '../../core/constants/ImageAssets.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../controller/NetworkController.dart';
import '../../locale/LocaleController.dart';
import '../../view/NavBar.dart';


class RatedCourses extends StatefulWidget {
  const RatedCourses({super.key});

  @override
  State<RatedCourses> createState() => _RatedCoursesState();
}

class _RatedCoursesState extends State<RatedCourses> {
  late SharedPrefs sharedPrefs;
  final ThemeController themeController = Get.find<ThemeController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final LocaleController localeController = Get.find<LocaleController>();

  List<Map<String, dynamic>> topRatedCourses = [];
  final Map<int, Uint8List> topRatedCoursesImages = {};
  List<Map<String, dynamic>> cachedTopRatedCourses = [];

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
      await getTopRatedCoursesData();
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load top-rated courses data
      final cachedTopRated = sharedPrefs.prefs.getString(
        'cached_top_rated_courses',
      );
      if (cachedTopRated != null) {
        final List<dynamic> parsedTopRatedList = jsonDecode(cachedTopRated);
        cachedTopRatedCourses = List<Map<String, dynamic>>.from(
          parsedTopRatedList,
        );
        topRatedCourses = List.from(cachedTopRatedCourses);
      }

      // Load images for top-rated courses
      await _loadTopRatedCoursesImages();
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  Future<void> _loadTopRatedCoursesImages() async {
    for (var course in topRatedCourses) {
      final imageKey = 'top_rated_course_image_${course['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          topRatedCoursesImages[course['id']] = base64Decode(cachedImage);
        });
      }
    }
  }

  Future<void> _cacheTopRatedCourses() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_top_rated_courses',
        jsonEncode(topRatedCourses),
      );
      cachedTopRatedCourses = List.from(topRatedCourses);
    } catch (e) {
      debugPrint("Error caching top-rated courses: $e");
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
      debugPrint("Error caching top-rated course image: $e");
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
      final APIurl = '$baseUrl/api/getallcoursesrated';

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
        final List<dynamic> topRatedCoursesList =
            responseBody is List
                ? responseBody
                : (responseBody['courses'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            topRatedCourses = List<Map<String, dynamic>>.from(
              topRatedCoursesList,
            );
          });
          await _cacheTopRatedCourses();
        }

        await Future.wait(
          topRatedCoursesList.map((course) async {
            final courseId = course['id'] as int;
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
        if (topRatedCourses.isEmpty) {
          setState(() {
            topRatedCourses = List.from(cachedTopRatedCourses);
          });
          if (topRatedCourses.isEmpty) {
            throw Exception(
              "Failed to load top-rated courses: ${response.statusCode}",
            );
          }
        }
      }
    } on TimeoutException {
      if (topRatedCourses.isEmpty) {
        setState(() {
          topRatedCourses = List.from(cachedTopRatedCourses);
        });
        if (topRatedCourses.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (topRatedCourses.isEmpty) {
        setState(() {
          topRatedCourses = List.from(cachedTopRatedCourses);
        });
        if (topRatedCourses.isEmpty) {
          showErrorSnackbar("Failed to load top-rated courses");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching top-rated courses: $e");
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
        debugPrint("Top-rated course image not found for ID: $courseId");
        return null;
      } else {
        throw Exception("Image fetch failed: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for top-rated course $courseId");
      return null;
    } catch (e) {
      debugPrint("Error fetching top-rated course image: $e");
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
        appBar: AppBar(
          title: Text("Top Rated Courses".tr),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: topRatedCourses.isEmpty
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
                  await getTopRatedCoursesData();
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: topRatedCourses.length + 1, // +1 for bottom spacing
                  itemBuilder: (context, index) {
                    if (index == topRatedCourses.length) {
                      // Bottom spacing item
                      return SizedBox(height: 30);
                    }

                    int courseId = topRatedCourses[index]["id"];
                    Uint8List? imageBytes = topRatedCoursesImages[courseId];

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CoursesLessons(
                                CoursesData: topRatedCourses[index],
                                index: index,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          child: Container(
                            height: 120,
                            child: Row(
                              children: [
                                // Course Image
                                Container(
                                  width: 120,
                                  height: 120,
                                  child: imageBytes != null
                                      ? Image.memory(
                                          imageBytes,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.asset(
                                              ImageAssets.subject,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          ImageAssets.subject,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                // Course Details
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${topRatedCourses[index]["name"]}".tr,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: themeController.initialTheme ==
                                                    Themes.customLightTheme
                                                ? Color.fromARGB(255, 40, 41, 61)
                                                : Color.fromARGB(255, 210, 209, 224),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Course ID: ${topRatedCourses[index]["id"]}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: themeController.initialTheme ==
                                                    Themes.customLightTheme
                                                ? Color.fromARGB(255, 40, 41, 61).withOpacity(0.7)
                                                : Color.fromARGB(255, 210, 209, 224).withOpacity(0.7),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "Top Rated",
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
                                  padding: EdgeInsets.only(right: 16),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
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