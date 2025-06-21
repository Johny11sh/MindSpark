// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:learning_management_system/controller/FavoriteController.dart';
import 'package:learning_management_system/view/CoursesLessons.dart';
import 'package:learning_management_system/view/Favorites.dart';
import 'package:learning_management_system/view/SubjectTeachers.dart';
import 'package:like_button/like_button.dart';
import '../controller/NetworkController.dart';
import '../locale/LocaleController.dart';
import '../services/SharedPrefs.dart';
import '../core/constants/ImageAssets.dart';
import '../themes/ThemeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'LogIn.dart';
import 'NavBar.dart';
import '../themes/Themes.dart';
import '../core/classes/RecommendedCourses.dart';
import '../core/classes/RatedCourses.dart';

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

  List<Map<String, dynamic>> subjects = [];
  final Map<int, Uint8List> subjectsImages = {};
  List<Map<String, dynamic>> recommendedCourses = [];
  final Map<int, Uint8List> recommendedCoursesImages = {};
  List<Map<String, dynamic>> TopRatedCourses = [];
  final Map<int, Uint8List> TopRatedCoursesImages = {};
  bool isFavorite = false;
  bool isLiterary = false;
  String subjectType = 'scientific';
  int numberOfListItems = 0;

  List<bool> isSelected = [true, false];

  // Add new variables for caching
  List<Map<String, dynamic>> scientificSubjects = [];
  List<Map<String, dynamic>> literarySubjects = [];
  List<Map<String, dynamic>> cachedRecommendedCourses = [];
  List<Map<String, dynamic>> cachedTopRatedCourses = [];

  // Most Recent Courses
  List<Map<String, dynamic>> recentCourses = [];
  final Map<int, Uint8List> recentCoursesImages = {};
  List<Map<String, dynamic>> cachedRecentCourses = [];

  // Subscribed Courses
  List<Map<String, dynamic>> subscribedCourses = [];
  final Map<int, Uint8List> subscribedCoursesImages = {};
  List<Map<String, dynamic>> cachedSubscribedCourses = [];
  late FavoriteController favoriteController ;

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
    await _loadCachedData();
    await _loadCachedRecentCourses();
    await _loadCachedSubscribedCourses();

    // Then try to fetch fresh data if online
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getSubjectsData(subjectType);
      await getRecommendedCoursesData();
      await getTopRatedCoursesData();
      await getRecentCoursesData();
      await getSubscribedCoursesData();
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

      // Load recent courses data
      await _loadCachedRecentCourses();
      // Load subscribed courses data
      await _loadCachedSubscribedCourses();

      // Set initial subjects based on current subjectType
      setState(() {
        subjects =
            subjectType == 'scientific' ? scientificSubjects : literarySubjects;
      });

      // Load images for all subject types
      await Future.wait([
        _loadImagesForSubjects(scientificSubjects),
        _loadImagesForSubjects(literarySubjects),
        _loadRecommendedCoursesImages(),
        _loadTopRatedCoursesImages(),
        _loadRecentCoursesImages(),
        _loadSubscribedCoursesImages(),
      ]);
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  Future<void> _loadImagesForSubjects(
    List<Map<String, dynamic>> subjectList,
  ) async {
    for (var subject in subjectList) {
      final imageKey = 'subject_image_${subject['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          subjectsImages[subject['id']] = base64Decode(cachedImage);
        });
      }
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

  Future<void> _loadTopRatedCoursesImages() async {
    for (var course in TopRatedCourses) {
      final imageKey = 'top_rated_course_image_${course['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          TopRatedCoursesImages[course['id']] = base64Decode(cachedImage);
        });
      }
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

  Future<void> _cacheSubjectImage(int uniId, Uint8List imageBytes) async {
    try {
      await sharedPrefs.prefs.setString(
        'subject_image_$uniId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching subject image: $e");
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
          await _cacheSubjectsData();
        }

        // 6. Parallel Image Loading and caching
        await Future.wait(
          subjectsList.map((uni) async {
            final uniId = uni["id"] as int;
            final imageBytes = await getSubjectImage(uni);
            if (imageBytes != null && mounted) {
              setState(() {
                subjectsImages[uniId] = imageBytes;
              });
              await _cacheSubjectImage(uniId, imageBytes);
            }
          }),
        );
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

  Future<Uint8List?> getSubjectImage(dynamic subject) async {
    // First try to get from cache
    final uniId = subject is Map ? subject['id'] as int : subject as int;
    final cachedImage = sharedPrefs.prefs.getString('subject_image_$uniId');
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
      final url = '$baseUrl/api/getsubjectimage/$uniId';

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
        debugPrint("Subject image not found for ID: $uniId");
        return null;
      } else {
        throw Exception("Image fetch failed: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for subject $uniId");
      return null;
    } catch (e) {
      debugPrint("Error fetching subject image: $e");
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
            TopRatedCourses = List<Map<String, dynamic>>.from(
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
                TopRatedCoursesImages[courseId] = imageBytes;
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
        if (TopRatedCourses.isEmpty) {
          setState(() {
            TopRatedCourses = List.from(cachedTopRatedCourses);
          });
          if (TopRatedCourses.isEmpty) {
            throw Exception(
              "Failed to load top-rated courses: ${response.statusCode}",
            );
          }
        }
      }
    } on TimeoutException {
      if (TopRatedCourses.isEmpty) {
        setState(() {
          TopRatedCourses = List.from(cachedTopRatedCourses);
        });
        if (TopRatedCourses.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (TopRatedCourses.isEmpty) {
        setState(() {
          TopRatedCourses = List.from(cachedTopRatedCourses);
        });
        if (TopRatedCourses.isEmpty) {
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

  Future<void> _loadCachedRecentCourses() async {
    try {
      final cachedRecent = sharedPrefs.prefs.getString('cached_recent_courses');
      if (cachedRecent != null) {
        final List<dynamic> parsedRecentList = jsonDecode(cachedRecent);
        cachedRecentCourses = List<Map<String, dynamic>>.from(parsedRecentList);
        recentCourses = List.from(cachedRecentCourses);
      }
      await _loadRecentCoursesImages();
    } catch (e) {
      debugPrint("Error loading cached recent courses: $e");
    }
  }

  Future<void> _loadRecentCoursesImages() async {
    for (var course in recentCourses) {
      final imageKey = 'recent_course_image_${course['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          recentCoursesImages[course['id']] = base64Decode(cachedImage);
        });
      }
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
      final APIurl = '$baseUrl/api/getallcoursesrecent';

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
        final List<dynamic> recentCoursesList =
            responseBody is List
                ? responseBody
                : (responseBody['courses'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            recentCourses = List<Map<String, dynamic>>.from(recentCoursesList);
          });
          await _cacheRecentCourses();
        }

        await Future.wait(
          recentCoursesList.map((course) async {
            final courseId = course['id'] as int;
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
        if (recentCourses.isEmpty) {
          setState(() {
            recentCourses = List.from(cachedRecentCourses);
          });
          if (recentCourses.isEmpty) {
            throw Exception(
              "Failed to load recent courses: " +
                  response.statusCode.toString(),
            );
          }
        }
      }
    } on TimeoutException {
      if (recentCourses.isEmpty) {
        setState(() {
          recentCourses = List.from(cachedRecentCourses);
        });
        if (recentCourses.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (recentCourses.isEmpty) {
        setState(() {
          recentCourses = List.from(cachedRecentCourses);
        });
        if (recentCourses.isEmpty) {
          showErrorSnackbar("Failed to load recent courses");
        } else {
          showErrorSnackbar("Using cached data - " + e.toString());
        }
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

  Future<void> _loadCachedSubscribedCourses() async {
    try {
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
      await _loadSubscribedCoursesImages();
    } catch (e) {
      debugPrint("Error loading cached subscribed courses: $e");
    }
  }

  Future<void> _loadSubscribedCoursesImages() async {
    for (var course in subscribedCourses) {
      final imageKey = 'subscribed_course_image_${course['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          subscribedCoursesImages[course['id']] = base64Decode(cachedImage);
        });
      }
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

  Future<void> _cacheSubscribedCourseImage(
    int courseId,
    Uint8List imageBytes,
  ) async {
    try {
      await sharedPrefs.prefs.setString(
        'subscribed_course_image_$courseId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching subscribed course image: $e");
    }
  }

  Future<void> getSubscribedCoursesData() async {
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
      final APIurl = '$baseUrl/api/getallcoursessubscribed';

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
        final List<dynamic> subscribedCoursesList =
            responseBody is List
                ? responseBody
                : (responseBody['courses'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            subscribedCourses = List<Map<String, dynamic>>.from(
              subscribedCoursesList,
            );
          });
          await _cacheSubscribedCourses();
        }

        await Future.wait(
          subscribedCoursesList.map((course) async {
            final courseId = course['id'] as int;
            final imageBytes = await getSubscribedCourseImage(course);
            if (imageBytes != null && mounted) {
              setState(() {
                subscribedCoursesImages[courseId] = imageBytes;
              });
              await _cacheSubscribedCourseImage(courseId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (subscribedCourses.isEmpty) {
          setState(() {
            subscribedCourses = List.from(cachedSubscribedCourses);
          });
          if (subscribedCourses.isEmpty) {
            throw Exception(
              "Failed to load subscribed courses: " +
                  response.statusCode.toString(),
            );
          }
        }
      }
    } on TimeoutException {
      if (subscribedCourses.isEmpty) {
        setState(() {
          subscribedCourses = List.from(cachedSubscribedCourses);
        });
        if (subscribedCourses.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (subscribedCourses.isEmpty) {
        setState(() {
          subscribedCourses = List.from(cachedSubscribedCourses);
        });
        if (subscribedCourses.isEmpty) {
          showErrorSnackbar("Failed to load subscribed courses");
        } else {
          showErrorSnackbar("Using cached data - " + e.toString());
        }
      }
      debugPrint("Error fetching subscribed courses: $e");
    }
  }

  Future<Uint8List?> getSubscribedCourseImage(dynamic course) async {
    final courseId = course is Map ? course['id'] as int : course as int;
    final cachedImage = sharedPrefs.prefs.getString(
      'subscribed_course_image_$courseId',
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
        debugPrint("Subscribed course image not found for ID: $courseId");
        return null;
      } else {
        throw Exception(
          "Image fetch failed: " + response.statusCode.toString(),
        );
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for subscribed course $courseId");
      return null;
    } catch (e) {
      debugPrint("Error fetching subscribed course image: $e");
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
          actions: [
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SearchCustom(subjects, subjectsImages),
                );
              },
              icon: Icon(Icons.search_outlined),
            ),
          ],
        ),
        body:
            subjects.isEmpty
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
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 30),
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
                                  ? Color.fromARGB(255, 210, 209, 224)
                                  : Color.fromARGB(255, 40, 41, 61),
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
                                  isLiterary ? 'literary' : 'scientific';
                              subjects =
                                  subjectType == 'scientific'
                                      ? scientificSubjects
                                      : literarySubjects;
                            });
                            if (sharedPrefs.prefs.getBool('isConnected') ==
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
                                if (sharedPrefs.prefs.getBool('isConnected') ==
                                    true) {
                                  getSubjectsData(subjectType);
                                }
                              },
                              child: Text(
                                "Scientific".tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
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
                                              : Color.fromARGB(255, 40, 41, 61)
                                          : isSelected[0]
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
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
                                if (sharedPrefs.prefs.getBool('isConnected') ==
                                    true) {
                                  getSubjectsData(subjectType);
                                }
                              },
                              child: Text(
                                "Literary".tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? isSelected[1]
                                              ? Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              )
                                              : Color.fromARGB(255, 40, 41, 61)
                                          : isSelected[1]
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: Text(
                          "Subjects".tr,
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
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 200,
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
                            Uint8List? imageBytes = subjectsImages[uniId];

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
                              child: Card(
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child:
                                      // imageBytes != null
                                      //     ? Image.memory(
                                      //       imageBytes,
                                      //       fit: BoxFit.fill,
                                      //       errorBuilder: (
                                      //         context,
                                      //         error,
                                      //         stackTrace,
                                      //       ) {
                                      //         return Image.asset(
                                      //           ImageAssets.subject,
                                      //           height: 125,
                                      //           fit: BoxFit.cover,
                                      //         );
                                      //       },
                                      //     )
                                      //     : Image.asset(
                                      //       ImageAssets.subject,
                                      //     ),
                                      subjects[i]["image"] != null ?
                                      CachedNetworkImage(
                                        imageUrl:
                                            "$mainIP/${subjects[i]["image"]}",
                                      )    : Image.asset(
                                        ImageAssets.subject,
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "${subjects[i]["name"]}".tr,
                                        style: TextStyle(
                                          fontSize: 16,
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
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 30),
                      Center(
                        child: Text(
                          "Recommended Courses".tr,
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
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 200,
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
                                          (context) => RecommendedCourses(),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        child: Icon(
                                          Icons.arrow_circle_right_outlined,
                                          size: 40,
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
                                        "More".tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
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
                                    ],
                                  ),
                                ),
                              );
                            }

                            int uniId = recommendedCourses[i]["id"];
                            Uint8List? imageBytes =
                                recommendedCoursesImages[uniId];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CoursesLessons(
                                          CoursesData: recommendedCourses[i],
                                          index: i,
                                        ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: 10,
                                      top: 3,
                                      child:    GetBuilder<FavoriteController>(
                                        builder: (controller) {
                                          final isFav =
                                              controller.isFavoriteC[recommendedCourses[i]["id"]
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
                                                recommendedCourses[i]["id"].toString(),
                                              );
                                              return !isLiked;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child:
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
                                                          ImageAssets.subject,
                                                          height: 125,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    )
                                                    : Image.asset(
                                                      ImageAssets.subject,
                                                    ),
                                          ),
                                          SizedBox(height: 30),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              "${recommendedCourses[i]["name"]}".tr,
                                              style: TextStyle(
                                                fontSize: 16,
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
                      SizedBox(height: 30),
                      Center(
                        child: Text(
                          "Top Rated Courses".tr,
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
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 200,
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
                                          (context) => RatedCourses(
                                            // CourseData: TopRatedCourses[i]
                                          ),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        child: Icon(
                                          Icons.arrow_circle_right_outlined,
                                          size: 40,
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
                                        "More".tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
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
                                    ],
                                  ),
                                ),
                              );
                            }

                            int uniId = TopRatedCourses[i]["id"];
                            Uint8List? imageBytes =
                                TopRatedCoursesImages[uniId];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CoursesLessons(
                                          CoursesData: recommendedCourses[i],
                                          index: i,
                                        ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: 10,
                                      top: 3,
                                      child:    GetBuilder<FavoriteController>(
                                        builder: (controller) {
                                          final isFav =
                                              controller.isFavoriteC[TopRatedCourses[i]["id"]
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
                                                TopRatedCourses[i]["id"].toString(),
                                              );
                                              return !isLiked;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child:
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
                                                          ImageAssets.subject,
                                                          height: 125,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    )
                                                    : Image.asset(
                                                      ImageAssets.subject,
                                                    ),
                                          ),
                                          SizedBox(height: 30),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              "${TopRatedCourses[i]["name"]}".tr,
                                              style: TextStyle(
                                                fontSize: 16,
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
                      SizedBox(height: 30),
                      Center(
                        child: Text(
                          "Most Recent Courses".tr,
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
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 200,
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
                                  //   Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder:
                                  //         (context) => RatedCourses(
                                  //           // CourseData: TopRatedCourses[i]
                                  //         ),
                                  //   ),
                                  // );
                                },
                                child: Card(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        child: Icon(
                                          Icons.arrow_circle_right_outlined,
                                          size: 40,
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
                                        "More".tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
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
                                    ],
                                  ),
                                ),
                              );
                            }

                            int uniId = recentCourses[i]["id"];
                            Uint8List? imageBytes = recentCoursesImages[uniId];

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
                              child: Card(
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: 10,
                                      top: 3,
                                      child:    GetBuilder<FavoriteController>(
                                        builder: (controller) {
                                          final isFav =
                                              controller.isFavoriteC[recentCourses[i]["id"]
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
                                                recentCourses[i]["id"].toString(),
                                              );
                                              return !isLiked;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child:
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
                                                          ImageAssets.subject,
                                                          height: 125,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    )
                                                    : Image.asset(
                                                      ImageAssets.subject,
                                                    ),
                                          ),
                                          SizedBox(height: 30),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              "${recentCourses[i]["name"]}".tr,
                                              style: TextStyle(
                                                fontSize: 16,
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
                      SizedBox(height: 30),
                      Center(
                        child: Text(
                          "Subscribed Courses".tr,
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
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 200,
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
                                  //   Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder:
                                  //         (context) => RatedCourses(
                                  //           // CourseData: TopRatedCourses[i]
                                  //         ),
                                  //   ),
                                  // );
                                },
                                child: Card(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        child: Icon(
                                          Icons.arrow_circle_right_outlined,
                                          size: 40,
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
                                        "More".tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
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
                                    ],
                                  ),
                                ),
                              );
                            }

                            int uniId = subscribedCourses[i]["id"];
                            Uint8List? imageBytes =
                                subscribedCoursesImages[uniId];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CoursesLessons(
                                          CoursesData: subscribedCourses[i],
                                          index: i,
                                        ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: 10,
                                      top: 3,
                                      child:    GetBuilder<FavoriteController>(
                                        builder: (controller) {
                                          final isFav =
                                              controller.isFavoriteC[subscribedCourses[i]["id"]
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
                                                subscribedCourses[i]["id"].toString(),
                                              );
                                              return !isLiked;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child:
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
                                                          ImageAssets.subject,
                                                          height: 125,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    )
                                                    : Image.asset(
                                                      ImageAssets.subject,
                                                    ),
                                          ),
                                          SizedBox(height: 30),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              "${subscribedCourses[i]["name"]}".tr,
                                              style: TextStyle(
                                                fontSize: 16,
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
                      SizedBox(height: 30),
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
        Uint8List? imageBytes = elementsImages[elementsId];

        return InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        SubjectTeachers(SubjectData: sortedItems![index]),
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
                              ImageAssets.subject,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                        : Image.asset(
                          ImageAssets.subject,
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
        Uint8List? imageBytes = elementsImages[elementsId];

        return SizedBox(
          height: 100,
          child: Card(
            child: ListTile(
              leading:
                  imageBytes != null
                      ? Image.memory(
                        imageBytes,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            ImageAssets.subject,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                      : Image.asset(
                        ImageAssets.subject,
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
                        (context) =>
                            SubjectTeachers(SubjectData: sortedItems![index]),
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
