// ignore_for_file: file_names, non_constant_identifier_names, unnecessary_null_comparison, avoid_print, unused_element

import 'dart:async';
import 'dart:io';
import '../core/classes/PDFOpener.dart';
import '../view/LogIn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controller/NetworkController.dart';
import '../core/constants/ImageAssets.dart';
import '../locale/LocaleController.dart';
import '../themes/ThemeController.dart';
import '../services/SharedPrefs.dart';
import '../themes/Themes.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'Favorites.dart';
import 'NavBar.dart';
import 'VideoPlayer.dart';
// import 'VideoPlayerScreen.dart';

class CoursesLessons extends StatefulWidget {
  final Map<String, dynamic> CoursesData;
  final int index;
  const CoursesLessons({
    super.key,
    required this.CoursesData,
    required this.index,
  });

  @override
  State<CoursesLessons> createState() => _CoursesLessonsState();
}

class _CoursesLessonsState extends State<CoursesLessons> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final NetworkController networkController = Get.find<NetworkController>();
  late SharedPrefs sharedPrefs;

  ScrollController scrollController = ScrollController();
  bool downloading = false;
  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  String filePath = "";
  // CancelToken? cancelToken;
  bool isPreparingPlayback = false;

  List<Map<String, dynamic>> coursesData = [];
  final Map<int, Uint8List> lecturesImages = {};
  bool? isLectureSubscribed = false;

  // --- Most Recent Lessons ---
  List<Map<String, dynamic>> recentLessonsData = [];
  final Map<int, Uint8List> recentLessonsImages = {};

  Future<void> _loadCachedRecentLessons() async {
    try {
      final cacheKey = 'cached_recent_lessons_${widget.CoursesData['id']}';
      final cachedData = sharedPrefs.prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> parsedList = jsonDecode(cachedData);
        setState(() {
          recentLessonsData = List<Map<String, dynamic>>.from(parsedList);
        });
        // Load cached images
        for (final lesson in recentLessonsData) {
          final imageKey = 'recent_lesson_image_${lesson['id']}';
          final imageString = sharedPrefs.prefs.getString(imageKey);
          if (imageString != null && mounted) {
            setState(() {
              recentLessonsImages[lesson['id']] = base64Decode(imageString);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading cached recent lessons: $e");
    }
  }

  Future<void> _cacheRecentLessons() async {
    try {
      final cacheKey = 'cached_recent_lessons_${widget.CoursesData['id']}';
      await sharedPrefs.prefs.setString(cacheKey, jsonEncode(recentLessonsData));
    } catch (e) {
      debugPrint("Error caching recent lessons: $e");
    }
  }

  Future<void> _cacheRecentLessonImage(int lessonId, Uint8List imageBytes) async {
    try {
      await sharedPrefs.prefs.setString(
        'recent_lesson_image_$lessonId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching recent lesson image: $e");
    }
  }

  Future<void> getRecentLessonsData() async {
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
      final APIurl = '$baseUrl/api/getcourselectures/${widget.CoursesData['id']}/recent';
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
      debugPrint("Recent Lessons API response: "+response.statusCode.toString());
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> lessonsList =
            responseBody is List
                ? responseBody
                : (responseBody['lessons'] ?? [responseBody]);
        if (mounted) {
          setState(() {
            recentLessonsData = List<Map<String, dynamic>>.from(lessonsList);
          });
          await _cacheRecentLessons();
        }
        await Future.wait(
          lessonsList.map((lesson) async {
            final lessonId = lesson['id'] as int;
            final imageBytes = await getRecentLessonImage(lesson);
            if (imageBytes != null && mounted) {
              setState(() {
                recentLessonsImages[lessonId] = imageBytes;
              });
              await _cacheRecentLessonImage(lessonId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (recentLessonsData.isEmpty) {
          throw Exception("Failed to load recent lessons: "+response.statusCode.toString());
        }
      }
    } on TimeoutException {
      if (recentLessonsData.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      if (recentLessonsData.isEmpty) {
        showErrorSnackbar("Failed to load recent lessons");
      } else {
        showErrorSnackbar("Using cached data - "+e.toString());
      }
      debugPrint("Error fetching recent lessons: $e");
    }
  }

  Future<Uint8List?> getRecentLessonImage(dynamic lesson) async {
    final lessonId = lesson is Map ? lesson['id'] as int : lesson as int;
    final cachedImage = sharedPrefs.prefs.getString('recent_lesson_image_$lessonId');
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
      final url = '$baseUrl/api/getlectureimage/$lessonId';
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
        debugPrint("Recent lesson image not found for ID: $lessonId");
        return null;
      } else {
        throw Exception("Image fetch failed: "+response.statusCode.toString());
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for recent lesson $lessonId");
      return null;
    } catch (e) {
      debugPrint("Error fetching recent lesson image: $e");
      return null;
    }
  }

  // --- Top Rated Lessons ---
  List<Map<String, dynamic>> topRatedLessonsData = [];
  final Map<int, Uint8List> topRatedLessonsImages = {};

  Future<void> _loadCachedTopRatedLessons() async {
    try {
      final cacheKey = 'cached_top_rated_lessons_${widget.CoursesData['id']}';
      final cachedData = sharedPrefs.prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> parsedList = jsonDecode(cachedData);
        setState(() {
          topRatedLessonsData = List<Map<String, dynamic>>.from(parsedList);
        });
        // Load cached images
        for (final lesson in topRatedLessonsData) {
          final imageKey = 'top_rated_lesson_image_${lesson['id']}';
          final imageString = sharedPrefs.prefs.getString(imageKey);
          if (imageString != null && mounted) {
            setState(() {
              topRatedLessonsImages[lesson['id']] = base64Decode(imageString);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading cached top rated lessons: $e");
    }
  }

  Future<void> _cacheTopRatedLessons() async {
    try {
      final cacheKey = 'cached_top_rated_lessons_${widget.CoursesData['id']}';
      await sharedPrefs.prefs.setString(cacheKey, jsonEncode(topRatedLessonsData));
    } catch (e) {
      debugPrint("Error caching top rated lessons: $e");
    }
  }

  Future<void> _cacheTopRatedLessonImage(int lessonId, Uint8List imageBytes) async {
    try {
      await sharedPrefs.prefs.setString(
        'top_rated_lesson_image_$lessonId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching top rated lesson image: $e");
    }
  }

  Future<void> getTopRatedLessonsData() async {
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
      final APIurl = '$baseUrl/api/getcourselectures/${widget.CoursesData['id']}/rated';
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
      debugPrint("Top Rated Lessons API response: "+response.statusCode.toString());
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> lessonsList =
            responseBody is List
                ? responseBody
                : (responseBody['lessons'] ?? [responseBody]);
        if (mounted) {
          setState(() {
            topRatedLessonsData = List<Map<String, dynamic>>.from(lessonsList);
          });
          await _cacheTopRatedLessons();
        }
        await Future.wait(
          lessonsList.map((lesson) async {
            final lessonId = lesson['id'] as int;
            final imageBytes = await getTopRatedLessonImage(lesson);
            if (imageBytes != null && mounted) {
              setState(() {
                topRatedLessonsImages[lessonId] = imageBytes;
              });
              await _cacheTopRatedLessonImage(lessonId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (topRatedLessonsData.isEmpty) {
          throw Exception("Failed to load top rated lessons: "+response.statusCode.toString());
        }
      }
    } on TimeoutException {
      if (topRatedLessonsData.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      if (topRatedLessonsData.isEmpty) {
        showErrorSnackbar("Failed to load top rated lessons");
      } else {
        showErrorSnackbar("Using cached data - "+e.toString());
      }
      debugPrint("Error fetching top rated lessons: $e");
    }
  }

  Future<Uint8List?> getTopRatedLessonImage(dynamic lesson) async {
    final lessonId = lesson is Map ? lesson['id'] as int : lesson as int;
    final cachedImage = sharedPrefs.prefs.getString('top_rated_lesson_image_$lessonId');
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
      final url = '$baseUrl/api/getlectureimage/$lessonId';
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
        debugPrint("Top rated lesson image not found for ID: $lessonId");
        return null;
      } else {
        throw Exception("Image fetch failed: "+response.statusCode.toString());
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for top rated lesson $lessonId");
      return null;
    } catch (e) {
      debugPrint("Error fetching top rated lesson image: $e");
      return null;
    }
  }

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
    await _loadCachedLectures();

    // Then try to fetch fresh data if online
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getLecturesData();
      // await getTopRatedLessonsData();
      // await getRecentLessonsData();

    }
  }

  Future<void> _loadCachedLectures() async {
    try {
      final cacheKey = 'cached_lectures_${widget.CoursesData['id']}';
      final cachedData = sharedPrefs.prefs.getString(cacheKey);

      if (cachedData != null) {
        final List<dynamic> parsedList = jsonDecode(cachedData);
        setState(() {
          coursesData = List<Map<String, dynamic>>.from(parsedList);
        });

        // Load cached images
        for (final lecture in coursesData) {
          final imageKey = 'lecture_image_${lecture['id']}';
          final imageString = sharedPrefs.prefs.getString(imageKey);
          if (imageString != null && mounted) {
            setState(() {
              lecturesImages[lecture['id']] = base64Decode(imageString);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading cached lectures: $e");
    }
  }

  Future<void> _cacheLectures() async {
    try {
      final cacheKey = 'cached_lectures_${widget.CoursesData['id']}';
      await sharedPrefs.prefs.setString(cacheKey, jsonEncode(coursesData));
    } catch (e) {
      debugPrint("Error caching lectures: $e");
    }
  }

  Future<void> _cacheLectureImage(int lectureId, Uint8List imageBytes) async {
    try {
      await sharedPrefs.prefs.setString(
        'lecture_image_$lectureId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching lecture image: $e");
    }
  }

  Future<void> getSubscription(int id) async {
    final token = sharedPrefs.prefs.getString('token') ?? '';
    if (token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => LogIn());
        showErrorSnackbar("Session expired. Please log in again.".tr);
      });
      return;
    }

    try {
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/lectureissubscribed/${id}';

      final response = await http
          .get(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            isLectureSubscribed = responseBody['isSubscribed'];
          });
        }
      } else if (response.statusCode == 404) {
        Get.snackbar("Error".tr, "Problem fetching the lecture".tr);
      }
    } on http.ClientException catch (e) {
      print("Network error: ${e.message}");
      Get.snackbar(
        "Network Error".tr,
        "Could not connect to the server. Please check your connection.".tr,
      );
    } on TimeoutException catch (_) {
      Get.snackbar(
        "Timeout".tr,
        "The request took too long. Please try again.".tr,
      );
    } on FormatException catch (_) {
      Get.snackbar("Error".tr, "Invalid server response".tr);
    } catch (e) {
      print("Unexpected error: $e");
      Get.snackbar("Error".tr, "An unexpected error occurred".tr);
    }
  }

  Future<void> getLecturesData() async {
    // 1. Token validation with early return
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
          '$baseUrl/api/getcourselectures/${widget.CoursesData['id']}';

      // 3. API request with timeout
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

      debugPrint("Lectures API response: ${response.statusCode}");

      // 4. Response handling
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Handle both array and object responses
        final List<dynamic> lecturesList =
            responseBody is List
                ? responseBody
                : (responseBody['lectures'] ?? [responseBody]);

        // 5. State Management and caching
        if (mounted) {
          setState(() {
            coursesData = List<Map<String, dynamic>>.from(lecturesList);
          });
          await _cacheLectures();
        }

        // 6. Parallel Image Loading and caching
        await Future.wait(
          lecturesList.map((lecture) async {
            final lectureId = lecture['id'] as int;
            final imageBytes = await getLecturesImage(lecture);
            if (imageBytes != null && mounted) {
              setState(() {
                lecturesImages[lectureId] = imageBytes;
              });
              await _cacheLectureImage(lectureId, imageBytes);
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
        if (coursesData.isEmpty) {
          throw Exception("Failed to load lectures: ${response.statusCode}");
        }
      }
    } on TimeoutException {
      // If we have cached data, just show a warning
      if (coursesData.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      // If we have cached data, just show a warning
      if (coursesData.isEmpty) {
        showErrorSnackbar("Failed to load lectures");
      } else {
        showErrorSnackbar("Using cached data - ${e.toString()}");
      }
      debugPrint("Error fetching lectures: $e");
    }
  }

  Future<Uint8List?> getLecturesImage(dynamic lecture) async {
    // First try to get from cache
    final lectureId = lecture is Map ? lecture['id'] as int : lecture as int;
    final cachedImage = sharedPrefs.prefs.getString('lecture_image_$lectureId');
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
      final url = '$baseUrl/api/getlectureimage/$lectureId';

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
        debugPrint("Lecture image not found for ID: $lectureId");
        return null;
      } else {
        throw Exception("Image fetch failed: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for lecture $lectureId");
      return null;
    } catch (e) {
      debugPrint("Error fetching lecture image: $e");
      return null;
    }
  }

  void showErrorSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(message),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red[800]!,
      isDismissible: true,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  static Future<File> loadNetwork(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    return _storeFile(url, bytes);
  }

  static Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  void openPDF(BuildContext context, File file) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => PDFOpener(PDFfile: file)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Favorites()),
              );
            },
            icon: Icon(Icons.favorite),
          ),
          title: Text("Home Page".tr),
          centerTitle: true,
        ),
        body:
            coursesData.isEmpty
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
                    await getLecturesData();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 50),
                      Text(
                        "Choose a lesson".tr,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                        ),
                      ),
                      SizedBox(height: 50),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: AlwaysScrollableScrollPhysics(),
                          controller: scrollController,
                          itemCount: coursesData.length,
                          itemBuilder: (context, i) {
                            int lectureId = coursesData[i]["id"];
                            Uint8List? imageBytes = lecturesImages[lectureId];

                            return InkWell(
                              onTap: () async {
                                await getSubscription(lectureId);

                                if (isLectureSubscribed == true) {
                                  if (coursesData[i]['type'] == 0) {
                                    try {
                                      final PDFurl = coursesData[i]['urlpdf'];
                                      // "http://www.pdf995.com/samples/pdf.pdf";
                                      final file = await loadNetwork(PDFurl);
                                      if (mounted) {
                                        openPDF(context, file);
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        showErrorSnackbar(
                                          "Failed to load PDF: ${e.toString()}",
                                        );
                                      }
                                    }
                                  } else if (coursesData[i]['type'] ==
                                      1) {
                                    try {
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => VideoPlayer(
                                                  videoUrl:
                                                      coursesData[i]['url360'],
                                                  // 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                                                  url360p:
                                                      coursesData[i]['url360'],
                                                  url720p:
                                                      coursesData[i]['url720'],
                                                  url1080p:
                                                      coursesData[i]['url1080'],
                                                ),
                                            fullscreenDialog: true,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        showErrorSnackbar(
                                          "Failed to load Video: ${e.toString()}",
                                        );
                                      }
                                    }
                                  }
                                } else {
                                  Get.rawSnackbar(
                                    titleText: Text(
                                      "Not subscribed!".tr,
                                      style: TextStyle(
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
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                      ),
                                    ),
                                    messageText: Text(
                                      'Contact the support team for instructions on how to subscribe to the course/subject first.'
                                          .tr,
                                      style: TextStyle(
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
                                    isDismissible: true,
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: Color.fromARGB(
                                      255,
                                      210,
                                      209,
                                      224,
                                    ),
                                    icon: FaIcon(
                                      FontAwesomeIcons.ban,
                                      size: 30,
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
                                    margin: const EdgeInsets.all(5),
                                    borderRadius: 5,
                                    borderColor: Color.fromARGB(
                                      255,
                                      40,
                                      41,
                                      61,
                                    ),
                                  );
                                }
                              },
                              child: Card(
                                child: ListTile(
                                  leading:
                                      imageBytes != null
                                          ? Image.memory(
                                            imageBytes,
                                            fit: BoxFit.fill,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Image.asset(
                                                ImageAssets.lecture,
                                                height: 125,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                          : Image.asset(ImageAssets.lecture),
                                  title: Text(
                                    "${coursesData[i]["name"]}".tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
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
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        "1- ".tr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
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

                                      Text(
                                        "${coursesData[i]["name"]}".tr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w300,
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
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 25,
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
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
