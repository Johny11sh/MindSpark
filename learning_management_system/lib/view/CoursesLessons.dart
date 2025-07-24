// ignore_for_file: file_names, non_constant_identifier_names, unnecessary_null_comparison, avoid_print, unused_element

import 'dart:async';
import 'dart:io';
import 'package:learning_management_system/core/classes/QuizScreen.dart';
import 'package:like_button/like_button.dart';
// import 'package:rating_dialog/rating_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/FavoriteController.dart';
import '../core/classes/PDFOpener.dart';
// import '../core/classes/Timer.dart';
import '../core/function/CustomRatingDialog.dart';
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
// import 'Favorites.dart';
import 'NavBar.dart';
import 'VideoPlayer.dart';

class CoursesLessons extends StatefulWidget {
  final Map<String, dynamic> CoursesData;
  final Uint8List? CoursesImage;
  final int index;
  const CoursesLessons({
    super.key,
    required this.CoursesData,
    required this.CoursesImage,
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
  var ChosenScreen = "About";
  bool downloading = false;
  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  String filePath = "";

  // CancelToken? cancelToken;
  bool isPreparingPlayback = false;

  bool isRated = false;

 late int userRating ;

  Map<int, bool> ratedLessons = {};


  List<Map<String, dynamic>> coursesData = [];
  final Map<int, Uint8List> lecturesImages = {};
  bool? isLectureSubscribed = false;

  // --- Most Recent Lessons ---
  List<Map<String, dynamic>> recentLessonsData = [];
  final Map<int, Uint8List> recentLessonsImages = {};

  // void showRatingDailog(BuildContext context, int courseId) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder:
  //         (context) => RatingDialog(
  //           initialRating: 1.5,
  //           title: Text(
  //             'Rating Dialog'.tr,
  //             textAlign: TextAlign.center,
  //             style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
  //           ),
  //           message: Text(
  //             'Tap a star to set your rating. Add more description here if you want.'
  //                 .tr,
  //             textAlign: TextAlign.center,
  //             style: const TextStyle(fontSize: 15),
  //           ),
  //           // your app's logo?
  //           image: Image.asset("${ImageAssets.AppLogo}", height: 160),
  //           submitButtonText: 'Submit',
  //           submitButtonTextStyle: TextStyle(
  //             color:
  //                 themeController.initialTheme == Themes.customLightTheme
  //                     ? Color.fromARGB(255, 40, 41, 61)
  //                     : Color.fromARGB(255, 210, 209, 224),
  //
  //             fontSize: 17,
  //           ),
  //           commentHint: 'Enter Your Rating',
  //           onCancelled: () => print('cancelled'),
  //           onSubmitted: (response) {
  //             print('rating: ${response.rating}, comment: ${response.comment}');
  //             submitRating(courseId, response.rating, response.comment);
  //             isRated = true;
  //             setState(() {});
  //           },
  //         ),
  //   );
  // }
  //
  late String token;

  //
  // submitRating(int courseId, double rating, String? comment) async {
  //   String url = "$mainIP/api/rateresource/$courseId";
  //   var response = await http.post(
  //     Uri.parse(url),
  //     headers: {
  //       'Authorization': "Bearer $token",
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'Accept': 'application/json',
  //     },
  //     body: json.encode({"rating": rating, "review": comment}),
  //   );
  //   if (response.statusCode == 200) {
  //     var responseBody = json.decode(response.body);
  //     print(responseBody);
  //   } else {
  //     print("fail");
  //   }
  // }

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
      await sharedPrefs.prefs.setString(
        cacheKey,
        jsonEncode(recentLessonsData),
      );
    } catch (e) {
      debugPrint("Error caching recent lessons: $e");
    }
  }

  Future<void> _cacheRecentLessonImage(
    int lessonId,
    Uint8List imageBytes,
  ) async {
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
      final APIurl =
          '$baseUrl/api/getcourselectures/${widget.CoursesData['id']}/recent';
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
      debugPrint("Recent Lessons API response: ${response.statusCode}");
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
          throw Exception(
            "Failed to load recent lessons: ${response.statusCode}",
          );
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
        showErrorSnackbar("Using cached data - $e");
      }
      debugPrint("Error fetching recent lessons: $e");
    }
  }

  Future<Uint8List?> getRecentLessonImage(dynamic lesson) async {
    final lessonId = lesson is Map ? lesson['id'] as int : lesson as int;
    final cachedImage = sharedPrefs.prefs.getString(
      'recent_lesson_image_$lessonId',
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
        throw Exception("Image fetch failed: ${response.statusCode}");
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
      await sharedPrefs.prefs.setString(
        cacheKey,
        jsonEncode(topRatedLessonsData),
      );
    } catch (e) {
      debugPrint("Error caching top rated lessons: $e");
    }
  }

  Future<void> _cacheTopRatedLessonImage(
    int lessonId,
    Uint8List imageBytes,
  ) async {
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
      final APIurl =
          '$baseUrl/api/getcourselectures/${widget.CoursesData['id']}/rated';
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
      debugPrint("Top Rated Lessons API response: ${response.statusCode}");
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
          throw Exception(
            "Failed to load top rated lessons: ${response.statusCode}",
          );
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
        showErrorSnackbar("Using cached data - $e");
      }
      debugPrint("Error fetching top rated lessons: $e");
    }
  }

  Future<Uint8List?> getTopRatedLessonImage(dynamic lesson) async {
    final lessonId = lesson is Map ? lesson['id'] as int : lesson as int;
    final cachedImage = sharedPrefs.prefs.getString(
      'top_rated_lesson_image_$lessonId',
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
        throw Exception("Image fetch failed: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for top rated lesson $lessonId");
      return null;
    } catch (e) {
      debugPrint("Error fetching top rated lesson image: $e");
      return null;
    }
  }

  late FavoriteController favoriteController;

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
    token = sharedPrefs.prefs.getString("token")!;
    widget.CoursesData["user_rating"] !=null  ? isRated = true: isRated= false;
    widget.CoursesData["user_rating"] !=null  ? userRating = widget.CoursesData["user_rating"] : userRating= 1;
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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return
    // MaterialApp(
    //   theme: themeController.initialTheme,
    //   locale: localeController.initialLang,
    //   debugShowCheckedModeBanner: false,
    //   home:
    Scaffold(
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
      // ),
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
                child: ListView(
                  scrollDirection: Axis.vertical,
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    Column(
                      children: [
                        Container(
                          height: Get.height / 2.4,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 210, 209, 224)
                                  : Color.fromARGB(255, 40, 41, 61),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(
                                      Icons.arrow_back_outlined,
                                      size: 35,
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
                                  Text(
                                    "Course".tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
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
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                    ),
                                  ),
                                  GetBuilder<FavoriteController>(
                                    builder: (controller) {
                                      final isFav =
                                          controller.isFavoriteC[widget
                                              .CoursesData["id"]
                                              .toString()] ??
                                          false;

                                      return LikeButton(
                                        size: 30,
                                        isLiked: isFav,
                                        likeBuilder: (bool isLiked) {
                                          return Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons
                                                    .favorite_border_outlined,
                                            color: Colors.red,
                                            size: 30,
                                          );
                                        },
                                        onTap: (bool isLiked) async {
                                          controller.toggleFavoriteC(
                                            widget.CoursesData["id"].toString(),
                                          );
                                          return !isLiked;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: Get.width,
                                height: Get.height / 2.86,
                                decoration: BoxDecoration(
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(60),
                                    topRight: Radius.circular(60),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.topCenter,
                                      child:
                                          widget.CoursesImage! != null
                                              ? Image.memory(
                                                widget.CoursesImage!,
                                                width: Get.width,
                                                height: Get.height * (1 / 4),
                                                fit: BoxFit.fill,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Image.asset(
                                                    ImageAssets.teacher,
                                                    // height: 125,
                                                    fit: BoxFit.fill,
                                                  );
                                                },
                                              )
                                              : Image.asset(
                                                ImageAssets.teacher,
                                                width: Get.width,
                                                height: Get.height * (1 / 4),
                                                fit: BoxFit.fill,
                                              ),
                                    ),
                                    Text(
                                      "${widget.CoursesData["name"]}".tr,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal,
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              "Video lessons".tr,
                                              style: TextStyle(
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
                                            Text(
                                              "${widget.CoursesData["video_lectures_count"]}"
                                                  .toString()
                                                  .tr,
                                              style: TextStyle(
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

                                        Column(
                                          children: [
                                            Text(
                                              "Price".tr,
                                              style: TextStyle(
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
                                            Text(
                                              "\$${widget.CoursesData["price"]}"
                                                  .toString()
                                                  .tr,
                                              style: TextStyle(
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
                                        Column(
                                          children: [
                                            Text(
                                              "PDF lessons".tr,
                                              style: TextStyle(
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
                                            Text(
                                              "${widget.CoursesData["pdf_lessons_count"]}"
                                                  .toString()
                                                  .tr,
                                              style: TextStyle(
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
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      style: BorderStyle.solid,
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
                                    right: BorderSide(
                                      style: BorderStyle.solid,
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
                                    bottom: BorderSide(
                                      style: BorderStyle.solid,
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
                                    top: BorderSide(
                                      style: BorderStyle.solid,
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
                                child: MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      ChosenScreen = "About";
                                    });
                                  },
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 210, 209, 224)
                                          : Color.fromARGB(255, 40, 41, 61),
                                  child: Text(
                                    "About",
                                    style: TextStyle(
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
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      style: BorderStyle.solid,
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
                                    right: BorderSide(
                                      style: BorderStyle.solid,
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
                                    bottom: BorderSide(
                                      style: BorderStyle.solid,
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
                                    top: BorderSide(
                                      style: BorderStyle.solid,
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
                                child: MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      ChosenScreen = "Lessons";
                                    });
                                  },
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 210, 209, 224)
                                          : Color.fromARGB(255, 40, 41, 61),
                                  child: Text(
                                    "Lessons",
                                    style: TextStyle(
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
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      style: BorderStyle.solid,
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
                                    right: BorderSide(
                                      style: BorderStyle.solid,
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
                                    bottom: BorderSide(
                                      style: BorderStyle.solid,
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
                                    top: BorderSide(
                                      style: BorderStyle.solid,
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
                                child: MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      ChosenScreen = "Reviews";
                                    });
                                  },
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 210, 209, 224)
                                          : Color.fromARGB(255, 40, 41, 61),
                                  child: Text(
                                    "Reviews",
                                    style: TextStyle(
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
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        ChosenScreen == "Reviews"
                            ? Column(
                              children: [
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 10,
                                    children: [
                                      SizedBox(width: 20),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              showRatingDailog(
                                                context,
                                                widget.CoursesData["id"],
                                                token,
                                                "$mainIP/api/ratecourse/${widget.CoursesData["id"]}",
                                                () {
                                                  setState(() {
                                                    isRated = true;
                                                  });
                                                },
                                                  userRating+0.0,
                                              );
                                            },
                                            icon: Icon(
                                              isRated ? Icons.star_outlined : Icons.star_border_outlined,
                                            ),
                                            color: Colors.blue,
                                            iconSize: 30,
                                          ),
                                          Text(
                                            isRated == true
                                                ? "Edit Rating".tr
                                                : "Rate This".tr,
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                      Icon(
                                        Icons.star_outlined,
                                        color: Colors.amber,
                                        size: 25,
                                      ),
                                      Text(
                                                "${widget.CoursesData["rating"].toString()}",
                                        style: TextStyle(
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
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),

                                          Text(
                                            "based on (${widget.CoursesData["ratings_count"].toString()}) reviews",
                                            style: TextStyle(
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
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: Get.height / 25),

                                Column(
                                  children: [
                                    buildRatingBar(5),
                                    SizedBox(height: 6),
                                    buildRatingBar(4),
                                    SizedBox(height: 6),
                                    buildRatingBar(3),
                                    SizedBox(height: 6),
                                    buildRatingBar(2),
                                    SizedBox(height: 6),
                                    buildRatingBar(1),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Container(
                                  height: 1,
                                  width: Get.width / 1.1,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 210, 209, 224),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(60),
                                    ),
                                  ),
                                ),

                                Container(
                                  height:
                                      Get.height *
                                      0.6, // 40% of screen height, adjust as needed
                                  child: ListView.builder(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount:
                                        widget
                                            .CoursesData["FeaturedRatings"]
                                            ?.length ??
                                        0,
                                    itemBuilder: (context, index) {
                                      final review =
                                          widget.CoursesData["FeaturedRatings"]?[index]
                                              as Map<String, dynamic>? ??
                                          {};
                                      return Container(
                                        width: Get.width / 1.1,
                                        child: StatefulBuilder(
                                          builder: (context, setState) {
                                            bool isExpanded = false;
                                            final reviewText =
                                                review["review"]
                                                    ?.toString()
                                                    .tr ??
                                                'No review'.tr;
                                            final textSpan = TextSpan(
                                              text: reviewText,
                                              style: TextStyle(
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
                                                fontSize: 12,
                                                fontWeight: FontWeight.w200,
                                              ),
                                            );
                                            final textPainter = TextPainter(
                                              text: textSpan,
                                              maxLines: 3,
                                              textDirection: TextDirection.ltr,
                                            );
                                            textPainter.layout(
                                              maxWidth: Get.width / 1.1,
                                            );
                                            final isLong =
                                                textPainter.didExceedMaxLines;
                                            return Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            review["user_name"]
                                                                    ?.toString()
                                                                    .tr ??
                                                                ''.tr,
                                                            style: TextStyle(
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
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .star_outlined,
                                                                color:
                                                                    Colors
                                                                        .amber,
                                                                size: 25,
                                                              ),
                                                              Text(
                                                                review["rating"]
                                                                        ?.toString()
                                                                        .tr ??
                                                                    'no rating'
                                                                        .tr,
                                                                style: TextStyle(
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
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        review["updated_at"]
                                                                ?.toString()
                                                                .tr ??
                                                            ''.tr,
                                                        style: TextStyle(
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
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w200,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      reviewText,
                                                      maxLines:
                                                          isExpanded ? null : 3,
                                                      overflow:
                                                          isExpanded
                                                              ? TextOverflow
                                                                  .visible
                                                              : TextOverflow
                                                                  .ellipsis,
                                                      style: TextStyle(
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
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w200,
                                                      ),
                                                    ),
                                                    if (isLong && !isExpanded)
                                                      TextButton(
                                                        onPressed:
                                                            () => setState(
                                                              () =>
                                                                  isExpanded =
                                                                      true,
                                                            ),
                                                        child: Text(
                                                          'Read more...',
                                                            ),
                                                        style:
                                                            TextButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                        ),
                                                      ),
                                                    if (isExpanded && isLong)
                                                      TextButton(
                                                        onPressed:
                                                            () => setState(
                                                              () =>
                                                                  isExpanded =
                                                                      false,
                                                            ),
                                                        child: Text(
                                                          'Show less',
                                                            ),
                                                        style:
                                                            TextButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                            ),
                                                        ),
                                                  ],
                                                      ),
                                                SizedBox(height: 10),
                                                    Container(
                                                      height: 1,
                                                      width: Get.width / 1.1,
                                                      decoration: BoxDecoration(
                                                        color: Color.fromARGB(
                                                          255,
                                                          210,
                                                          209,
                                                          224,
                                                        ),
                                                    shape: BoxShape.rectangle,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(60),
                                                            ),
                                                      ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                            : ChosenScreen == "Lessons"
                            ? SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(left: 5),
                                        child: Text(
                                          "Total Videos Duration".tr,
                                          style: TextStyle(
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
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 5, top: 10),
                                    child: Text(
                                      "${widget.CoursesData['duration_formatted_long']}"
                                          .tr,
                                      style: TextStyle(
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: Get.height / 25),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                      controller: scrollController,
                                      itemCount: coursesData.length,
                                      itemBuilder: (context, i) {
                                        int lectureId = coursesData[i]["id"];
                                        Uint8List? imageBytes =
                                            lecturesImages[lectureId];

                                        return InkWell(
                                          onTap: () async {
                                            await getSubscription(lectureId);

                                            if (isLectureSubscribed == true) {
                                              if (coursesData[i]['type'] == 0) {
                                                try {
                                                  final PDFurl =
                                                      coursesData[i]['urlpdf'];
                                                  // "http://www.pdf995.com/samples/pdf.pdf";
                                                final file = await loadNetwork(
                                                  PDFurl,
                                                );
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
                                                            (
                                                              context,
                                                            ) => VideoPlayer(
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
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                messageText: Text(
                                                  'Contact the support team for instructions on how to subscribe to the course/subject first.'
                                                      .tr,
                                                  style: TextStyle(
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
                                                isDismissible: true,
                                                snackPosition:
                                                    SnackPosition.BOTTOM,
                                                duration: const Duration(
                                                  seconds: 3,
                                                ),
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
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                              boxShadow: [
                                                BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Row(
                                                children: [
                                                  // Lesson Image
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      color: Colors.grey[300],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child:
                                                          imageBytes != null
                                                              ? Image.memory(
                                                                imageBytes,
                                                              fit: BoxFit.cover,
                                                                errorBuilder: (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) {
                                                                  return Image.asset(
                                                                    ImageAssets
                                                                        .lecture,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                  );
                                                                },
                                                              )
                                                              : Image.asset(
                                                                ImageAssets
                                                                    .lecture,
                                                              fit: BoxFit.cover,
                                                              ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  // Lesson Details
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Lesson Name
                                                        Text(
                                                          "${coursesData[i]["name"]}"
                                                              .tr,
                                                        // "hell",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        SizedBox(height: 4),
                                                        // Type and Duration/Slides
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                    vertical: 2,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    coursesData[i]['type'] ==
                                                                            0
                                                                        ? Colors
                                                                            .blue
                                                                        : Colors
                                                                            .red,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                coursesData[i]['type'] ==
                                                                        0
                                                                    ? "PDF".tr
                                                                  : "Video".tr,
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 8),
                                                            Icon(
                                                              coursesData[i]['type'] ==
                                                                      0
                                                                  ? Icons
                                                                      .description
                                                                  : Icons
                                                                      .play_circle_outline,
                                                              size: 14,
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
                                                            SizedBox(width: 4),
                                                            Text(
                                                              coursesData[i]['type'] ==
                                                                      0
                                                                ? "${coursesData[i]['pages']} slides"
                                                                // Static value for PDF
                                                                : "${coursesData[i]['formatted_duration']} min",
                                                            // Static value for Video
                                                              style: TextStyle(
                                                                fontSize: 12,
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
                                                        SizedBox(height: 4),
                                                        // Rating
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.star,
                                                            color: Colors.amber,
                                                              size: 14,
                                                            ),
                                                            SizedBox(width: 4),
                                                            Text(
                                                            "${coursesData[i]['rating']}"
                                                                  .tr, // Static rating
                                                              style: TextStyle(
                                                                fontSize: 12,
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
                                                      ],
                                                    ),
                                                  ),
                                                // rate this lessons
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () async {
                                                        showRatingDailog(
                                                          context,
                                                          coursesData[i]["id"],
                                                          token,
                                                          "$mainIP/api/ratelecture/${coursesData[i]["id"]}",
                                                              () {
                                                            setState(() {
                                                              ratedLessons[coursesData[i]["id"]] = true;
                                                            });
                                                          },
                                                          1.0
                                                        );
                                                        print("${coursesData[i]["id"]}");
                                                      },
                                                      icon: Icon(
                                                        ratedLessons[coursesData[i]["id"]] == true ? Icons.star_outlined : Icons.star_border_outlined,
                                                      ),
                                                      color: Colors.blue,
                                                      iconSize: 25,
                                                    ),
                                                    Text(
                                                      ratedLessons[coursesData[i]["id"]] == true
                                                          ? "Edit Rating".tr
                                                          : "Rate This".tr,
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(width: 10,),
                                                  // Quiz Button
                                                  Column(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        child: IconButton(
                                                          onPressed: () {
                                                           Get.to(QuizScreen(lessonId: coursesData[i]['id'] ));
                                                            // Quiz functionality - static for now
                                                          // Get.snackbar(
                                                          //   "Quiz".tr,
                                                          //   "Quiz feature coming soon!"
                                                          //       .tr,
                                                          //   snackPosition:
                                                          //       SnackPosition
                                                          //           .BOTTOM,
                                                          // );
                                                          },
                                                          icon: Icon(
                                                            Icons.quiz,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        "Quiz".tr,
                                                        style: TextStyle(
                                                          fontSize: 10,
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
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  SizedBox(height: Get.height / 25),
                                  Container(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Text(
                                      "Sources".tr,
                                      style: TextStyle(
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: List.generate(
                                      widget.CoursesData["sources"].length,
                                      (index) => TextButton(
                                        onPressed: () async {
                                          _launchURL(
                                            widget
                                                .CoursesData["sources"][index]["link"],
                                          );
                                        },
                                        child: Text(
                                          "${widget.CoursesData["sources"][index]["name"]}"
                                              .tr,
                                          style: TextStyle(
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
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
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
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                ],
                              ),
                            )
                            : Container(
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Text(
                                      "What Will You Learn".tr,
                                      style: TextStyle(
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 5, top: 10),
                                    child: Text(
                                      "${widget.CoursesData['description']}".tr,
                                      style: TextStyle(
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: Get.height / 25),
                                  Container(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Text(
                                      "Requirements".tr,
                                      style: TextStyle(
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 5, top: 10),
                                    child: Text(
                                      "${widget.CoursesData['requirements']}"
                                          .tr,
                                      style: TextStyle(
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: Get.height / 25),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 5),
                                      Text(
                                        "Subscriptions:".tr,
                                        style: TextStyle(
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      SizedBox(width: 10),
                                      Text(
                                        "${widget.CoursesData['subscriptions'].toString()}"
                                            .tr,
                                        style: TextStyle(
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: Get.height / 25),
                                  
                                  Container(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Text(
                                      "Available Languages".tr,
                                      style: TextStyle(
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  // Container(
                                  //   padding: EdgeInsets.only(left: 5, top: 10),
                                  //   child: Text(
                                  //     "${widget.CoursesData['languages']}".tr,
                                  //     style: TextStyle(
                                  //       color:
                                  //           themeController.initialTheme ==
                                  //                   Themes.customLightTheme
                                  //               ? Color.fromARGB(
                                  //                 255,
                                  //                 40,
                                  //                 41,
                                  //                 61,
                                  //               )
                                  //               : Color.fromARGB(
                                  //                 255,
                                  //                 210,
                                  //                 209,
                                  //                 224,
                                  //               ),
                                  //       fontSize: 16,
                                  //       fontWeight: FontWeight.w400,
                                  //     ),
                                  //   ),
                                  // ),
                                  SizedBox(height: Get.height / 25),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
    )
    // )
    ;
  }

  Widget buildRatingBar(int rating) {
    final ratingBreakdown = widget.CoursesData["rating_breakdown"] ?? {};
    final totalReviews =
        (int.tryParse(ratingBreakdown["5"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["4"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["3"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["2"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["1"].toString()) ?? 0);

    final count =
        int.tryParse(ratingBreakdown[rating.toString()].toString()) ?? 0;
    final percent = totalReviews > 0 ? count / totalReviews : 0.0;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              rating == 5
                  ? "Excellent".tr
                  : rating == 4
                  ? "Good".tr
                  : rating == 3
                  ? "Average".tr
                  : rating == 2
                  ? "Below Average".tr
                  : "Poor".tr,
              style: TextStyle(
                color:
                    themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 40, 41, 61)
                        : Color.fromARGB(255, 210, 209, 224),
                fontSize: 15,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 210, 209, 224),
                  borderRadius: BorderRadius.all(Radius.circular(60)),
                ),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percent,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              count.toString(),
              style: TextStyle(
                color:
                    themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 40, 41, 61)
                        : Color.fromARGB(255, 210, 209, 224),
                fontSize: 15,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
