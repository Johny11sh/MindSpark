// ignore_for_file: file_names, non_constant_identifier_names, unnecessary_null_comparison, avoid_print, unused_element

import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';

import '../controller/FontController.dart';
import '../controller/ProfileController.dart';
import '../controller/WatchlistController.dart';
import '../core/classes/QuizScreen.dart';
import 'package:like_button/like_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/FavoriteController.dart';
import '../core/classes/PDFOpener.dart';
import '../core/function/CustomRatingDialog.dart';
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
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'NavBar.dart';
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
  final NetworkController networkController = Get.find<NetworkController>();
  late SharedPrefs sharedPrefs;

  ScrollController scrollController = ScrollController();
  var ChosenScreen = "About";
  bool downloading = false;
  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  String filePath = "";

  bool isPreparingPlayback = false;

  bool isRated = false;

  late int userRating;

  Map<int, bool> ratedLessons = {};

  List<Map<String, dynamic>> coursesData = [];
  bool? isLectureSubscribed = false;

  List<Map<String, dynamic>> recentLessonsData = [];

  List<Map<String, dynamic>> topRatedLessonsData = [];

  late String token;

  late FavoriteController favoriteController;
  final CacheManager cacheManager = CacheManager();

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
    widget.CoursesData["user_rating"] != null
        ? isRated = true
        : isRated = false;
    widget.CoursesData["user_rating"] != null
        ? userRating = widget.CoursesData["user_rating"]
        : userRating = 1;

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
        style: TextStyle(fontFamily: FontController().currentFontFamily),
      ),
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
    final ratingBreakdown = widget.CoursesData["rating_breakdown"] ?? {};
    final totalReviews =
        (int.tryParse(ratingBreakdown["5"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["4"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["3"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["2"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["1"].toString()) ?? 0);

    return Scaffold(
      body:
          (cacheManager.isCacheEnabled.value == false &&
                  sharedPrefs.prefs.getBool('isConnected') == false)
              ? Center(
                child: Lottie.asset(
                  ImageAssets.noDataLottie,
                  width: 300,
                  height: 300,
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
                                              ? Color.fromARGB(255, 40, 41, 61)
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
                                      fontFamily:
                                          FontController().currentFontFamily,
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
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 18,
                                          icon: const Icon(
                                            Icons.bookmark_add_outlined,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            final watchlist =
                                                Get.find<WatchlistController>();
                                            watchlist.toggleCourseWatchlist(
                                              widget.CoursesData['id']
                                                  .toString(),
                                              (widget.CoursesData['name'] ?? '')
                                                  .toString(),
                                              '',
                                            );
                                            Get.snackbar(
                                              'Watchlist',
                                              'Toggled',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              duration: const Duration(
                                                seconds: 1,
                                              ),
                                            );
                                          },
                                          tooltip: 'Add to Watchlist',
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
                                          widget.CoursesData["image"]! != null
                                              ? Image.network(
                                                widget.CoursesData["image"]!,
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
                                                    height: 225,
                                                    fit: BoxFit.cover,
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
                                    const SizedBox(height: 15),
                                    Text(
                                      "${widget.CoursesData["name"]}".tr,
                                      style: TextStyle(
                                        fontFamily:
                                            FontController().currentFontFamily,
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
                                    const SizedBox(height: 15),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Video lessons:".tr,
                                          style: TextStyle(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
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
                                        const SizedBox(width: 5),
                                        Text(
                                          "${widget.CoursesData["video_lectures_count"]}"
                                              .toString()
                                              .tr,
                                          style: TextStyle(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
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

                                        const SizedBox(width: 15),
                                        Text(
                                          "-",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall!.copyWith(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
                                            fontSize: 20,
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
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          "PDF lessons:".tr,
                                          style: TextStyle(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
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
                                        const SizedBox(width: 5),
                                        Text(
                                          "${widget.CoursesData["pdf_lessons_count"]}"
                                              .toString()
                                              .tr,
                                          style: TextStyle(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
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
                                      ],
                                    ),
                                    const SizedBox(height: 15),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Price:".tr,
                                          style: TextStyle(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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

                                        const SizedBox(width: 5),
                                        Text(
                                          "\$${widget.CoursesData["price"]}"
                                              .toString()
                                              .tr,
                                          style: TextStyle(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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
                                        const SizedBox(width: 10),
                                        Text(
                                          "-",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall!.copyWith(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
                                            fontSize: 20,
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
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Sparkies Price:',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall!.copyWith(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
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
                                            fontWeight: FontWeight.bold,
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
                                                FontController()
                                                    .currentFontFamily,
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
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "-",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall!.copyWith(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
                                            fontSize: 20,
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
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        Text(
                                          'My Sparkies:',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall!.copyWith(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
                                            fontSize: 12,
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
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "${profileController.profileData['sparkies'].toString()}/5"
                                              .toString(),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall!.copyWith(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
                                            fontSize: 12,
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
                                          ),
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
                                      fontFamily:
                                          FontController().currentFontFamily,
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
                                      fontFamily:
                                          FontController().currentFontFamily,
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
                                      fontFamily:
                                          FontController().currentFontFamily,
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
                        const SizedBox(height: 20),

                        ChosenScreen == "Reviews"
                            ? Column(
                              children: [
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 10,
                                    children: [
                                      const SizedBox(width: 20),
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
                                                userRating + 0.0,
                                              );
                                            },
                                            icon: Icon(
                                              isRated
                                                  ? Icons.star_outlined
                                                  : Icons.star_border_outlined,
                                            ),
                                            color: Colors.blue,
                                            iconSize: 30,
                                          ),
                                          Text(
                                            isRated == true
                                                ? "Edit Rating".tr
                                                : "Rate This".tr,
                                            style: TextStyle(
                                              fontFamily:
                                                  FontController()
                                                      .currentFontFamily,
                                              color: Colors.blue,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
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
                                                widget.CoursesData["rating"]
                                                    .toString(),
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontController()
                                                          .currentFontFamily,
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
                                            "based on (${totalReviews.toString()}) reviews",
                                            style: TextStyle(
                                              fontFamily:
                                                  FontController()
                                                      .currentFontFamily,
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
                                    const SizedBox(height: 6),
                                    buildRatingBar(4),
                                    const SizedBox(height: 6),
                                    buildRatingBar(3),
                                    const SizedBox(height: 6),
                                    buildRatingBar(2),
                                    const SizedBox(height: 6),
                                    buildRatingBar(1),
                                  ],
                                ),
                                const SizedBox(height: 10),
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

                                SizedBox(
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
                                      return SizedBox(
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
                                                              fontFamily:
                                                                  FontController()
                                                                      .currentFontFamily,
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
                                                                  fontFamily:
                                                                      FontController()
                                                                          .currentFontFamily,
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
                                                          fontFamily:
                                                              FontController()
                                                                  .currentFontFamily,
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
                                                        fontFamily:
                                                            FontController()
                                                                .currentFontFamily,
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
                                                        style:
                                                            TextButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                            ),
                                                        child: Text(
                                                          'Read more...',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                FontController()
                                                                    .currentFontFamily,
                                                          ),
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
                                                        style:
                                                            TextButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                            ),
                                                        child: Text(
                                                          'Show less',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                FontController()
                                                                    .currentFontFamily,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
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
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          "Total Videos Duration:".tr,
                                          style: TextStyle(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
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
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          "${widget.CoursesData['duration_formatted_long']}"
                                              .tr,
                                          style: TextStyle(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
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
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          "Total PDFs pages:".tr,
                                          style: TextStyle(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
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
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          "${widget.CoursesData['total_pdf_pages']}"
                                              .tr,
                                          style: TextStyle(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
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
                                      // Uint8List? imageBytes =
                                      //     lecturesImages[lectureId];

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
                                                  fontFamily:
                                                      FontController()
                                                          .currentFontFamily,
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
                                                  fontFamily:
                                                      FontController()
                                                          .currentFontFamily,
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
                                          margin: const EdgeInsets.symmetric(
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
                                                              fit: BoxFit.cover,
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
                                                              FontController()
                                                                  .currentFontFamily,
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
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
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
                                                                fontFamily:
                                                                    FontController()
                                                                        .currentFontFamily,
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
                                                                  FontController()
                                                                      .currentFontFamily,
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
                                                      const SizedBox(height: 4),
                                                      // Rating
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                            size: 14,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            "${coursesData[i]['rating']}"
                                                                .tr, // Static rating
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  FontController()
                                                                      .currentFontFamily,
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
                                                                  blurRadius: 3,
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
                                                              ratedLessons[coursesData[i]["id"]] =
                                                                  true;
                                                            });
                                                          },
                                                          1.0,
                                                        );
                                                        print(
                                                          "${coursesData[i]["id"]}",
                                                        );
                                                      },
                                                      icon: Icon(
                                                        ratedLessons[coursesData[i]["id"]] ==
                                                                true
                                                            ? Icons
                                                                .star_outlined
                                                            : Icons
                                                                .star_border_outlined,
                                                      ),
                                                      color: Colors.blue,
                                                      iconSize: 25,
                                                    ),
                                                    Text(
                                                      ratedLessons[coursesData[i]["id"]] ==
                                                              true
                                                          ? "Edit Rating".tr
                                                          : "Rate This".tr,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            FontController()
                                                                .currentFontFamily,
                                                        color: Colors.blue,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
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
                                                        onPressed: () {
                                                          int ID =
                                                              coursesData[i]['id'];
                                                          Get.to(
                                                            QuizScreen(
                                                              lessonId:
                                                                  ID.toString(),
                                                            ),
                                                          );
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
                                                            FontController()
                                                                .currentFontFamily,
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
                                        fontFamily:
                                            FontController().currentFontFamily,
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
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                        ),
                                    itemCount:
                                        (widget.CoursesData['sources'] as List)
                                            .length,
                                    itemBuilder: (context, index) {
                                      final source =
                                          widget.CoursesData['sources'][index];

                                      return TextButton(
                                        onPressed: () async {
                                          await _launchURL(source["link"]);
                                        },
                                        child: Text(
                                          source["name"].toString().tr,
                                          style: TextStyle(
                                            fontFamily:
                                                FontController()
                                                    .currentFontFamily,
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
                                        fontFamily:
                                            FontController().currentFontFamily,
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
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: Divider(height: 20, thickness: 1),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                      left: 5,
                                      top: 10,
                                    ),
                                    child: Text(
                                      "${widget.CoursesData['description']}".tr,
                                      style: TextStyle(
                                        fontFamily:
                                            FontController().currentFontFamily,
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
                                        fontFamily:
                                            FontController().currentFontFamily,
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
                                    padding: const EdgeInsets.only(
                                      left: 5,
                                      top: 10,
                                    ),
                                    child: Text(
                                      "${widget.CoursesData['requirements']}"
                                          .tr,
                                      style: TextStyle(
                                        fontFamily:
                                            FontController().currentFontFamily,
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
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: Divider(height: 20, thickness: 1),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 5),
                                      Text(
                                        "Subscriptions:".tr,
                                        style: TextStyle(
                                          fontFamily:
                                              FontController()
                                                  .currentFontFamily,
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

                                      const SizedBox(width: 10),
                                      Text(
                                        widget.CoursesData['subscriptions']
                                            .toString()
                                            .tr,
                                        style: TextStyle(
                                          fontFamily:
                                              FontController()
                                                  .currentFontFamily,
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
                                      "Available Languages".tr,
                                      style: TextStyle(
                                        fontFamily:
                                            FontController().currentFontFamily,
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
                fontFamily: FontController().currentFontFamily,
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
        const SizedBox(width: 10),
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
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              count.toString(),
              style: TextStyle(
                fontFamily: FontController().currentFontFamily,
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
