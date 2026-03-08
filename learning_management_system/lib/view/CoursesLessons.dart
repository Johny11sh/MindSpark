// ignore_for_file: file_names, non_constant_identifier_names, unnecessary_null_comparison, avoid_print, unused_element

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning_management_system/core/classes/ReviewsPage.dart';
import 'package:lottie/lottie.dart';

import '../core/constants/FontGlobals.dart';
import '../controller/LikesController.dart';
import '../controller/ProfileController.dart';
import '../controller/WatchlistController.dart';
import '../core/classes/QuizScreen.dart';
import 'package:like_button/like_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/FavoriteController.dart';
import '../core/function/CustomRatingDialog.dart';
import '../core/function/buildRatingBar.dart';
import '../core/function/noDataLottie.dart';
import '../services/CacheManager.dart';
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
import '../widget/AnimatedWatchlistButton.dart';
import 'NavBar.dart';
import 'PDFPage.dart';
import 'VideoPlayer.dart';

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
  final ProfileController profileController = Get.find<ProfileController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final TextEditingController reportController = TextEditingController();
  final NetworkController networkController = Get.find<NetworkController>();
  late SharedPrefs sharedPrefs;

  Set<int> expandedReviews = {};

  ScrollController scrollController = ScrollController();
  var ChosenScreen = "About";
  bool downloading = false;
  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  String filePath = "";

  bool isRated = false;

  List<String> ReportList = [];
  bool report1 = false;
  bool report2 = false;
  bool report3 = false;
  bool? isConnected;
  // late bool IsHelpful;
  // late bool IsUnHelpful;
  Map<int, bool> helpfulStates = {};
  Map<int, bool> unhelpfulStates = {};

  bool isPreparingPlayback = false;

  double? newUserRating;
  List<Map<String, dynamic>> newFeaturedRating = [];
  Map<String, dynamic> newBreakingDown = {};
  String? newCTRLRating;

  Map<int, bool> ratedCourses = {};

  List<Map<String, dynamic>> coursesData = [];
  bool? isLectureSubscribed = false;

  List<Map<String, dynamic>> recentLessonsData = [];

  List<Map<String, dynamic>> topRatedLessonsData = [];

  late String token;

  late FavoriteController favoriteController;
  late LikesController likesController;
  final CacheManager cacheManager = CacheManager();
  Future<void> loadRatedLessons() async {
    final storedMap = await sharedPrefs.loadMap("ratedCourses");
    setState(() {
      ratedCourses = storedMap;
    });
  }

  Future<Map<String, dynamic>?> SubscribeToCourse(String CourseID) async {
    try {
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) {
        debugPrint("No token found, already logged out");
        return null;
      }

      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/course/$CourseID/purchase';

      final response = await http
          .post(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      debugPrint(
        "Subscription confirmation API response: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Get.rawSnackbar(
          title: "Subscribed successfully".tr,
          messageText: Text(
            data['message'].toString().tr,
            style: TextStyle(fontFamily: globalFontFamily),
          ),
          isDismissible: true,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          icon: const Icon(Icons.check, color: Colors.white, size: 35),
          margin: const EdgeInsets.all(5),
          borderRadius: 5,
          borderColor: Colors.green[700]!,
        );
      } else {
        final data = json.decode(response.body);
        Get.rawSnackbar(
          title: "Subscription failed".tr,
          messageText: Text(
            data['message'].toString().tr,
            style: TextStyle(fontFamily: globalFontFamily),
          ),
          isDismissible: true,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          icon: const Icon(
            Icons.priority_high_outlined,
            color: Colors.white,
            size: 35,
          ),
          margin: const EdgeInsets.all(5),
          borderRadius: 5,
          borderColor: Colors.grey[700]!,
        );
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
    return null;
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
      final APIurl = '$baseUrl/api/lectureissubscribed/$id';

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
          '$baseUrl/api/getcourselectures/${widget.CoursesData['id']}';

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

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        final List<dynamic> lecturesList =
            responseBody is List
                ? responseBody
                : (responseBody['lectures'] ?? [responseBody]);

        final List<dynamic> topRatedLessonsList =
            responseBody is List
                ? responseBody
                : (responseBody['top_rated'] ?? [responseBody]);

        final List<dynamic> recentLessonsList =
            responseBody is List
                ? responseBody
                : (responseBody['recent'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            coursesData = List<Map<String, dynamic>>.from(lecturesList);
            topRatedLessonsData = List<Map<String, dynamic>>.from(
              topRatedLessonsList,
            );
            recentLessonsData = List<Map<String, dynamic>>.from(
              recentLessonsList,
            );
          });
          if (cacheManager.isCacheEnabled.value == true) {
            await _cacheLectures();
            await _cacheRecentLessons();
            await _cacheTopRatedLessons();
          }
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (coursesData.isEmpty ||
            topRatedLessonsData.isEmpty ||
            recentLessonsData.isEmpty) {
          throw Exception("Failed to load lectures: ${response.statusCode}");
        }
      }
    } on TimeoutException {
      if (coursesData.isEmpty ||
          topRatedLessonsData.isEmpty ||
          recentLessonsData.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      if (coursesData.isEmpty ||
          topRatedLessonsData.isEmpty ||
          recentLessonsData.isEmpty) {
        showErrorSnackbar("Failed to load lectures");
      } else {
        showErrorSnackbar("Using cached data - ${e.toString()}");
      }
      debugPrint("Error fetching lectures: $e");
    }
  }

  bool _areBarsVisible = false;

  void Animations() {
    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _areBarsVisible = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    Animations();

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
    likesController = Get.put(LikesController());
    token = sharedPrefs.prefs.getString("token")!;
    widget.CoursesData["user_rating"] != null
        ? isRated = true
        : isRated = false;
    loadRatedLessons();
    // widget.CoursesData["user_rating"] != null
    //     ? userRating = widget.CoursesData["user_rating"]
    //     : userRating = 1;
    // sources = widget.CoursesData['sources'] ?? [];
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getLecturesData();
    } else {
      if (cacheManager.isCacheEnabled.value == true) {
        await _loadCachedLectures();
      }
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

        final cacheKey2 = 'cached_recent_lessons_${widget.CoursesData['id']}';
        final cachedData2 = sharedPrefs.prefs.getString(cacheKey2);
        if (cachedData2 != null) {
          final List<dynamic> parsedList = jsonDecode(cachedData2);
          setState(() {
            recentLessonsData = List<Map<String, dynamic>>.from(parsedList);
          });
        }

        final cacheKey3 =
            'cached_top_rated_lessons_${widget.CoursesData['id']}';
        final cachedData3 = sharedPrefs.prefs.getString(cacheKey3);
        if (cachedData3 != null) {
          final List<dynamic> parsedList = jsonDecode(cachedData3);
          setState(() {
            topRatedLessonsData = List<Map<String, dynamic>>.from(parsedList);
          });
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

  void showErrorSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: TextStyle(fontFamily: globalFontFamily),
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red[800]!,
      isDismissible: true,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    var ratingBreakdown = widget.CoursesData["rating_breakdown"] ?? {};

    if (newBreakingDown.isNotEmpty) {
      ratingBreakdown = newBreakingDown;
    }

    newUserRating =
        widget.CoursesData['user_rating'] != null
            ? double.tryParse(widget.CoursesData['user_rating'].toString())
            : 0;
    print(widget.CoursesData["image"]);
    final totalReviews =
        (int.tryParse(ratingBreakdown["5"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["4"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["3"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["2"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["1"].toString()) ?? 0);

    final featuredRatings =
        widget.CoursesData["FeaturedRatings"] as List<dynamic>? ?? [];

    if (newFeaturedRating.isNotEmpty) {
      featuredRatings.addAll(newFeaturedRating);
    }

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body:
            (cacheManager.isCacheEnabled.value == false &&
                        sharedPrefs.prefs.getBool('isConnected') == false) ||
                    (widget.CoursesData.isEmpty && coursesData.isEmpty)
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
                              await _loadCachedLectures();
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
                : coursesData.isEmpty
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
                            height: Get.height / 2,
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
                                    const SizedBox(width: 30),
                                    Text(
                                          "Course".tr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
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
                                            fontWeight: FontWeight.w500,
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        20
                                                    : 20 -
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
                                    const SizedBox(width: 0),
                                    Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF4F8EF7),
                                                Color(0xFF2563EB),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.15,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: AnimatedWatchlistButton(
                                            itemId:
                                                widget.CoursesData["id"]
                                                    ?.toString() ??
                                                "0",
                                            itemType: "course",
                                            itemTitle:
                                                widget.CoursesData["name"]
                                                    ?.toString() ??
                                                "Book",
                                            itemImage:
                                                widget.CoursesData["image"]
                                                    ?.toString() ??
                                                "",
                                            size: 24,
                                            isCourse: true,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
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
                                                  widget.CoursesData["id"]
                                                      .toString(),
                                                );
                                                return !isLiked;
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: Get.width,
                                  height: Get.height / 2.31,
                                  decoration: BoxDecoration(
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
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(60),
                                      topRight: Radius.circular(60),
                                    ),
                                  ),
                                  child:
                                      (widget.CoursesData.isEmpty)
                                          ? noDataLottie("No data available")
                                          : Column(
                                            children: [
                                              Center(
                                                child: Container(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child:
                                                      widget.CoursesData["image"]! !=
                                                              null
                                                          ? Image.network(
                                                            "$mainIP/${widget.CoursesData["image"]!}",
                                                            width:
                                                                Get.width / 2,
                                                            height:
                                                                Get.height *
                                                                (1 / 6),
                                                            fit: BoxFit.fill,
                                                            errorBuilder: (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Image.asset(
                                                                ImageAssets
                                                                    .course,
                                                                width:
                                                                    Get.width /
                                                                    2,
                                                                height:
                                                                    Get.height *
                                                                    (1 / 6),
                                                                fit:
                                                                    BoxFit.fill,
                                                              );
                                                            },
                                                          )
                                                          : Image.asset(
                                                            ImageAssets.course,
                                                            width:
                                                                Get.width / 2,
                                                            height:
                                                                Get.height *
                                                                (1 / 6),
                                                            fit: BoxFit.fill,
                                                          ),
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Text(
                                                "${widget.CoursesData["name"]}"
                                                    .tr,
                                                style: TextStyle(
                                                  fontFamily: globalFontFamily,
                                                  fontSize:
                                                      globalFontSizeChange <= 17
                                                          ? (globalFontSizeChange /
                                                                  5) +
                                                              22
                                                          : 22 -
                                                              (globalFontSizeChange /
                                                                  5),
                                                  fontWeight: FontWeight.w600,
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

                                              // Text(
                                              //   "From : ${widget.CoursesData["video_lectures_count"]}"
                                              //       .toString()
                                              //       .tr,
                                              //   style: TextStyle(
                                              //     fontFamily:
                                              //         globalFontFamily,
                                              //     fontSize:  globalFontSizeChange <= 17 ?(globalFontSizeChange/5) + 16 :  16- (globalFontSizeChange / 5),
                                              //     fontWeight: FontWeight.w500,
                                              //     fontStyle: FontStyle.normal,
                                              //     color:
                                              //         themeController.initialTheme ==
                                              //                 Themes.customLightTheme
                                              //             ? Color.fromARGB(
                                              //               255,
                                              //               210,
                                              //               209,
                                              //               224,
                                              //             )
                                              //             : Color.fromARGB(
                                              //               255,
                                              //               40,
                                              //               41,
                                              //               61,
                                              //             ),
                                              //   ),
                                              // ),
                                              const SizedBox(height: 20),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    "Video lessons:".tr,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          globalFontFamily,
                                                      fontSize:
                                                          globalFontSizeChange <=
                                                                  17
                                                              ? (globalFontSizeChange /
                                                                      5) +
                                                                  16
                                                              : 16 -
                                                                  (globalFontSizeChange /
                                                                      5),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontStyle:
                                                          FontStyle.normal,
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
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    "${widget.CoursesData["video_lectures_count"]}"
                                                        .toString()
                                                        .tr,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          globalFontFamily,
                                                      fontSize:
                                                          globalFontSizeChange <=
                                                                  17
                                                              ? (globalFontSizeChange /
                                                                      5) +
                                                                  16
                                                              : 16 -
                                                                  (globalFontSizeChange /
                                                                      5),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontStyle:
                                                          FontStyle.normal,
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

                                                  const SizedBox(width: 15),
                                                  Text(
                                                    "-",
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall!.copyWith(
                                                      fontFamily:
                                                          globalFontFamily,
                                                      fontSize:
                                                          globalFontSizeChange <=
                                                                  17
                                                              ? (globalFontSizeChange /
                                                                      5) +
                                                                  20
                                                              : 20 -
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
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 15),
                                                  Text(
                                                    "PDF lessons:".tr,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          globalFontFamily,
                                                      fontSize:
                                                          globalFontSizeChange <=
                                                                  17
                                                              ? (globalFontSizeChange /
                                                                      5) +
                                                                  16
                                                              : 16 -
                                                                  (globalFontSizeChange /
                                                                      5),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontStyle:
                                                          FontStyle.normal,
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
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    "${widget.CoursesData["pdf_lessons_count"]}"
                                                        .toString()
                                                        .tr,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          globalFontFamily,
                                                      fontSize:
                                                          globalFontSizeChange <=
                                                                  17
                                                              ? (globalFontSizeChange /
                                                                      5) +
                                                                  16
                                                              : 16 -
                                                                  (globalFontSizeChange /
                                                                      5),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontStyle:
                                                          FontStyle.normal,
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
                                              const SizedBox(height: 25),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Price:".tr,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          globalFontFamily,
                                                      fontSize:
                                                          globalFontSizeChange <=
                                                                  17
                                                              ? (globalFontSizeChange /
                                                                      5) +
                                                                  16
                                                              : 16 -
                                                                  (globalFontSizeChange /
                                                                      5),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FontStyle.normal,
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

                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "\$${widget.CoursesData["price"]}"
                                                        .toString()
                                                        .tr,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          globalFontFamily,
                                                      fontSize:
                                                          globalFontSizeChange <=
                                                                  17
                                                              ? (globalFontSizeChange /
                                                                      5) +
                                                                  16
                                                              : 16 -
                                                                  (globalFontSizeChange /
                                                                      5),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FontStyle.normal,
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
                                              const SizedBox(height: 25),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  // const SizedBox(width: 10),
                                                  // Text(
                                                  //   "-",
                                                  //   style: Theme.of(
                                                  //     context,
                                                  //   ).textTheme.bodySmall!.copyWith(
                                                  //     fontFamily:
                                                  //         globalFontFamily,
                                                  //     fontSize:
                                                  //         globalFontSizeChange <=
                                                  //                 17
                                                  //             ? (globalFontSizeChange /
                                                  //                     5) +
                                                  //                 20
                                                  //             : 20 -
                                                  //                 (globalFontSizeChange /
                                                  //                     5),
                                                  //     color:
                                                  //         themeController
                                                  //                     .initialTheme ==
                                                  //                 Themes
                                                  //                     .customLightTheme
                                                  //             ? Color.fromARGB(
                                                  //               255,
                                                  //               210,
                                                  //               209,
                                                  //               224,
                                                  //             )
                                                  //             : Color.fromARGB(
                                                  //               255,
                                                  //               40,
                                                  //               41,
                                                  //               61,
                                                  //             ),
                                                  //     fontWeight: FontWeight.w300,
                                                  //   ),
                                                  // ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Sparkies Price:',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall!.copyWith(
                                                      fontFamily:
                                                          globalFontFamily,
                                                      fontSize:
                                                          globalFontSizeChange <=
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    widget
                                                        .CoursesData['sparkiesPrice']
                                                        .toString(),
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall!.copyWith(
                                                      fontFamily:
                                                          globalFontFamily,
                                                      fontSize:
                                                          globalFontSizeChange <=
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "-",
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall!.copyWith(
                                                      fontFamily:
                                                          globalFontFamily,
                                                      fontSize:
                                                          globalFontSizeChange <=
                                                                  17
                                                              ? (globalFontSizeChange /
                                                                      5) +
                                                                  20
                                                              : 20 -
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
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),

                                                  Text(
                                                    'My Sparkies:',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall!.copyWith(
                                                      fontFamily:
                                                          globalFontFamily,
                                                      fontSize:
                                                          globalFontSizeChange <=
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
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    profileController
                                                        .profileData['sparkies']
                                                        .toString(),
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall!.copyWith(
                                                      fontFamily:
                                                          globalFontFamily,
                                                      fontSize:
                                                          globalFontSizeChange <=
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
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
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
                                      right: BorderSide(
                                        style: BorderStyle.solid,
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
                                      bottom: BorderSide(
                                        style: BorderStyle.solid,
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
                                      top: BorderSide(
                                        style: BorderStyle.solid,
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
                                      right: BorderSide(
                                        style: BorderStyle.solid,
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
                                      bottom: BorderSide(
                                        style: BorderStyle.solid,
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
                                      top: BorderSide(
                                        style: BorderStyle.solid,
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
                                      right: BorderSide(
                                        style: BorderStyle.solid,
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
                                      bottom: BorderSide(
                                        style: BorderStyle.solid,
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
                                      top: BorderSide(
                                        style: BorderStyle.solid,
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
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          ChosenScreen == "Reviews"
                              ? Column(
                                children: [
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      spacing: 10,
                                      children: [
                                        const SizedBox(width: 20),
                                        StatefulBuilder(
                                          builder: (context, setDState) {
                                            bool isRated =
                                                ratedCourses[widget
                                                    .CoursesData['id']] ??
                                                false;
                                            return Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () async {
                                                    showRatingDailog(
                                                      context,
                                                      widget.CoursesData["id"],
                                                      token,
                                                      "$mainIP/api/ratecourse/${widget.CoursesData["id"]}",

                                                      () async {
                                                        setState(() {
                                                          newUserRating =
                                                              userRating;
                                                          newFeaturedRating =
                                                              List<
                                                                Map<
                                                                  String,
                                                                  dynamic
                                                                >
                                                              >.from(
                                                                newRatingData,
                                                              );
                                                          newBreakingDown = Map<
                                                            String,
                                                            dynamic
                                                          >.from(
                                                            newRatingsBreakingDown,
                                                          );
                                                          newCTRLRating =
                                                              newRating;

                                                          if (newFeaturedRating
                                                              .isNotEmpty) {
                                                            if (isCreated ==
                                                                    false &&
                                                                featuredRatings
                                                                    .isNotEmpty) {
                                                              featuredRatings
                                                                  .removeAt(0);
                                                            }
                                                            featuredRatings.insert(
                                                              0,
                                                              newFeaturedRating
                                                                  .first,
                                                            );
                                                          }

                                                          if (newFeaturedRating
                                                              .isEmpty) {
                                                            if (isCreated ==
                                                                    false &&
                                                                featuredRatings
                                                                    .isNotEmpty) {
                                                              featuredRatings
                                                                  .removeAt(0);
                                                            }
                                                          }
                                                          widget.CoursesData['featuredRatings'] =
                                                              featuredRatings;
                                                          widget.CoursesData['rating_breakdown'] =
                                                              newBreakingDown;
                                                          widget.CoursesData['user_rating'] =
                                                              newUserRating;
                                                          widget.CoursesData['rating'] =
                                                              newCTRLRating;

                                                          ratedCourses[widget
                                                                  .CoursesData["id"]] =
                                                              true;
                                                        });
                                                        await sharedPrefs
                                                            .saveMap(
                                                              "ratedCourses",
                                                              ratedCourses,
                                                            );
                                                      },
                                                      newUserRating ?? 0,
                                                    );
                                                  },
                                                  icon: Icon(
                                                    (isRated)
                                                        ? Icons.star_outlined
                                                        : Icons
                                                            .star_border_outlined,
                                                  ),
                                                  color: Colors.blue,
                                                  iconSize: 30,
                                                ),
                                                Text(
                                                  (isRated)
                                                      ? newUserRating
                                                          .toString()
                                                          .tr
                                                      : "Rate This".tr,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        globalFontFamily,
                                                    color: Colors.blue,
                                                    fontSize:
                                                        globalFontSizeChange <=
                                                                17
                                                            ? (globalFontSizeChange /
                                                                    5) +
                                                                16
                                                            : 16 -
                                                                (globalFontSizeChange /
                                                                    5),
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 10),
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
                                                  "${(widget.CoursesData['rating'] == null)
                                                      ? "0"
                                                      : (newCTRLRating == null)
                                                      ? widget.CoursesData['rating'].toString()
                                                      : newCTRLRating.toString()}/5",

                                                  style: TextStyle(
                                                    fontFamily:
                                                        globalFontFamily,
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
                                                    fontSize:
                                                        globalFontSizeChange <=
                                                                17
                                                            ? (globalFontSizeChange /
                                                                    5) +
                                                                22
                                                            : 22 -
                                                                (globalFontSizeChange /
                                                                    5),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Text(
                                              "based on (${totalReviews.toString()}) reviews",
                                              style: TextStyle(
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
                                                fontSize:
                                                    globalFontSizeChange <= 17
                                                        ? (globalFontSizeChange /
                                                                5) +
                                                            20
                                                        : 20 -
                                                            (globalFontSizeChange /
                                                                5),
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
                                      buildRatingBar(
                                        5,
                                        _areBarsVisible,
                                        widget.CoursesData["rating_breakdown"],
                                      ),
                                      const SizedBox(height: 6),
                                      buildRatingBar(
                                        4,
                                        _areBarsVisible,
                                        widget.CoursesData["rating_breakdown"],
                                      ),
                                      const SizedBox(height: 6),
                                      buildRatingBar(
                                        3,
                                        _areBarsVisible,
                                        widget.CoursesData["rating_breakdown"],
                                      ),
                                      const SizedBox(height: 6),
                                      buildRatingBar(
                                        2,
                                        _areBarsVisible,
                                        widget.CoursesData["rating_breakdown"],
                                      ),
                                      const SizedBox(height: 6),
                                      buildRatingBar(
                                        1,
                                        _areBarsVisible,
                                        widget.CoursesData["rating_breakdown"],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  Container(
                                    height: 1,
                                    width: Get.width / 1.1,
                                    decoration: BoxDecoration(
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
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(60),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  Center(
                                    child: SizedBox(
                                      width: Get.width / 3.5,
                                      height: 40,
                                      child: MaterialButton(
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
                                        textColor:
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

                                        onPressed: () async {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => ReviewsPage(
                                                    type: "getcourseratings",
                                                    sectionId:
                                                        widget
                                                            .CoursesData["id"],
                                                  ),
                                            ),
                                          );
                                          _areBarsVisible = false;
                                          Animations();
                                        },
                                        child: Text(
                                          "See All Reviews".tr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: globalFontFamily,
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        14
                                                    : 14 -
                                                        (globalFontSizeChange /
                                                            5),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  Container(
                                    height: 1,
                                    width: Get.width / 1.1,
                                    decoration: BoxDecoration(
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
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(60),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 20),

                                  SizedBox(
                                    height:
                                        Get.height *
                                        0.6, // 40% of screen height, adjust as needed
                                    child: ListView.builder(
                                      physics: AlwaysScrollableScrollPhysics(),
                                      itemCount:
                                          (featuredRatings.length < 4)
                                              ? featuredRatings.length
                                              : 3,
                                      itemBuilder: (context, index) {
                                        final review =
                                            widget.CoursesData["FeaturedRatings"]?[index]
                                                as Map<String, dynamic>? ??
                                            {};

                                        featuredRatings.length;

                                        // final review =
                                        //     featuredRatings[index]
                                        //         as Map<String, dynamic>? ??
                                        //     {};
                                        final reviewId = review['id'] ?? index;

                                        // Initialize state only if not present
                                        helpfulStates[reviewId] ??=
                                            review["isHelpful"] == true;
                                        unhelpfulStates[reviewId] ??=
                                            review["isUnhelpful"] == true;

                                        // IsHelpful =
                                        //     widget
                                        //         .CoursesData["FeaturedRatings"]?[index]["isHelpful"] ==
                                        //     true;
                                        // IsUnHelpful =
                                        //     widget
                                        //         .CoursesData["FeaturedRatings"]?[index]["isUnhelpful"] ==
                                        //     true;
                                        final reviewText =
                                            review["review"]?.toString().tr ??
                                            'No review'.tr;
                                        final textSpan = TextSpan(
                                          text: reviewText,
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
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        12
                                                    : 12 -
                                                        (globalFontSizeChange /
                                                            5),
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
                                        final isExpanded = expandedReviews
                                            .contains(index);

                                        return SizedBox(
                                          width: Get.width / 1.1,
                                          child: StatefulBuilder(
                                            builder: (context, setDiaState) {
                                              // bool isRated =
                                              //     ratedCourses[widget
                                              //         .CoursesData['id']] ??
                                              //     false;
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
                                                                fontFamily:
                                                                    globalFontFamily,
                                                                color:
                                                                    (review["user_name"] ==
                                                                            profileController.profileData['userName'])
                                                                        ? themeController.initialTheme ==
                                                                                Themes.customLightTheme
                                                                            ? Colors.amber.shade700
                                                                            : Colors.amber
                                                                        : themeController.initialTheme ==
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
                                                                fontSize:
                                                                    globalFontSizeChange >=
                                                                            17
                                                                        ? (globalFontSizeChange /
                                                                                5) +
                                                                            20
                                                                        : 20 -
                                                                            (globalFontSizeChange /
                                                                                5),
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
                                                                    fontFamily:
                                                                        globalFontFamily,
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
                                                            fontFamily:
                                                                globalFontFamily,
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
                                                            fontSize:
                                                                globalFontSizeChange >=
                                                                        17
                                                                    ? (globalFontSizeChange /
                                                                            5) +
                                                                        10
                                                                    : 10 -
                                                                        (globalFontSizeChange /
                                                                            5),
                                                            fontWeight:
                                                                FontWeight.w200,
                                                          ),
                                                        ),
                                                      ),
                                                      PopupMenuButton<String>(
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
                                                        icon: Icon(
                                                          Icons
                                                              .more_vert_rounded,
                                                        ),
                                                        iconSize: 20,
                                                        iconColor:
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
                                                        onSelected: (
                                                          value,
                                                        ) async {
                                                          if (value ==
                                                              'report') {
                                                            showDialog(
                                                              context: context,
                                                              builder: (
                                                                context,
                                                              ) {
                                                                bool
                                                                localReport1 =
                                                                    report1;
                                                                bool
                                                                localReport2 =
                                                                    report2;
                                                                bool
                                                                localReport3 =
                                                                    report3;
                                                                return StatefulBuilder(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                        setDialogState,
                                                                      ) => AlertDialog(
                                                                        title: Text(
                                                                          "Reasons:"
                                                                              .tr,
                                                                          style: TextStyle(
                                                                            fontFamily:
                                                                                globalFontFamily,
                                                                            color: Color.fromARGB(
                                                                              255,
                                                                              40,
                                                                              41,
                                                                              61,
                                                                            ),
                                                                            fontSize:
                                                                                globalFontSizeChange >=
                                                                                        17
                                                                                    ? (globalFontSizeChange /
                                                                                            5) +
                                                                                        18
                                                                                    : 18 -
                                                                                        (globalFontSizeChange /
                                                                                            5),
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                        content: Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            CheckboxListTile(
                                                                              title: Text(
                                                                                "Offensive:".tr,
                                                                                style: TextStyle(
                                                                                  fontFamily:
                                                                                      globalFontFamily,
                                                                                  color: Color.fromARGB(
                                                                                    255,
                                                                                    40,
                                                                                    41,
                                                                                    61,
                                                                                  ),
                                                                                  fontSize:
                                                                                      globalFontSizeChange >=
                                                                                              17
                                                                                          ? (globalFontSizeChange /
                                                                                                  5) +
                                                                                              14
                                                                                          : 14 -
                                                                                              (globalFontSizeChange /
                                                                                                  5),
                                                                                  fontWeight:
                                                                                      FontWeight.w300,
                                                                                ),
                                                                              ),
                                                                              value:
                                                                                  localReport1,
                                                                              onChanged: (
                                                                                value,
                                                                              ) {
                                                                                setDialogState(
                                                                                  () {
                                                                                    localReport1 =
                                                                                        value ??
                                                                                        false;
                                                                                  },
                                                                                );
                                                                                setDiaState(
                                                                                  () {
                                                                                    report1 =
                                                                                        value ??
                                                                                        false;
                                                                                  },
                                                                                );
                                                                              },
                                                                            ),
                                                                            CheckboxListTile(
                                                                              title: Text(
                                                                                "Inappropriate:".tr,
                                                                                style: TextStyle(
                                                                                  fontFamily:
                                                                                      globalFontFamily,
                                                                                  color: Color.fromARGB(
                                                                                    255,
                                                                                    40,
                                                                                    41,
                                                                                    61,
                                                                                  ),
                                                                                  fontSize:
                                                                                      globalFontSizeChange >=
                                                                                              17
                                                                                          ? (globalFontSizeChange /
                                                                                                  5) +
                                                                                              14
                                                                                          : 14 -
                                                                                              (globalFontSizeChange /
                                                                                                  5),
                                                                                  fontWeight:
                                                                                      FontWeight.w300,
                                                                                ),
                                                                              ),
                                                                              value:
                                                                                  localReport2,
                                                                              onChanged: (
                                                                                value,
                                                                              ) {
                                                                                setDialogState(
                                                                                  () {
                                                                                    localReport2 =
                                                                                        value ??
                                                                                        false;
                                                                                  },
                                                                                );
                                                                                setDiaState(
                                                                                  () {
                                                                                    report2 =
                                                                                        value ??
                                                                                        false;
                                                                                  },
                                                                                );
                                                                              },
                                                                            ),
                                                                            CheckboxListTile(
                                                                              title: Text(
                                                                                "Unrelated:".tr,
                                                                                style: TextStyle(
                                                                                  fontFamily:
                                                                                      globalFontFamily,
                                                                                  color: Color.fromARGB(
                                                                                    255,
                                                                                    40,
                                                                                    41,
                                                                                    61,
                                                                                  ),
                                                                                  fontSize:
                                                                                      globalFontSizeChange >=
                                                                                              17
                                                                                          ? (globalFontSizeChange /
                                                                                                  5) +
                                                                                              14
                                                                                          : 14 -
                                                                                              (globalFontSizeChange /
                                                                                                  5),
                                                                                  fontWeight:
                                                                                      FontWeight.w300,
                                                                                ),
                                                                              ),
                                                                              value:
                                                                                  localReport3,
                                                                              onChanged: (
                                                                                value,
                                                                              ) {
                                                                                setDialogState(
                                                                                  () {
                                                                                    localReport3 =
                                                                                        value ??
                                                                                        false;
                                                                                  },
                                                                                );
                                                                                setDiaState(
                                                                                  () {
                                                                                    report3 =
                                                                                        value ??
                                                                                        false;
                                                                                  },
                                                                                );
                                                                              },
                                                                            ),
                                                                            const SizedBox(
                                                                              height:
                                                                                  10,
                                                                            ),
                                                                            Container(
                                                                              height:
                                                                                  80,
                                                                              padding: const EdgeInsets.only(
                                                                                right:
                                                                                    30,
                                                                                left:
                                                                                    30,
                                                                              ),
                                                                              child: TextFormField(
                                                                                style: TextStyle(
                                                                                  color: Color.fromARGB(
                                                                                    255,
                                                                                    40,
                                                                                    41,
                                                                                    61,
                                                                                  ),
                                                                                ),
                                                                                controller:
                                                                                    reportController,
                                                                                autovalidateMode:
                                                                                    AutovalidateMode.onUserInteraction,
                                                                                cursorColor: const Color.fromARGB(
                                                                                  255,
                                                                                  254,
                                                                                  233,
                                                                                  204,
                                                                                ),
                                                                                obscureText:
                                                                                    false,
                                                                                keyboardType:
                                                                                    TextInputType.text,

                                                                                decoration: InputDecoration(
                                                                                  prefixIcon: const Icon(
                                                                                    Icons.message_rounded,
                                                                                    size:
                                                                                        25,
                                                                                  ),
                                                                                  prefixIconColor: const Color.fromARGB(
                                                                                    255,
                                                                                    40,
                                                                                    41,
                                                                                    61,
                                                                                  ),
                                                                                  hintText:
                                                                                      "Message (optional)".tr,
                                                                                  hintStyle: TextStyle(
                                                                                    color: const Color.fromARGB(
                                                                                      255,
                                                                                      40,
                                                                                      41,
                                                                                      61,
                                                                                    ),
                                                                                  ),
                                                                                  focusedBorder: OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      6,
                                                                                    ),
                                                                                    borderSide: const BorderSide(
                                                                                      width:
                                                                                          2,
                                                                                      color: Color.fromARGB(
                                                                                        255,
                                                                                        40,
                                                                                        41,
                                                                                        61,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  enabledBorder: OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      6,
                                                                                    ),
                                                                                    borderSide: const BorderSide(
                                                                                      color: Color.fromARGB(
                                                                                        255,
                                                                                        40,
                                                                                        41,
                                                                                        61,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  errorBorder: OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      6,
                                                                                    ),
                                                                                    borderSide: const BorderSide(
                                                                                      color: Color.fromARGB(
                                                                                        255,
                                                                                        255,
                                                                                        23,
                                                                                        7,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  focusedErrorBorder: OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      6,
                                                                                    ),
                                                                                    borderSide: const BorderSide(
                                                                                      width:
                                                                                          2,
                                                                                      color: Color.fromARGB(
                                                                                        255,
                                                                                        255,
                                                                                        23,
                                                                                        7,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),

                                                                                // validator: (
                                                                                //   val,
                                                                                // ) {
                                                                                //   if (val!.isEmpty) {
                                                                                //     return "Please enter A User Name".tr;
                                                                                //   } else {
                                                                                //     if (val.length <
                                                                                //         3) {
                                                                                //       return "User Name must be longer than 3 characters".tr;
                                                                                //     } else if (val.length >
                                                                                //         25) {
                                                                                //       return "User Name must be shorter than 25 characters".tr;
                                                                                //     }
                                                                                //   }
                                                                                //   return null;
                                                                                // },
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height:
                                                                                  10,
                                                                            ),

                                                                            MaterialButton(
                                                                              onPressed: () async {
                                                                                if (localReport1 ==
                                                                                    true) {
                                                                                  ReportList.add(
                                                                                    'offensive',
                                                                                  );
                                                                                }
                                                                                if (localReport2 ==
                                                                                    true) {
                                                                                  ReportList.add(
                                                                                    'inappropriate',
                                                                                  );
                                                                                }
                                                                                if (localReport3 ==
                                                                                    true) {
                                                                                  ReportList.add(
                                                                                    'unrelated',
                                                                                  );
                                                                                }
                                                                                // await networkController.checkConnectivityManually();
                                                                                isConnected = sharedPrefs.prefs.getBool(
                                                                                  'isConnected',
                                                                                );
                                                                                if (isConnected ==
                                                                                    true) {
                                                                                  if (ReportList.isNotEmpty) {
                                                                                    likesController.reportReview(
                                                                                      'course_rating_id',
                                                                                      reviewId.toString(),
                                                                                      ReportList,
                                                                                      reportController.text.toString(),
                                                                                    );
                                                                                    ReportList.clear();
                                                                                  } else {
                                                                                    Get.rawSnackbar(
                                                                                      title:
                                                                                          "Warning".tr,
                                                                                      messageText: Text(
                                                                                        "You need to choose at least one reason".tr,
                                                                                        style: TextStyle(
                                                                                          fontFamily:
                                                                                              globalFontFamily,
                                                                                        ),
                                                                                      ),
                                                                                      isDismissible:
                                                                                          true,
                                                                                      snackPosition:
                                                                                          SnackPosition.BOTTOM,
                                                                                      duration: const Duration(
                                                                                        seconds:
                                                                                            3,
                                                                                      ),
                                                                                      backgroundColor:
                                                                                          Colors.red,
                                                                                      icon: const Icon(
                                                                                        Icons.priority_high_outlined,
                                                                                        color:
                                                                                            Colors.white,
                                                                                        size:
                                                                                            35,
                                                                                      ),
                                                                                      margin: const EdgeInsets.all(
                                                                                        5,
                                                                                      ),
                                                                                      borderRadius:
                                                                                          5,
                                                                                      borderColor:
                                                                                          Colors.grey[700]!,
                                                                                    );
                                                                                  }
                                                                                } else {
                                                                                  Get.snackbar(
                                                                                    "Connection error".tr,
                                                                                    "Connection access is needed".tr,
                                                                                  );
                                                                                }
                                                                              },
                                                                              color: Color.fromARGB(
                                                                                255,
                                                                                210,
                                                                                209,
                                                                                224,
                                                                              ),
                                                                              minWidth:
                                                                                  Get.width /
                                                                                  3.5,
                                                                              height:
                                                                                  35,
                                                                              child: Text(
                                                                                "Submit".tr,
                                                                                style: TextStyle(
                                                                                  fontSize:
                                                                                      globalFontSizeChange >=
                                                                                              17
                                                                                          ? (globalFontSizeChange /
                                                                                                  5) +
                                                                                              20
                                                                                          : 20 -
                                                                                              (globalFontSizeChange /
                                                                                                  5),
                                                                                  fontWeight:
                                                                                      FontWeight.w500,
                                                                                  fontStyle:
                                                                                      FontStyle.normal,
                                                                                  color: Color.fromARGB(
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
                                                                );
                                                              },
                                                            );
                                                          }
                                                        },
                                                        itemBuilder:
                                                            (context) => [
                                                              PopupMenuItem(
                                                                onTap: () {
                                                                  report1 =
                                                                      false;
                                                                  report2 =
                                                                      false;
                                                                  report3 =
                                                                      false;
                                                                },
                                                                value: 'report',
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      "report"
                                                                          .tr,
                                                                      style: TextStyle(
                                                                        fontFamily:
                                                                            globalFontFamily,
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
                                                                        fontSize:
                                                                            globalFontSizeChange >=
                                                                                    17
                                                                                ? (globalFontSizeChange /
                                                                                        5) +
                                                                                    14
                                                                                : 14 -
                                                                                    (globalFontSizeChange /
                                                                                        5),
                                                                        fontWeight:
                                                                            FontWeight.w300,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        reviewText,
                                                        maxLines:
                                                            isExpanded
                                                                ? null
                                                                : 3,
                                                        overflow:
                                                            isExpanded
                                                                ? TextOverflow
                                                                    .visible
                                                                : TextOverflow
                                                                    .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              globalFontFamily,
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
                                                          fontSize:
                                                              globalFontSizeChange <=
                                                                      17
                                                                  ? (globalFontSizeChange /
                                                                          5) +
                                                                      12
                                                                  : 12 -
                                                                      (globalFontSizeChange /
                                                                          5),
                                                          fontWeight:
                                                              FontWeight.w200,
                                                        ),
                                                      ),
                                                      if (isLong && !isExpanded)
                                                        TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              expandedReviews
                                                                  .add(index);
                                                            });
                                                          },
                                                          style:
                                                              TextButton.styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                          child: Text(
                                                            'Read more...',
                                                            style: TextStyle(
                                                              color:
                                                                  themeController
                                                                              .initialTheme ==
                                                                          Themes
                                                                              .customLightTheme
                                                                      ? Color.fromARGB(
                                                                        255,
                                                                        46,
                                                                        48,
                                                                        97,
                                                                      )
                                                                      : Color.fromARGB(
                                                                        255,
                                                                        153,
                                                                        151,
                                                                        188,
                                                                      ),
                                                              fontFamily:
                                                                  globalFontFamily,
                                                            ),
                                                          ),
                                                        ),
                                                      if (isExpanded && isLong)
                                                        TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              expandedReviews
                                                                  .remove(
                                                                    index,
                                                                  );
                                                            });
                                                          },
                                                          style:
                                                              TextButton.styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                          child: Text(
                                                            'Show less',
                                                            style: TextStyle(
                                                              color:
                                                                  themeController
                                                                              .initialTheme ==
                                                                          Themes
                                                                              .customLightTheme
                                                                      ? Color.fromARGB(
                                                                        255,
                                                                        46,
                                                                        48,
                                                                        97,
                                                                      )
                                                                      : Color.fromARGB(
                                                                        255,
                                                                        153,
                                                                        151,
                                                                        188,
                                                                      ),
                                                              fontFamily:
                                                                  globalFontFamily,
                                                            ),
                                                          ),
                                                        ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          LikeButton(
                                                            size: 20,
                                                            isLiked:
                                                                helpfulStates[reviewId] ??
                                                                false,
                                                            likeBuilder: (
                                                              bool isLiked,
                                                            ) {
                                                              return Icon(
                                                                isLiked
                                                                    ? Icons
                                                                        .thumb_up_alt
                                                                    : Icons
                                                                        .thumb_up_alt_outlined,
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
                                                                size: 20,
                                                              );
                                                            },
                                                            onTap: (
                                                              bool isLiked,
                                                            ) async {
                                                              // print(widget.videoData["id"].toString());

                                                              await likesController
                                                                  .toggleHelpful({
                                                                    "course_rating_id":
                                                                        reviewId,
                                                                  });
                                                              review["isHelpful"] =
                                                                  likesController
                                                                      .isHelpful;
                                                              review["isUnhelpful"] =
                                                                  likesController
                                                                      .isUnhelpful;
                                                              setDiaState(() {
                                                                helpfulStates[reviewId] =
                                                                    !isLiked;
                                                                if (helpfulStates[reviewId] ==
                                                                    true) {
                                                                  unhelpfulStates[reviewId] =
                                                                      false;
                                                                }
                                                              });

                                                              return !isLiked;
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),

                                                          LikeButton(
                                                            size: 20,
                                                            isLiked:
                                                                unhelpfulStates[reviewId] ??
                                                                false,
                                                            likeBuilder: (
                                                              bool isLiked,
                                                            ) {
                                                              return Icon(
                                                                isLiked
                                                                    ? Icons
                                                                        .thumb_down_alt
                                                                    : Icons
                                                                        .thumb_down_alt_outlined,
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
                                                                size: 20,
                                                              );
                                                            },
                                                            onTap: (
                                                              bool isLiked,
                                                            ) async {
                                                              // print(widget.videoData["id"].toString());
                                                              await likesController
                                                                  .toggleUnhelpful({
                                                                    "course_rating_id":
                                                                        reviewId,
                                                                  });
                                                              review["isHelpful"] =
                                                                  likesController
                                                                      .isHelpful;
                                                              review["isUnhelpful"] =
                                                                  likesController
                                                                      .isUnhelpful;
                                                              setDiaState(() {
                                                                unhelpfulStates[reviewId] =
                                                                    !isLiked;
                                                                if (unhelpfulStates[reviewId] ==
                                                                    true) {
                                                                  helpfulStates[reviewId] =
                                                                      false;
                                                                }
                                                              });
                                                              return !isLiked;
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Container(
                                                    height: 1,
                                                    width: Get.width / 1.1,
                                                    decoration: BoxDecoration(
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
                                          padding: const EdgeInsets.only(
                                            left: 5,
                                          ),
                                          child: Text(
                                            "Total Videos Duration:".tr,
                                            style: TextStyle(
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
                                              fontSize:
                                                  globalFontSizeChange <= 17
                                                      ? (globalFontSizeChange /
                                                              5) +
                                                          18
                                                      : 18 -
                                                          (globalFontSizeChange /
                                                              5),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                            left: 5,
                                          ),
                                          child: Text(
                                            "${widget.CoursesData['duration_formatted_long']}"
                                                .tr,
                                            style: TextStyle(
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
                                              fontSize:
                                                  globalFontSizeChange <= 17
                                                      ? (globalFontSizeChange /
                                                              5) +
                                                          16
                                                      : 16 -
                                                          (globalFontSizeChange /
                                                              5),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(
                                            left: 5,
                                          ),
                                          child: Text(
                                            "Total PDFs pages:".tr,
                                            style: TextStyle(
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
                                              fontSize:
                                                  globalFontSizeChange <= 17
                                                      ? (globalFontSizeChange /
                                                              5) +
                                                          18
                                                      : 18 -
                                                          (globalFontSizeChange /
                                                              5),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),

                                        Container(
                                          padding: const EdgeInsets.only(
                                            left: 5,
                                          ),
                                          child: Text(
                                            "${widget.CoursesData['total_pdf_pages']}"
                                                .tr,
                                            style: TextStyle(
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
                                              fontSize:
                                                  globalFontSizeChange <= 17
                                                      ? (globalFontSizeChange /
                                                              5) +
                                                          16
                                                      : 16 -
                                                          (globalFontSizeChange /
                                                              5),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: Get.height / 25),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      controller: scrollController,
                                      itemCount: coursesData.length,
                                      itemBuilder: (context, i) {
                                        int lectureId = coursesData[i]["id"];

                                        return InkWell(
                                          onTap: () async {
                                            await getSubscription(lectureId);

                                            if (isLectureSubscribed == true) {
                                              if (coursesData[i]['type'] == 0) {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) => PDFPage(
                                                          PDFData:
                                                              coursesData[i],
                                                          // PDFData: widget.BookData
                                                        ),
                                                  ),
                                                );
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
                                                              videoData:
                                                                  coursesData[i],
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
                                                    fontFamily:
                                                        globalFontFamily,
                                                    color: Color.fromARGB(
                                                      255,
                                                      40,
                                                      41,
                                                      61,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        globalFontSizeChange <=
                                                                17
                                                            ? (globalFontSizeChange /
                                                                    5) +
                                                                18
                                                            : 18 -
                                                                (globalFontSizeChange /
                                                                    5),
                                                  ),
                                                ),
                                                messageText: Text(
                                                  'Contact the support team for instructions on how to subscribe to the course/subject first.'
                                                      .tr,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        globalFontFamily,
                                                    color: Color.fromARGB(
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
                                                  color: Color.fromARGB(
                                                    255,
                                                    40,
                                                    41,
                                                    61,
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
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      Colors.black.withValues(),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
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
                                                          coursesData[i]["image"] !=
                                                                  null
                                                              ? CachedNetworkImage(
                                                                imageUrl:
                                                                    "$mainIP/${coursesData[i]['image']}",
                                                                height: 60,
                                                                width: 60,
                                                              )
                                                              : Image.asset(
                                                                ImageAssets
                                                                    .lecture,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                              ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${coursesData[i]["name"]}"
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
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        8,
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
                                                                    : "Video"
                                                                        .tr,
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      globalFontFamily,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize:
                                                                      globalFontSizeChange >=
                                                                              17
                                                                          ? (globalFontSizeChange /
                                                                                  5) +
                                                                              10
                                                                          : 10 -
                                                                              (globalFontSizeChange /
                                                                                  5),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
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
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              coursesData[i]['type'] ==
                                                                      0
                                                                  ? "${coursesData[i]['pages']} slides"
                                                                  // Static value for PDF
                                                                  : "${coursesData[i]['formatted_duration']} min",
                                                              // Static value for Video
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    globalFontFamily,
                                                                fontSize:
                                                                    globalFontSizeChange >=
                                                                            17
                                                                        ? (globalFontSizeChange /
                                                                                5) +
                                                                            12
                                                                        : 12 -
                                                                            (globalFontSizeChange /
                                                                                5),
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
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        // Rating
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.amber,
                                                              size: 14,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              ((coursesData[i]['rating'] ==
                                                                          null)
                                                                      ? "0"
                                                                      : (newCTRLRating ==
                                                                          null)
                                                                      ? coursesData[i]['rating']
                                                                          .toString()
                                                                      : newCTRLRating
                                                                          .toString())
                                                                  .tr,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    globalFontFamily,
                                                                fontSize:
                                                                    globalFontSizeChange >=
                                                                            17
                                                                        ? (globalFontSizeChange /
                                                                                5) +
                                                                            12
                                                                        : 12 -
                                                                            (globalFontSizeChange /
                                                                                5),
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
                                                            const SizedBox(
                                                              width: 30,
                                                            ),
                                                            Container(
                                                              width: 24,
                                                              height: 24,
                                                              decoration: BoxDecoration(
                                                                gradient: const LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                      0xFF4F8EF7,
                                                                    ),
                                                                    Color(
                                                                      0xFF2563EB,
                                                                    ),
                                                                  ],
                                                                  begin:
                                                                      Alignment
                                                                          .topLeft,
                                                                  end:
                                                                      Alignment
                                                                          .bottomRight,
                                                                ),
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                          0.15,
                                                                        ),
                                                                    blurRadius:
                                                                        3,
                                                                    offset:
                                                                        const Offset(
                                                                          0,
                                                                          1,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: IconButton(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                iconSize: 14,
                                                                icon: const Icon(
                                                                  Icons
                                                                      .bookmark_add_outlined,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                                onPressed: () {
                                                                  final watchlist =
                                                                      Get.find<
                                                                        WatchlistController
                                                                      >();
                                                                  watchlist.toggleLectureWatchlist(
                                                                    coursesData[i]['id']
                                                                        .toString(),
                                                                    (coursesData[i]['name'] ??
                                                                            '')
                                                                        .toString(),
                                                                    '',
                                                                  );
                                                                  Get.snackbar(
                                                                    'Watchlist',
                                                                    'Toggled',
                                                                    snackPosition:
                                                                        SnackPosition
                                                                            .BOTTOM,
                                                                    duration:
                                                                        const Duration(
                                                                          seconds:
                                                                              1,
                                                                        ),
                                                                  );
                                                                },
                                                                tooltip:
                                                                    'Add to Watchlist',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Column(
                                                  //   children: [
                                                  //     IconButton(
                                                  //       onPressed: () async {
                                                  //         showRatingDailog(
                                                  //           context,
                                                  //           coursesData[i]["id"],
                                                  //           token,
                                                  //           "$mainIP/api/ratelecture/${coursesData[i]["id"]}",
                                                  //           () {
                                                  //             setState(() {
                                                  //               newFeaturedRating =
                                                  //                   newRatingData;
                                                  //               newUserRating =
                                                  //                   userRating;
                                                  //               ratedCourses[coursesData[i]["id"]] =
                                                  //                   true;
                                                  //             });
                                                  //           },
                                                  //           1.0,
                                                  //         );
                                                  //         print(
                                                  //           "${coursesData[i]["id"]}",
                                                  //         );
                                                  //       },
                                                  //       icon: Icon(
                                                  //         ratedCourses[coursesData[i]["id"]] ==
                                                  //                 true
                                                  //             ? Icons
                                                  //                 .star_outlined
                                                  //             : Icons
                                                  //                 .star_border_outlined,
                                                  //       ),
                                                  //       color: Colors.blue,
                                                  //       iconSize: 25,
                                                  //     ),
                                                  //     Text(
                                                  //       ratedCourses[coursesData[i]["id"]] ==
                                                  //               true
                                                  //           ? newUserRating
                                                  //               .toString()
                                                  //               .tr
                                                  //           : "Rate This".tr,
                                                  //       style: TextStyle(
                                                  //         fontFamily:
                                                  //             globalFontFamily,
                                                  //         color: Colors.blue,
                                                  //         fontSize:
                                                  //             globalFontSizeChange >=
                                                  //                     17
                                                  //                 ? (globalFontSizeChange /
                                                  //                         5) +
                                                  //                     12
                                                  //                 : 12 -
                                                  //                     (globalFontSizeChange /
                                                  //                         5),
                                                  //         fontWeight:
                                                  //             FontWeight.w400,
                                                  //       ),
                                                  //     ),
                                                  //   ],
                                                  // ),
                                                  const SizedBox(width: 10),
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
                                                          onPressed: () async {
                                                            await getSubscription(
                                                              lectureId,
                                                            );

                                                            int ID =
                                                                coursesData[i]['id'];
                                                            if (isLectureSubscribed ==
                                                                true) {
                                                              Get.to(
                                                                QuizScreen(
                                                                  lessonId:
                                                                      ID.toString(),
                                                                ),
                                                              );
                                                            } else {
                                                              Get.rawSnackbar(
                                                                titleText: Text(
                                                                  "Not subscribed!"
                                                                      .tr,
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        globalFontFamily,
                                                                    color:
                                                                        Color.fromARGB(
                                                                          255,
                                                                          40,
                                                                          41,
                                                                          61,
                                                                        ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        globalFontSizeChange <=
                                                                                17
                                                                            ? (globalFontSizeChange /
                                                                                    5) +
                                                                                18
                                                                            : 18 -
                                                                                (globalFontSizeChange /
                                                                                    5),
                                                                  ),
                                                                ),
                                                                messageText: Text(
                                                                  'Contact the support team for instructions on how to subscribe to the course/subject first.'
                                                                      .tr,
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        globalFontFamily,
                                                                    color:
                                                                        Color.fromARGB(
                                                                          255,
                                                                          40,
                                                                          41,
                                                                          61,
                                                                        ),
                                                                  ),
                                                                ),
                                                                isDismissible:
                                                                    true,
                                                                snackPosition:
                                                                    SnackPosition
                                                                        .BOTTOM,
                                                                duration:
                                                                    const Duration(
                                                                      seconds:
                                                                          3,
                                                                    ),
                                                                backgroundColor:
                                                                    Color.fromARGB(
                                                                      255,
                                                                      210,
                                                                      209,
                                                                      224,
                                                                    ),
                                                                icon: FaIcon(
                                                                  FontAwesomeIcons
                                                                      .ban,
                                                                  size: 30,
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        40,
                                                                        41,
                                                                        61,
                                                                      ),
                                                                ),
                                                                margin:
                                                                    const EdgeInsets.all(
                                                                      5,
                                                                    ),
                                                                borderRadius: 5,
                                                                borderColor:
                                                                    Color.fromARGB(
                                                                      255,
                                                                      40,
                                                                      41,
                                                                      61,
                                                                    ),
                                                              );
                                                            }
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
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        "Quiz".tr,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              globalFontFamily,
                                                          fontSize:
                                                              globalFontSizeChange >=
                                                                      17
                                                                  ? (globalFontSizeChange /
                                                                          5) +
                                                                      10
                                                                  : 10 -
                                                                      (globalFontSizeChange /
                                                                          5),
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
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: Divider(height: 30, thickness: 1),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        "Sources".tr,
                                        style: TextStyle(
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
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      18
                                                  : 18 -
                                                      (globalFontSizeChange /
                                                          5),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                          ),
                                      itemCount:
                                          (widget.CoursesData['sources']
                                                  as List)
                                              .length,
                                      itemBuilder: (context, index) {
                                        final source =
                                            widget
                                                .CoursesData['sources'][index];

                                        return TextButton(
                                          onPressed: () async {
                                            await _launchURL(source["link"]);
                                          },
                                          child: Text(
                                            source["name"].toString().tr,
                                            style: TextStyle(
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
                                              fontSize:
                                                  globalFontSizeChange <= 17
                                                      ? (globalFontSizeChange /
                                                              5) +
                                                          16
                                                      : 16 -
                                                          (globalFontSizeChange /
                                                              5),
                                              fontWeight: FontWeight.w400,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
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
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 30),
                                  ],
                                ),
                              )
                              : Container(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        "What Will You Learn".tr,
                                        style: TextStyle(
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
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      18
                                                  : 18 -
                                                      (globalFontSizeChange /
                                                          5),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(
                                        left: 5,
                                        top: 10,
                                      ),
                                      child: Text(
                                        "${widget.CoursesData['description']}"
                                            .tr,
                                        style: TextStyle(
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
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      16
                                                  : 16 -
                                                      (globalFontSizeChange /
                                                          5),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: Divider(height: 20, thickness: 1),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        "Requirements".tr,
                                        style: TextStyle(
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
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      18
                                                  : 18 -
                                                      (globalFontSizeChange /
                                                          5),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(
                                        left: 5,
                                        top: 10,
                                      ),
                                      child: Text(
                                        "${widget.CoursesData['requirements']}"
                                            .tr,
                                        style: TextStyle(
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
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      16
                                                  : 16 -
                                                      (globalFontSizeChange /
                                                          5),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: Divider(height: 20, thickness: 1),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 5),
                                        Text(
                                          "Subscriptions:".tr,
                                          style: TextStyle(
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
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        18
                                                    : 18 -
                                                        (globalFontSizeChange /
                                                            5),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        const SizedBox(width: 10),
                                        Text(
                                          widget.CoursesData['subscriptions']
                                              .toString()
                                              .tr,
                                          style: TextStyle(
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
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        16
                                                    : 16 -
                                                        (globalFontSizeChange /
                                                            5),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 20,
                                      ),
                                      // child: Divider(height: 20, thickness: 1),
                                    ),

                                    Center(
                                      child: SizedBox(
                                        width: 130,
                                        height: 45,
                                        child: MaterialButton(
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
                                          textColor:
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

                                          onPressed: () async {
                                            // await networkController
                                            //     .checkConnectivityManually();
                                            isConnected = sharedPrefs.prefs
                                                .getBool('isConnected');
                                            if (isConnected == true) {
                                              SubscribeToCourse(
                                                widget.CoursesData['id']
                                                    .toString(),
                                              );
                                            } else {
                                              Get.snackbar(
                                                "Connection error".tr,
                                                "Connection access is needed"
                                                    .tr,
                                              );
                                            }
                                          },
                                          child: Text(
                                            "Subscribe with Sparkies".tr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: globalFontFamily,
                                              fontSize:
                                                  globalFontSizeChange <= 17
                                                      ? (globalFontSizeChange /
                                                              5) +
                                                          14
                                                      : 14 -
                                                          (globalFontSizeChange /
                                                              5),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Container(
                                    //   padding: const EdgeInsets.only(left: 5),
                                    //   child: Text(
                                    //     "Available Languages".tr,
                                    //     style: TextStyle(
                                    //       fontFamily: globalFontFamily,
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
                                    //       fontSize:
                                    //           globalFontSizeChange <= 17
                                    //               ? (globalFontSizeChange / 5) +
                                    //                   18
                                    //               : 18 -
                                    //                   (globalFontSizeChange / 5),
                                    //       fontWeight: FontWeight.w500,
                                    //     ),
                                    //   ),
                                    // ),

                                    // Container(
                                    //   padding: const EdgeInsets.only(left: 5, top: 10),
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
                                    //       fontSize:  globalFontSizeChange <= 17 ?(globalFontSizeChange/5) + 16 :   16- (globalFontSizeChange / 5),
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
      ),
    )
    // )
    ;
  }
}
