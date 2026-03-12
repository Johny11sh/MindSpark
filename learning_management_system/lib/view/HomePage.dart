// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:learning_management_system/controller/BackButtonController.dart';
// import 'package:learning_management_system/controller/WatchlistController.dart';
import 'package:learning_management_system/core/classes/PdfCard.dart';
import 'package:learning_management_system/core/classes/SubjectsBooks.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';
import '../controller/FontController.dart';
import '../controller/ProfileController.dart';
import '../core/classes/Courses.dart';
import '../core/constants/FontGlobals.dart';
import '../core/function/noDataLottie.dart';
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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  late SharedPrefs sharedPrefs;
  late AnimationController _toggleAnimationController;

  final ThemeController themeController = Get.find<ThemeController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final FontController fontController = Get.find<FontController>();
  late BackButtonController controller = Get.put(BackButtonController());

  // final ProfileController profileController = Get.put(ProfileController());

  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> recommendedCourses = [];
  List<Map<String, dynamic>> TopRatedCourses = [];
  bool isFavorite = false;
  bool isLiterary = false;
  String subjectType = 'scientific';
  int numberOfListItems = 0;

  int hasWarning = 0;
  int isBanned = 0;
  int warningCount = 0;
  String? warningMessage = '';

  List<bool> isSelected = [true, false];

  List<Map<String, dynamic>> scientificSubjects = [];
  List<Map<String, dynamic>> literarySubjects = [];
  List<Map<String, dynamic>> cachedRecommendedCourses = [];
  List<Map<String, dynamic>> cachedTopRatedCourses = [];

  List<Map<String, dynamic>> recentCourses = [];
  List<Map<String, dynamic>> cachedRecentCourses = [];

  List<Map<String, dynamic>> subscribedCourses = [];
  List<Map<String, dynamic>> cachedSubscribedCourses = [];

  List<Map<String, dynamic>> myCourses = [];
  List<Map<String, dynamic>> cachedMyCourses = [];

  List<Map<String, dynamic>> userInfo = [];

  late FavoriteController favoriteController;
  // late WatchlistController watchlistController;
  final CacheManager cacheManager = CacheManager();

  late String token;

  @override
  void initState() {
    super.initState();
    _toggleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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
    token = sharedPrefs.prefs.getString("token")!;

    favoriteController = Get.put(FavoriteController());

    // watchlistController = Get.put(WatchlistController());
  }

  void showWarningDialog() {
    if (hasWarning == 1) {
      print("warned");
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Warning"),
            titleTextStyle: TextStyle(
              fontFamily: globalFontFamily,
              color: Color.fromARGB(255, 40, 41, 61),
              fontWeight: FontWeight.w400,
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 20
                      : 20 - (globalFontSizeChange / 5),
            ),
            content: Text(
              'You have been warned $warningCount times.Your latest violation was incurred by the following comment:\n$warningMessage\nBe wary that too many warnings and violations of our terms may result a full ban on you account.'
                  .tr,
            ),
            contentTextStyle: TextStyle(
              fontFamily: globalFontFamily,
              color: Color.fromARGB(255, 40, 41, 61),
              fontWeight: FontWeight.w300,
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 16
                      : 16 - (globalFontSizeChange / 5),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  SeeWarning();
                  Get.back();
                },
                child: Text(
                  'OK',
                  style: TextStyle(fontFamily: globalFontFamily),
                ),
              ),
            ],
          );
        },
      );
    }
    if (isBanned == 1) {
      if (isBanned == 1) {
        controller.ban = true;
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: controller.onWillPop,
            child: AlertDialog(
              title: Text("Banned"),
              titleTextStyle: TextStyle(
                fontFamily: globalFontFamily,
                color: Color.fromARGB(255, 40, 41, 61),
                fontWeight: FontWeight.w400,
                fontSize:
                    globalFontSizeChange <= 17
                        ? (globalFontSizeChange / 5) + 20
                        : 20 - (globalFontSizeChange / 5),
              ),
              content: Text(
                'Your account has been banned due to multiple violations of our terms.\nPlease contact one of our admins in order to get your account reinstated.\nIf we already told you we removed the ban, please try logging in again later'
                    .tr,
              ),
              contentTextStyle: TextStyle(
                fontFamily: globalFontFamily,
                color: Color.fromARGB(255, 40, 41, 61),
                fontWeight: FontWeight.w300,
                fontSize:
                    globalFontSizeChange <= 17
                        ? (globalFontSizeChange / 5) + 16
                        : 16 - (globalFontSizeChange / 5),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    Get.offAll(() => LogIn());
                    sharedPrefs.prefs.clear();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(fontFamily: globalFontFamily),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getSubjectsData(subjectType);
      await getCoursesData();
      showWarningDialog();
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
        style: TextStyle(fontFamily: globalFontFamily),
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

        final List<dynamic> MyCoursesList =
            responseBody is List
                ? responseBody
                : (responseBody['user_subscribed'] ?? [responseBody]);

        final List<dynamic> userList =
            responseBody is List
                ? responseBody
                : (responseBody['user'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            userInfo = List<Map<String, dynamic>>.from(userList);
            var data = userInfo[0];
            isBanned = data['isBanned'];
            hasWarning = data['hasWarning'];
            warningCount = data['counter'];
            warningMessage = data['comment'];

            print(userInfo[0]);

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
            myCourses = List<Map<String, dynamic>>.from(MyCoursesList);
          });

          if (cacheManager.isCacheEnabled.value == true) {
            await _cacheRecommendedCourses();
            await _cacheTopRatedCourses();
            await _cacheRecentCourses();
            await _cacheSubscribedCourses();
            await _cacheMyCourses();
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
            subscribedCourses.isEmpty ||
            myCourses.isEmpty) {
          setState(() {
            recommendedCourses = List.from(cachedRecommendedCourses);
            TopRatedCourses = List.from(cachedTopRatedCourses);
            recentCourses = List.from(cachedRecentCourses);
            subscribedCourses = List.from(cachedSubscribedCourses);
            myCourses = List.from(cachedMyCourses);
          });
          if (recommendedCourses.isEmpty ||
              TopRatedCourses.isEmpty ||
              recentCourses.isEmpty ||
              subscribedCourses.isEmpty ||
              myCourses.isEmpty) {
            throw Exception("Failed to load courses: ${response.statusCode}");
          }
        }
      }
    } on TimeoutException {
      if (recommendedCourses.isEmpty ||
          TopRatedCourses.isEmpty ||
          recentCourses.isEmpty ||
          subscribedCourses.isEmpty ||
          myCourses.isEmpty) {
        setState(() {
          recommendedCourses = List.from(cachedRecommendedCourses);
          TopRatedCourses = List.from(cachedTopRatedCourses);
          recentCourses = List.from(cachedRecentCourses);
          subscribedCourses = List.from(cachedSubscribedCourses);
          myCourses = List.from(cachedMyCourses);
        });
        if (recommendedCourses.isEmpty ||
            TopRatedCourses.isEmpty ||
            recentCourses.isEmpty ||
            subscribedCourses.isEmpty ||
            myCourses.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (recommendedCourses.isEmpty ||
          TopRatedCourses.isEmpty ||
          recentCourses.isEmpty ||
          subscribedCourses.isEmpty ||
          myCourses.isEmpty) {
        setState(() {
          recommendedCourses = List.from(cachedRecommendedCourses);
          TopRatedCourses = List.from(cachedTopRatedCourses);
          recentCourses = List.from(cachedRecentCourses);
          subscribedCourses = List.from(cachedSubscribedCourses);
          myCourses = List.from(cachedMyCourses);
        });
        if (recommendedCourses.isEmpty ||
            TopRatedCourses.isEmpty ||
            recentCourses.isEmpty ||
            subscribedCourses.isEmpty ||
            myCourses.isEmpty) {
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

  Future<void> _cacheMyCourses() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_my_courses',
        jsonEncode(myCourses),
      );
      cachedMyCourses = List.from(myCourses);
    } catch (e) {
      debugPrint("Error caching My courses: $e");
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

      final cachedMYCourses = sharedPrefs.prefs.getString('cached_my_courses');
      if (cachedMYCourses != null) {
        final List<dynamic> parsedMYCoursesList = jsonDecode(cachedMYCourses);
        cachedMyCourses = List<Map<String, dynamic>>.from(parsedMYCoursesList);
        myCourses = List.from(cachedMyCourses);
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

  Future<void> SeeWarning() async {
    print("has been warned jeez");
    final url = Uri.parse('$mainIP/api/seewarning');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final List<dynamic> userList =
          responseBody is List
              ? responseBody
              : (responseBody['user'] ?? [responseBody]);

      if (mounted) {
        setState(() {
          userInfo = List<Map<String, dynamic>>.from(userList);
          var data = userInfo[0];
          isBanned = data['isBanned'];
          hasWarning = data['hasWarning'];
          warningCount = data['counter'];
          warningMessage = data['comment'];

          print(userInfo[0]);
        });
      }

      print('warning has been seen');
    } else {
      print('Error : ${response.body}');
    }
  }

  @override
  void dispose() {
    _toggleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isBanned == 1) {
      controller.ban = true;
    }
    return WillPopScope(
      onWillPop: controller.onWillPop,

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
                : subjects.isEmpty
                ? RefreshIndicator(
                  color:
                      themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 40, 41, 61)
                          : Color.fromARGB(255, 210, 209, 224),
                  backgroundColor:
                      themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 210, 209, 224)
                          : Color.fromARGB(255, 46, 48, 97),
                  onRefresh: () async {
                    setState(() {
                      cacheManager.init();
                      networkController.init();
                    });
                    await networkController.checkConnectivityManually();

                    print('caching: ${cacheManager.isCacheEnabled.value}');
                    print(
                      'connection: ${sharedPrefs.prefs.getBool('isConnected')}',
                    );
                    setState(() {});
                    if (sharedPrefs.prefs.getBool('isConnected') == true) {
                      await _loadInitialData();
                    } else {
                      if (cacheManager.isCacheEnabled.value == true) {
                        await _loadCachedData();
                        setState(() {});
                      }
                    }
                  },
                  child: Center(
                    child: CircularProgressIndicator(
                      color:
                          themeController.initialTheme ==
                                  Themes.customLightTheme
                              ? Color.fromARGB(255, 40, 41, 61)
                              : Color.fromARGB(255, 210, 209, 224),
                    ),
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
                    setState(() {
                      cacheManager.init();
                      networkController.init();
                    });
                    await networkController.checkConnectivityManually();

                    print('caching: ${cacheManager.isCacheEnabled.value}');
                    print(
                      'connection: ${sharedPrefs.prefs.getBool('isConnected')}',
                    );
                    setState(() {});
                    if (sharedPrefs.prefs.getBool('isConnected') == true) {
                      await _loadInitialData();
                    } else {
                      if (cacheManager.isCacheEnabled.value == true) {
                        await _loadCachedData();
                        setState(() {});
                      }
                    }
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
                                            elements: subjects,
                                            // elementsImages: subjectsImages,
                                            searchType: 'subjects',
                                            onItemTap: (subject) {
                                              if (isSelected[0]) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            SubjectTeachers(
                                                              SubjectData:
                                                                  subject,
                                                            ),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => SubjectsBooks(
                                                          subjectId:
                                                              subject['id'],
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
                                    ).animate().rotate(
                                      begin: -0.2,
                                      end: 0,
                                      duration: 500.ms,
                                      curve: Curves.elasticOut,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .slideX(begin: 0.5),
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
                            child:
                                (subjects.isEmpty &&
                                        recommendedCourses.isEmpty &&
                                        TopRatedCourses.isEmpty &&
                                        myCourses.isEmpty &&
                                        subscribedCourses.isEmpty &&
                                        recentCourses.isEmpty)
                                    ? noDataLottie("No data available")
                                    : ListView(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      children: [
                                        const SizedBox(height: 20),
                                        Center(
                                          child: Text(
                                            "My Courses".tr,
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
                                              fontFamily: globalFontFamily,
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
                                        const SizedBox(height: 30),
                                        SizedBox(
                                          height: 200,
                                          child: GridView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 1,
                                                ),
                                            controller: scrollController,
                                            itemCount: myCourses.length + 1,
                                            itemBuilder: (context, i) {
                                              if (i == myCourses.length) {
                                                return InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => Courses(
                                                              // courses: myCourses,
                                                              title:
                                                                  "My Courses",
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Card(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
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
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                globalFontFamily,
                                                            fontSize:
                                                                globalFontSizeChange <=
                                                                        17
                                                                    ? (globalFontSizeChange /
                                                                            5) +
                                                                        18
                                                                    : 18 -
                                                                        (globalFontSizeChange /
                                                                            5),
                                                            fontWeight:
                                                                FontWeight.w400,
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
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }

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
                                                                myCourses[i],
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
                                                  padding: const EdgeInsets.all(
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
                                                            myCourses[i]["rating"] !=
                                                                    null
                                                                ? Container(
                                                                  height: 23,
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
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
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .star,
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
                                                                        // "${myCourses[i]["rating"]}",
                                                                        double.parse(
                                                                          myCourses[i]["rating"]
                                                                              .toString(),
                                                                        ).toStringAsFixed(
                                                                          1,
                                                                        ),
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              globalFontFamily,
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
                                                                          color: Color.fromARGB(
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
                                                              builder: (
                                                                controller,
                                                              ) {
                                                                final isFav =
                                                                    controller
                                                                        .isFavoriteC[myCourses[i]["id"]
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
                                                                      myCourses[i]["id"]
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
                                                            myCourses[i]['image'] !=
                                                                    null
                                                                ? CachedNetworkImage(
                                                                  imageUrl:
                                                                      "$mainIP/${myCourses[i]["image"]}",
                                                                  height: 90,
                                                                  width: 90,
                                                                )
                                                                // ? Image.network(
                                                                //   myCourses[i]['image'],
                                                                //   height: 90,
                                                                //   width: 90,
                                                                // )
                                                                : Image.asset(
                                                                  ImageAssets
                                                                      .subject,
                                                                ),

                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                "${myCourses[i]["name"]}"
                                                                    .tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
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
                                                                      FontWeight
                                                                          .w500,
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
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            borderColor:
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
                                            selectedBorderColor:
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
                                            fillColor:
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
                                            selectedColor:
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
                                            onPressed: (int newIndex) {
                                              setState(() {
                                                for (
                                                  int index = 0;
                                                  index < isSelected.length;
                                                  index++
                                                ) {
                                                  isSelected[index] =
                                                      index == newIndex;
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
                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 420,
                                                ),
                                                curve: Curves.easeInOut,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(22),
                                                  color:
                                                      isSelected[0]
                                                          ? (themeController
                                                                      .initialTheme ==
                                                                  Themes
                                                                      .customLightTheme
                                                              ? const Color.fromARGB(
                                                                255,
                                                                40,
                                                                41,
                                                                61,
                                                              )
                                                              : const Color.fromARGB(
                                                                255,
                                                                210,
                                                                209,
                                                                224,
                                                              ))
                                                          : Colors.transparent,
                                                  boxShadow:
                                                      isSelected[0]
                                                          ? [
                                                            BoxShadow(
                                                              color:
                                                                  themeController
                                                                              .initialTheme ==
                                                                          Themes
                                                                              .customLightTheme
                                                                      ? const Color.fromARGB(
                                                                        100,
                                                                        40,
                                                                        41,
                                                                        61,
                                                                      )
                                                                      : const Color.fromARGB(
                                                                        100,
                                                                        210,
                                                                        209,
                                                                        224,
                                                                      ),
                                                              blurRadius: 20,
                                                              spreadRadius: 3,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    2,
                                                                  ),
                                                            ),
                                                          ]
                                                          : [],
                                                ),
                                                child: ScaleTransition(
                                                  scale:
                                                      isSelected[0]
                                                          ? Tween(
                                                            begin: 0.9,
                                                            end: 1.2,
                                                          ).animate(
                                                            CurvedAnimation(
                                                              parent:
                                                                  _toggleAnimationController,
                                                              curve:
                                                                  Curves
                                                                      .bounceInOut,
                                                            ),
                                                          )
                                                          : const AlwaysStoppedAnimation(
                                                            1.0,
                                                          ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        isSelected[0] = true;
                                                        isSelected[1] = false;
                                                        isLiterary = false;
                                                        subjectType =
                                                            "scientific";
                                                        subjects =
                                                            scientificSubjects;
                                                      });
                                                      _toggleAnimationController
                                                          .forward()
                                                          .then((_) {
                                                            _toggleAnimationController
                                                                .reverse();
                                                          });
                                                      if (sharedPrefs.prefs
                                                              .getBool(
                                                                'isConnected',
                                                              ) ==
                                                          true) {
                                                        getSubjectsData(
                                                          subjectType,
                                                        );
                                                      }
                                                    },
                                                    child: Text(
                                                      "Scientific".tr,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            globalFontFamily,
                                                        fontSize:
                                                            globalFontSizeChange <=
                                                                    17
                                                                ? (globalFontSizeChange /
                                                                        5) +
                                                                    18
                                                                : 18 -
                                                                    (globalFontSizeChange /
                                                                        5),
                                                        color:
                                                            themeController
                                                                        .initialTheme ==
                                                                    Themes
                                                                        .customLightTheme
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
                                                ),
                                              ),
                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeInOut,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(22),
                                                  color:
                                                      isSelected[1]
                                                          ? (themeController
                                                                      .initialTheme ==
                                                                  Themes
                                                                      .customLightTheme
                                                              ? const Color.fromARGB(
                                                                255,
                                                                40,
                                                                41,
                                                                61,
                                                              )
                                                              : const Color.fromARGB(
                                                                255,
                                                                210,
                                                                209,
                                                                224,
                                                              ))
                                                          : Colors.transparent,
                                                  boxShadow:
                                                      isSelected[1]
                                                          ? [
                                                            BoxShadow(
                                                              color:
                                                                  themeController
                                                                              .initialTheme ==
                                                                          Themes
                                                                              .customLightTheme
                                                                      ? const Color.fromARGB(
                                                                        100,
                                                                        40,
                                                                        41,
                                                                        61,
                                                                      )
                                                                      : const Color.fromARGB(
                                                                        100,
                                                                        210,
                                                                        209,
                                                                        224,
                                                                      ),
                                                              blurRadius: 10,
                                                              spreadRadius: 2,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    2,
                                                                  ),
                                                            ),
                                                          ]
                                                          : [],
                                                ),
                                                child: ScaleTransition(
                                                  scale:
                                                      isSelected[1]
                                                          ? Tween(
                                                            begin: 0.9,
                                                            end: 1.2,
                                                          ).animate(
                                                            CurvedAnimation(
                                                              parent:
                                                                  _toggleAnimationController,
                                                              curve:
                                                                  Curves
                                                                      .bounceInOut,
                                                            ),
                                                          )
                                                          : const AlwaysStoppedAnimation(
                                                            1.0,
                                                          ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        isSelected[1] = true;
                                                        isSelected[0] = false;
                                                        isLiterary = true;
                                                        subjectType =
                                                            "literary";
                                                        subjects =
                                                            literarySubjects;
                                                      });
                                                      _toggleAnimationController
                                                          .forward()
                                                          .then((_) {
                                                            _toggleAnimationController
                                                                .reverse();
                                                          });
                                                      if (sharedPrefs.prefs
                                                              .getBool(
                                                                'isConnected',
                                                              ) ==
                                                          true) {
                                                        getSubjectsData(
                                                          subjectType,
                                                        );
                                                      }
                                                    },
                                                    child: Text(
                                                      "Literary".tr,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            globalFontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize:
                                                            globalFontSizeChange <=
                                                                    17
                                                                ? (globalFontSizeChange /
                                                                        5) +
                                                                    18
                                                                : 18 -
                                                                    (globalFontSizeChange /
                                                                        5),
                                                        color:
                                                            themeController
                                                                        .initialTheme ==
                                                                    Themes
                                                                        .customLightTheme
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
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 120,
                                          child: GridView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 1,
                                                ),
                                            controller: scrollController,
                                            itemCount: subjects.length,
                                            itemBuilder: (context, i) {
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              SubjectTeachers(
                                                                SubjectData:
                                                                    subjects[i],
                                                              ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                    right: 11,
                                                    left: 1,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  height: 120,
                                                  width: 120,
                                                  decoration: BoxDecoration(
                                                    // color: Colors.red,
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
                                                      Expanded(
                                                        flex: 3,
                                                        child:
                                                            subjects[i]["image"] !=
                                                                    null
                                                                ? CachedNetworkImage(
                                                                  imageUrl:
                                                                      "$mainIP/${subjects[i]["image"]}",
                                                                )
                                                                // ? Image.network(
                                                                //   subjects[i]["image"],
                                                                // )
                                                                : Image.asset(
                                                                  ImageAssets
                                                                      .book,
                                                                ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          "${subjects[i]["name"]}"
                                                              .tr,
                                                          style: TextStyle(
                                                            fontSize:
                                                                globalFontSizeChange <=
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
                                                                FontWeight.w400,
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
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 200,
                                          child: GridView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 1,
                                                ),
                                            controller: scrollController,
                                            itemCount:
                                                recommendedCourses.length + 1,
                                            itemBuilder: (context, i) {
                                              if (i ==
                                                  recommendedCourses.length) {
                                                return InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => Courses(
                                                              // courses:
                                                              //     recommendedCourses,
                                                              title:
                                                                  "Recommended Courses",
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Card(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
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
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                globalFontFamily,
                                                            fontSize:
                                                                globalFontSizeChange <=
                                                                        17
                                                                    ? (globalFontSizeChange /
                                                                            5) +
                                                                        18
                                                                    : 18 -
                                                                        (globalFontSizeChange /
                                                                            5),
                                                            fontWeight:
                                                                FontWeight.w400,
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
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }

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
                                                  padding: const EdgeInsets.all(
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
                                                            recommendedCourses[i]["rating"] !=
                                                                    null
                                                                ? Container(
                                                                  height: 23,
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
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
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .star,
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
                                                                        // "${recommendedCourses[i]["rating"]}",
                                                                        double.parse(
                                                                          recommendedCourses[i]["rating"]
                                                                              .toString(),
                                                                        ).toStringAsFixed(
                                                                          1,
                                                                        ),
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              globalFontFamily,
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
                                                                          color: Color.fromARGB(
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
                                                              builder: (
                                                                controller,
                                                              ) {
                                                                final isFav =
                                                                    controller
                                                                        .isFavoriteC[recommendedCourses[i]["id"]
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
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const SizedBox(
                                                              height: 36,
                                                            ),
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
                                                                  ImageAssets
                                                                      .subject,
                                                                ),

                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                "${recommendedCourses[i]["name"]}"
                                                                    .tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
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
                                                                      FontWeight
                                                                          .w500,
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
                                        const SizedBox(height: 30),
                                        Center(
                                          child: Text(
                                            "Top Rated Courses".tr,
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
                                              fontStyle: FontStyle.normal,
                                              fontFamily: globalFontFamily,
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
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 200,
                                          child: GridView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 1,
                                                ),
                                            controller: scrollController,
                                            itemCount:
                                                TopRatedCourses.length + 1,
                                            itemBuilder: (context, i) {
                                              if (i == TopRatedCourses.length) {
                                                return InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => Courses(
                                                              // courses:
                                                              //     TopRatedCourses,
                                                              title:
                                                                  "Top Rated Courses",
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Card(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
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
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                globalFontFamily,
                                                            fontSize:
                                                                globalFontSizeChange <=
                                                                        17
                                                                    ? (globalFontSizeChange /
                                                                            5) +
                                                                        18
                                                                    : 18 -
                                                                        (globalFontSizeChange /
                                                                            5),
                                                            fontWeight:
                                                                FontWeight.w400,
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
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }

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
                                                  padding: const EdgeInsets.all(
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
                                                            TopRatedCourses[i]["rating"] !=
                                                                    null
                                                                ? Container(
                                                                  height: 23,
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
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
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .star,
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
                                                                        // "${recommendedCourses[i]["rating"]}",
                                                                        double.parse(
                                                                          TopRatedCourses[i]["rating"]
                                                                              .toString(),
                                                                        ).toStringAsFixed(
                                                                          1,
                                                                        ),
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              globalFontFamily,
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
                                                                          color: Color.fromARGB(
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
                                                              builder: (
                                                                controller,
                                                              ) {
                                                                final isFav =
                                                                    controller
                                                                        .isFavoriteC[TopRatedCourses[i]["id"]
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
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const SizedBox(
                                                              height: 35,
                                                            ),
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
                                                                  ImageAssets
                                                                      .subject,
                                                                ),

                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                "${TopRatedCourses[i]["name"]}"
                                                                    .tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
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
                                                                      FontWeight
                                                                          .w500,
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
                                        const SizedBox(height: 30),
                                        Center(
                                          child: Text(
                                            "Most Recent Courses".tr,
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
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 200,
                                          child: GridView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
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
                                                            (
                                                              context,
                                                            ) => Courses(
                                                              // courses:
                                                              //     recentCourses,
                                                              title:
                                                                  "Recent Courses",
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Card(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
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
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                globalFontFamily,
                                                            fontSize:
                                                                globalFontSizeChange <=
                                                                        17
                                                                    ? (globalFontSizeChange /
                                                                            5) +
                                                                        18
                                                                    : 18 -
                                                                        (globalFontSizeChange /
                                                                            5),
                                                            fontWeight:
                                                                FontWeight.w400,
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
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }

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
                                                                recentCourses[i],
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
                                                  padding: const EdgeInsets.all(
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
                                                            recentCourses[i]["rating"] !=
                                                                    null
                                                                ? Container(
                                                                  height: 23,
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
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
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .star,
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
                                                                        // "${recentCourses[i]["rating"]}",
                                                                        double.parse(
                                                                          recentCourses[i]["rating"]
                                                                              .toString(),
                                                                        ).toStringAsFixed(
                                                                          1,
                                                                        ),
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              globalFontFamily,
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
                                                                          color: Color.fromARGB(
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
                                                              builder: (
                                                                controller,
                                                              ) {
                                                                final isFav =
                                                                    controller
                                                                        .isFavoriteC[recentCourses[i]["id"]
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
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const SizedBox(
                                                              height: 34,
                                                            ),
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
                                                                  ImageAssets
                                                                      .subject,
                                                                ),

                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                "${recentCourses[i]["name"]}"
                                                                    .tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
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
                                                                      FontWeight
                                                                          .w500,
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
                                        const SizedBox(height: 30),
                                        Center(
                                          child: Text(
                                            "Most Subscribed Courses".tr,
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
                                              fontFamily: globalFontFamily,
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
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 200,
                                          child: GridView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 1,
                                                ),
                                            controller: scrollController,
                                            itemCount:
                                                subscribedCourses.length + 1,
                                            itemBuilder: (context, i) {
                                              if (i ==
                                                  subscribedCourses.length) {
                                                return InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => Courses(
                                                              // courses:
                                                              //     subscribedCourses,
                                                              title:
                                                                  "Most Subscribed Courses",
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Card(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
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
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                globalFontFamily,
                                                            fontSize:
                                                                globalFontSizeChange <=
                                                                        17
                                                                    ? (globalFontSizeChange /
                                                                            5) +
                                                                        18
                                                                    : 18 -
                                                                        (globalFontSizeChange /
                                                                            5),
                                                            fontWeight:
                                                                FontWeight.w400,
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
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }

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
                                                  padding: const EdgeInsets.all(
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
                                                            subscribedCourses[i]["rating"] !=
                                                                    null
                                                                ? Container(
                                                                  height: 23,
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
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
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .star,
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
                                                                          subscribedCourses[i]["rating"]
                                                                              .toString(),
                                                                        ).toStringAsFixed(
                                                                          1,
                                                                        ),
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              globalFontFamily,
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
                                                                          color: Color.fromARGB(
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
                                                              builder: (
                                                                controller,
                                                              ) {
                                                                final isFav =
                                                                    controller
                                                                        .isFavoriteC[subscribedCourses[i]["id"]
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
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const SizedBox(
                                                              height: 34,
                                                            ),
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
                                                                  ImageAssets
                                                                      .subject,
                                                                ),

                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                "${subscribedCourses[i]["name"]}"
                                                                    .tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
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
                                                                      FontWeight
                                                                          .w500,
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
                                        const SizedBox(height: 30),

                                        Container(
                                          padding: EdgeInsets.only(
                                            left: 60,
                                            right: 60,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          PdfLibraryScreen(),
                                                ),
                                              );
                                            },
                                            child: Card(
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
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Text(
                                                  textAlign: TextAlign.center,
                                                  "Previous Exams".tr,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        globalFontFamily,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize:
                                                        globalFontSizeChange >=
                                                                17
                                                            ? (globalFontSizeChange /
                                                                    5) +
                                                                16
                                                            : 16 -
                                                                (globalFontSizeChange /
                                                                    5),
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
      ),
    );
  }
}
