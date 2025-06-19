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


class RecommendedCourses extends StatefulWidget {
  const RecommendedCourses({super.key});

  @override
  State<RecommendedCourses> createState() => _RecommendedCoursesState();
}

class _RecommendedCoursesState extends State<RecommendedCourses> {
  late SharedPrefs sharedPrefs;
  final ThemeController themeController = Get.find<ThemeController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final LocaleController localeController = Get.find<LocaleController>();

  List<Map<String, dynamic>> recommendedCourses = [];
  final Map<int, Uint8List> recommendedCoursesImages = {};
  List<Map<String, dynamic>> cachedRecommendedCourses = [];

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
      await getRecommendedCoursesData();
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load recommended courses data
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

      // Load images for recommended courses
      await _loadRecommendedCoursesImages();
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  Future<void> _loadRecommendedCoursesImages() async {
    for (var course in recommendedCourses) {
      final imageKey = 'recommended_course_image_${course['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          recommendedCoursesImages[course['id']] = base64Decode(cachedImage);
        });
      }
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

  Future<void> _cacheRecommendedCourseImage(
    int courseId,
    Uint8List imageBytes,
  ) async {
    try {
      await sharedPrefs.prefs.setString(
        'recommended_course_image_$courseId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching recommended course image: $e");
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

  Future<void> getRecommendedCoursesData() async {
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
      final APIurl = '$baseUrl/api/getallcoursesrecommended';

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
                : (responseBody['courses'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            recommendedCourses = List<Map<String, dynamic>>.from(
              recommendedCoursesList,
            );
          });
          await _cacheRecommendedCourses();
        }

        await Future.wait(
          recommendedCoursesList.map((course) async {
            final courseId = course['id'] as int;
            final imageBytes = await getRecommendedCourseImage(course);
            if (imageBytes != null && mounted) {
              setState(() {
                recommendedCoursesImages[courseId] = imageBytes;
              });
              await _cacheRecommendedCourseImage(courseId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (recommendedCourses.isEmpty) {
          setState(() {
            recommendedCourses = List.from(cachedRecommendedCourses);
          });
          if (recommendedCourses.isEmpty) {
            throw Exception(
              "Failed to load recommended courses: ${response.statusCode}",
            );
          }
        }
      }
    } on TimeoutException {
      if (recommendedCourses.isEmpty) {
        setState(() {
          recommendedCourses = List.from(cachedRecommendedCourses);
        });
        if (recommendedCourses.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (recommendedCourses.isEmpty) {
        setState(() {
          recommendedCourses = List.from(cachedRecommendedCourses);
        });
        if (recommendedCourses.isEmpty) {
          showErrorSnackbar("Failed to load recommended courses");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching recommended courses: $e");
    }
  }

  Future<Uint8List?> getRecommendedCourseImage(dynamic course) async {
    final courseId = course is Map ? course['id'] as int : course as int;
    final cachedImage = sharedPrefs.prefs.getString(
      'recommended_course_image_$courseId',
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
        debugPrint("Recommended course image not found for ID: $courseId");
        return null;
      } else {
        throw Exception("Image fetch failed: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for recommended course $courseId");
      return null;
    } catch (e) {
      debugPrint("Error fetching recommended course image: $e");
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
          title: Text("Recommended Courses".tr),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: recommendedCourses.isEmpty
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
                  await getRecommendedCoursesData();
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: recommendedCourses.length + 1, // +1 for bottom spacing
                  itemBuilder: (context, index) {
                    if (index == recommendedCourses.length) {
                      // Bottom spacing item
                      return SizedBox(height: 30);
                    }

                    int courseId = recommendedCourses[index]["id"];
                    Uint8List? imageBytes = recommendedCoursesImages[courseId];

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CoursesLessons(
                                CoursesData: recommendedCourses[index],
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
                                          "${recommendedCourses[index]["name"]}".tr,
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
                                          "Course ID: ${recommendedCourses[index]["id"]}",
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