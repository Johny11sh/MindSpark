// ignore_for_file: file_names, must_be_immutable, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learning_management_system/view/CoursesLessons.dart';
import 'package:learning_management_system/view/NavBar.dart';
import '../../services/CacheManager.dart';
import '../../services/SharedPrefs.dart';
import '../../core/constants/ImageAssets.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../controller/NetworkController.dart';
import '../../locale/LocaleController.dart';
import '../../core/function/loadingLottie.dart';
import '../../view/LogIn.dart';
import '../constants/FontGlobals.dart';
import '../function/DynamicSearch.dart';
import '../function/noDataLottie.dart';

class Courses extends StatefulWidget {
  // List<Map<String, dynamic>> courses = [];
  // Map<int, Uint8List> CoursesImages = {};
  String title;
  Courses({
    super.key,
    // required this.courses,
    // required this.CoursesImages,
    required this.title,
  });

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  late SharedPrefs sharedPrefs;
  final ThemeController themeController = Get.find<ThemeController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final LocaleController localeController = Get.find<LocaleController>();

  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> cachedCourses = [];

  List<Map<String, dynamic>> recommendedCourses = [];
  List<Map<String, dynamic>> cachedRecommendedCourses = [];

  List<Map<String, dynamic>> topRatedCourses = [];
  List<Map<String, dynamic>> cachedTopRatedCourses = [];

  List<Map<String, dynamic>> recentCourses = [];
  List<Map<String, dynamic>> cachedRecentCourses = [];

  List<Map<String, dynamic>> mostSubscribedCourses = [];
  List<Map<String, dynamic>> cachedMostSubscribedCourses = [];

  List<Map<String, dynamic>> subscribedCourses = [];
  List<Map<String, dynamic>> cachedSubscribedCourses = [];
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
      networkController.onInit();
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
            courses = List.from(recommendedCourses);
          });
          await _cacheRecommendedCourses();
        }
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
          courses = List.from(recommendedCourses);
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
        courses = List.from(recommendedCourses);
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
        courses = List.from(recommendedCourses);
        if (recommendedCourses.isEmpty) {
          showErrorSnackbar("Failed to load recommended courses");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching recommended courses: $e");
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
            courses = List.from(topRatedCourses);
          });
          await _cacheTopRatedCourses();
        }
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
          courses = List.from(topRatedCourses);

          if (topRatedCourses.isEmpty) {
            throw Exception(
              "Failed to load top rated courses: ${response.statusCode}",
            );
          }
        }
      }
    } on TimeoutException {
      if (topRatedCourses.isEmpty) {
        setState(() {
          topRatedCourses = List.from(cachedTopRatedCourses);
        });
        courses = List.from(topRatedCourses);

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
        courses = List.from(topRatedCourses);

        if (topRatedCourses.isEmpty) {
          showErrorSnackbar("Failed to load top rated courses");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching top rated courses: $e");
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
      debugPrint("Error caching top rated courses: $e");
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
            courses = List.from(recentCourses);
          });
          await _cacheRecentCourses();
        }
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
          courses = List.from(recentCourses);

          if (recentCourses.isEmpty) {
            throw Exception(
              "Failed to load recent courses: ${response.statusCode}",
            );
          }
        }
      }
    } on TimeoutException {
      if (recentCourses.isEmpty) {
        setState(() {
          recentCourses = List.from(cachedRecentCourses);
        });
        courses = List.from(recentCourses);

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
        courses = List.from(recentCourses);

        if (recentCourses.isEmpty) {
          showErrorSnackbar("Failed to load recent courses");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching recent courses: $e");
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

  Future<void> getMostSubscribedCoursesData() async {
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
        final List<dynamic> mostSubscribedCoursesList =
            responseBody is List
                ? responseBody
                : (responseBody['courses'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            mostSubscribedCourses = List<Map<String, dynamic>>.from(
              mostSubscribedCoursesList,
            );
            courses = List.from(mostSubscribedCourses);
          });
          await _cacheMostSubscribedCourses();
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (mostSubscribedCourses.isEmpty) {
          setState(() {
            mostSubscribedCourses = List.from(cachedMostSubscribedCourses);
          });
          courses = List.from(mostSubscribedCourses);

          if (mostSubscribedCourses.isEmpty) {
            throw Exception(
              "Failed to load most subscribed courses: ${response.statusCode}",
            );
          }
        }
      }
    } on TimeoutException {
      if (mostSubscribedCourses.isEmpty) {
        setState(() {
          mostSubscribedCourses = List.from(cachedMostSubscribedCourses);
        });
        courses = List.from(mostSubscribedCourses);

        if (mostSubscribedCourses.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (mostSubscribedCourses.isEmpty) {
        setState(() {
          mostSubscribedCourses = List.from(cachedMostSubscribedCourses);
        });
        courses = List.from(mostSubscribedCourses);

        if (mostSubscribedCourses.isEmpty) {
          showErrorSnackbar("Failed to load most subscribed courses");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching most subscribed courses: $e");
    }
  }

  Future<void> _cacheMostSubscribedCourses() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_most_subscribed_courses',
        jsonEncode(mostSubscribedCourses),
      );
      cachedMostSubscribedCourses = List.from(mostSubscribedCourses);
    } catch (e) {
      debugPrint("Error caching most subscribed courses: $e");
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
      final APIurl = '$baseUrl/api/getallcoursesusersubscribed';

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

            courses = List.from(subscribedCourses);
          });
          await _cacheSubscribedCourses();
        }
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
          courses = List.from(subscribedCourses);

          if (subscribedCourses.isEmpty) {
            throw Exception(
              "Failed to load subscribed courses: ${response.statusCode}",
            );
          }
        }
      }
    } on TimeoutException {
      if (subscribedCourses.isEmpty) {
        setState(() {
          subscribedCourses = List.from(cachedSubscribedCourses);
        });
        courses = List.from(subscribedCourses);

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
        courses = List.from(subscribedCourses);

        if (subscribedCourses.isEmpty) {
          showErrorSnackbar("Failed to load subscribed courses");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching subscribed courses: $e");
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

  Future<void> _loadInitialData() async {
    // await _cacheCourses();
    await _loadCachedData();
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      if (widget.title == "Recommended Courses".tr) {
        await getRecommendedCoursesData();
        courses = List.from(recommendedCourses);
      } else if (widget.title == "Top Rated Courses".tr) {
        await getTopRatedCoursesData();
        courses = List.from(topRatedCourses);
      } else if (widget.title == "Recent Courses".tr) {
        await getRecentCoursesData();
        courses = List.from(recentCourses);
      } else if (widget.title == "Most Subscribed Courses".tr) {
        await getMostSubscribedCoursesData();
        courses = List.from(mostSubscribedCourses);
      } else if (widget.title == "My Courses".tr) {
        await getSubscribedCoursesData();
        courses = List.from(subscribedCourses);
      }
      // await getCoursesData();
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load  courses data
      final cachedRecommendedCourses = sharedPrefs.prefs.getString(
        'cached_recommended_courses',
      );
      if (cachedRecommendedCourses != null) {
        final List<dynamic> parsedRecommendedList = jsonDecode(
          cachedRecommendedCourses,
        );
        cachedCourses = List<Map<String, dynamic>>.from(parsedRecommendedList);
        courses = List.from(cachedCourses);
      }
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
    try {
      // Load  courses data
      final cachedTopRatedCourses = sharedPrefs.prefs.getString(
        'cached_top_rated_courses',
      );
      if (cachedTopRatedCourses != null) {
        final List<dynamic> parsedTopRatedList = jsonDecode(
          cachedTopRatedCourses,
        );
        cachedCourses = List<Map<String, dynamic>>.from(parsedTopRatedList);
        courses = List.from(cachedCourses);
      }
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
    try {
      // Load  courses data
      final cachedRecentCourses = sharedPrefs.prefs.getString(
        'cached_recent_courses',
      );
      if (cachedRecentCourses != null) {
        final List<dynamic> parsedRecentList = jsonDecode(cachedRecentCourses);
        cachedCourses = List<Map<String, dynamic>>.from(parsedRecentList);
        courses = List.from(cachedCourses);
      }
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
    try {
      // Load  courses data
      final cachedMostSubscribed = sharedPrefs.prefs.getString(
        'cached_most_subscribed_courses',
      );
      if (cachedMostSubscribed != null) {
        final List<dynamic> parsedMostSubscribedList = jsonDecode(
          cachedMostSubscribed,
        );
        cachedCourses = List<Map<String, dynamic>>.from(
          parsedMostSubscribedList,
        );
        courses = List.from(cachedCourses);
      }
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
    try {
      // Load  courses data
      final cachedSubscribed = sharedPrefs.prefs.getString(
        'cached_subscribed_courses',
      );
      if (cachedSubscribed != null) {
        final List<dynamic> parsedSubscribedList = jsonDecode(cachedSubscribed);
        cachedCourses = List<Map<String, dynamic>>.from(parsedSubscribedList);
        courses = List.from(cachedCourses);
      }
    } catch (e) {
      debugPrint("Error loading cached data: $e");
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
            courses.isEmpty
                ? loadingLottie()
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
                    // await getRecommendedCoursesData();
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
                          height: 120,
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
                                          widget.title.tr,
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
                                            elements: courses,
                                            // elementsImages: subjectBooksImages,
                                            searchType: 'courses',
                                            subjectName: widget.title,
                                            onItemTap: (course) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => CoursesLessons(
                                                        index: courses.indexOf(
                                                          course,
                                                        ),
                                                        CoursesData: course,
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
                                (courses.isEmpty)
                                    ? noDataLottie("No data available")
                                    : Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Text(
                                          "Choose a Course".tr,
                                          style: TextStyle(
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
                                            fontFamily: globalFontFamily,
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
                                          child: ListView.builder(
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            itemCount: courses.length,
                                            itemBuilder: (context, i) {
                                              try {
                                                final course = courses[i];
                                                final courseName =
                                                    course["name"]
                                                        ?.toString() ??
                                                    "Unknown Course";
                                                final instructor =
                                                    course["instructor"]
                                                        ?.toString();
                                                return Center(
                                                  child: Container(
                                                        width:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.9,
                                                        margin:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => CoursesLessons(
                                                                      CoursesData:
                                                                          course,
                                                                      index: i,
                                                                    ),
                                                              ),
                                                            );
                                                          },
                                                          child: Card(
                                                            elevation: 4,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    15,
                                                                  ),
                                                            ),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    16,
                                                                  ),
                                                              child: Row(
                                                                children: [
                                                                  // Image Section
                                                                  Container(
                                                                    width: 60,
                                                                    height: 60,
                                                                    decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            10,
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
                                                                        width:
                                                                            1,
                                                                      ),
                                                                    ),
                                                                    child: ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            9,
                                                                          ),
                                                                      child:
                                                                          course['image'] !=
                                                                                  null
                                                                              ? CachedNetworkImage(
                                                                                imageUrl:
                                                                                    "$mainIP/${course['image']}",
                                                                                height:
                                                                                    60,
                                                                                width:
                                                                                    60,
                                                                              )
                                                                              : Image.asset(
                                                                                ImageAssets.book,
                                                                                fit:
                                                                                    BoxFit.cover,
                                                                              ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 16,
                                                                  ),
                                                                  // Content Section
                                                                  Expanded(
                                                                    child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          courseName
                                                                              .tr,
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                globalFontFamily,
                                                                            fontSize:
                                                                                globalFontSizeChange >=
                                                                                        17
                                                                                    ? (globalFontSizeChange /
                                                                                            5) +
                                                                                        16
                                                                                    : 16 -
                                                                                        (globalFontSizeChange /
                                                                                            5),
                                                                            fontWeight:
                                                                                FontWeight.w600,
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
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              4,
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.star_outlined,
                                                                              size:
                                                                                  14,
                                                                              color:
                                                                                  Colors.amber,
                                                                            ),
                                                                            const SizedBox(
                                                                              width:
                                                                                  4,
                                                                            ),
                                                                            Text(
                                                                              course['rating'].toString(),
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    globalFontSizeChange >=
                                                                                            17
                                                                                        ? (globalFontSizeChange /
                                                                                                5) +
                                                                                            12
                                                                                        : 12 -
                                                                                            (globalFontSizeChange /
                                                                                                5),
                                                                                fontFamily:
                                                                                    globalFontFamily,
                                                                                color:
                                                                                    Colors.amber,
                                                                                fontWeight:
                                                                                    FontWeight.w500,
                                                                              ),
                                                                            ).animate().fadeIn(
                                                                              delay:
                                                                                  100.ms,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .animate(
                                                        delay: (i * 100).ms,
                                                      )
                                                      .fadeIn(duration: 400.ms)
                                                      .slideX(
                                                        begin: 0.5,
                                                        end: 0,
                                                        curve:
                                                            Curves.easeOutBack,
                                                        duration: 300.ms,
                                                      )
                                                      .scaleXY(
                                                        begin: 0.8,
                                                        end: 1,
                                                        duration: 400.ms,
                                                        curve:
                                                            Curves.elasticOut,
                                                      ),
                                                );
                                              } catch (e) {
                                                debugPrint(
                                                  "Error rendering course at index $i: $e",
                                                );
                                                return Container(
                                                  margin: const EdgeInsets.all(
                                                    8,
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
      ),
    );
  }
}
