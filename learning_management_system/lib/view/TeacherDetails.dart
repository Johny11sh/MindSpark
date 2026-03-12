// ignore_for_file: non_constant_identifier_names, file_names, unnecessary_null_comparison, dead_code

import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:learning_management_system/view/CoursesLessons.dart';
import 'package:like_button/like_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/FavoriteController.dart';
import '../controller/ProfileController.dart';
import '../core/classes/ReviewsPage.dart';
import '../core/constants/FontGlobals.dart';
import '../controller/LikesController.dart';
import '../controller/NetworkController.dart';
import '../core/constants/ImageAssets.dart';
import '../core/function/CustomRatingDialog.dart';
import '../core/function/buildRatingBar.dart';
import '../core/function/noDataLottie.dart';
import '../locale/LocaleController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/SharedPrefs.dart';
import 'NavBar.dart';
import 'OnBoarding.dart';

class TeacherDetails extends StatefulWidget {
  final Map<String, dynamic> TeacherData;

  const TeacherDetails({super.key, required this.TeacherData});

  @override
  State<TeacherDetails> createState() => _TeacherDetailsState();
}

class _TeacherDetailsState extends State<TeacherDetails> {
  String ChosenScreen = "About";
  final NetworkController networkController = Get.find<NetworkController>();
  final TextEditingController reportController = TextEditingController();
  final LikesController likesController = LikesController();
  final ProfileController profileController = Get.find<ProfileController>();

  bool isRated = false;
  bool report1 = false;
  bool report2 = false;
  bool report3 = false;
  List<String> ReportList = [];

  Map<int, bool> ratedTeachers = {};

  double? newUserRating;
  List<Map<String, dynamic>> newFeaturedRating = [];
  Map<String, dynamic> newBreakingDown = {};
  String? newCTRLRating;

  bool? isConnected;
  // late bool IsHelpful;
  // late bool IsUnHelpful;
  Map<int, bool> helpfulStates = {};
  Map<int, bool> unhelpfulStates = {};
  List<Map<String, dynamic>> teacherCourses = [];
  final Map<int, Uint8List> coursesImages = {};
  bool isCoursesLoading = true;

  Set<int> expandedReviews = {};
  late String token;

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

  Future<void> loadRatedLessons() async {
    final storedMap = await sharedPrefs.loadMap("ratedTeachers");
    setState(() {
      ratedTeachers = storedMap;
    });
  }

  @override
  void initState() {
    super.initState();
    Animations();
    token = sharedPrefs.prefs.getString("token")!;
    profileController.getProfileData();

    _fetchTeacherCourses();
    likesController.onInit();
    loadRatedLessons();
  }

  Future<void> _fetchTeacherCourses() async {
    setState(() {
      isCoursesLoading = true;
    });
    try {
      final sharedPrefs = SharedPrefs.instance;
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() {
          isCoursesLoading = false;
        });
        return;
      }
      final cacheKey = 'cached_courses_${widget.TeacherData['id']}';
      final cachedData = sharedPrefs.prefs.getString(cacheKey);
      if (cachedData != null) {
        final List<dynamic> parsedList = jsonDecode(cachedData);
        setState(() {
          teacherCourses = List<Map<String, dynamic>>.from(parsedList);
        });
        // Load cached images
        for (final course in teacherCourses) {
          final imageKey = 'course_image_${course['id']}';
          final imageString = sharedPrefs.prefs.getString(imageKey);
          if (imageString != null && mounted) {
            setState(() {
              coursesImages[course['id']] = base64Decode(imageString);
            });
          }
        }
      }
      // Fetch from API if online
      if (sharedPrefs.prefs.getBool('isConnected') == true) {
        var baseUrl = String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: mainIP,
        );
        final APIurl =
            '$baseUrl/api/getteachercourses/${widget.TeacherData['id']}';
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
          final List<dynamic> coursesList =
              responseBody is List
                  ? responseBody
                  : (responseBody['courses'] ?? [responseBody]);
          setState(() {
            teacherCourses = List<Map<String, dynamic>>.from(coursesList);
          });
          await sharedPrefs.prefs.setString(
            cacheKey,
            jsonEncode(teacherCourses),
          );
          // Cache images
          for (final course in teacherCourses) {
            final imageKey = 'course_image_${course['id']}';
            if (!sharedPrefs.prefs.containsKey(imageKey)) {
              final imageUrl = course['image_url'];
              if (imageUrl != null && imageUrl.isNotEmpty) {
                try {
                  final imgResp = await http.get(Uri.parse(imageUrl));
                  if (imgResp.statusCode == 200) {
                    await sharedPrefs.prefs.setString(
                      imageKey,
                      base64Encode(imgResp.bodyBytes),
                    );
                    setState(() {
                      coursesImages[course['id']] = imgResp.bodyBytes;
                    });
                  }
                } catch (_) {}
              }
            } else {
              setState(() {
                coursesImages[course['id']] = base64Decode(
                  sharedPrefs.prefs.getString(imageKey)!,
                );
              });
            }
          }
        }
      }
    } catch (e) {
      // ignore
    }
    setState(() {
      isCoursesLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();

    final featuredRatings =
        widget.TeacherData["FeaturedRatings"] as List<dynamic>? ?? [];

    var ratingBreakdown = widget.TeacherData["rating_breakdown"] ?? {};
    if (newBreakingDown.isNotEmpty) {
      ratingBreakdown = newBreakingDown;
    }

    newUserRating =
        widget.TeacherData['user_rating'] != null
            ? double.tryParse(widget.TeacherData['user_rating'].toString())
            : 0;

    final totalReviews =
        (int.tryParse(ratingBreakdown["5"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["4"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["3"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["2"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["1"].toString()) ?? 0);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: MaterialApp(
        theme: themeController.initialTheme,
        locale: localeController.initialLang,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body:
              widget.TeacherData == null || widget.TeacherData.isEmpty
                  ? Center(
                    child: CircularProgressIndicator(
                      color:
                          themeController.initialTheme ==
                                  Themes.customLightTheme
                              ? Color.fromARGB(255, 40, 41, 61)
                              : Color.fromARGB(255, 210, 209, 224),
                    ),
                  )
                  : ListView(
                    scrollDirection: Axis.vertical,
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: Get.height / 2.5,

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
                                    Text(
                                          "Teacher".tr,
                                          textAlign: TextAlign.center,
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
                                            fontWeight: FontWeight.w500,
                                            fontFamily: globalFontFamily,
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
                                    GetBuilder<FavoriteController>(
                                      builder: (controller) {
                                        final isFav =
                                            controller.isFavorite[widget
                                                .TeacherData["id"]
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
                                            controller.toggleFavorite(
                                              widget.TeacherData["id"]
                                                  .toString(),
                                            );
                                            return !isLiked;
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: Get.width,
                                  height: Get.height / 3.005,
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
                                      (teacherCourses.isEmpty)
                                          ? noDataLottie("No data available")
                                          : Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(
                                                  top: 20,
                                                ),
                                                alignment: Alignment.topCenter,
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                        255,
                                                        40,
                                                        41,
                                                        61,
                                                      ),
                                                  radius: 60,
                                                  child:
                                                      widget.TeacherData["image"] !=
                                                              null
                                                          ? CachedNetworkImage(
                                                            imageUrl:
                                                                "$mainIP/${widget.TeacherData['image']}",
                                                            // height: 60,
                                                            // width: 60,
                                                            fit: BoxFit.fill,
                                                          )
                                                          : Image.asset(
                                                            ImageAssets.teacher,
                                                            // width:
                                                            //     Get.width *
                                                            //     (2 / 10),
                                                            // height:
                                                            //     Get.width *
                                                            //     (2 / 10),
                                                            fit: BoxFit.fill,
                                                          ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                    "${widget.TeacherData["name"]}"
                                                        .tr,
                                                    style: TextStyle(
                                                      fontSize:
                                                          globalFontSizeChange <=
                                                                  17
                                                              ? (globalFontSizeChange /
                                                                      5) +
                                                                  22
                                                              : 22 -
                                                                  (globalFontSizeChange /
                                                                      5),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily:
                                                          globalFontFamily,
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
                                                  )
                                                  .animate()
                                                  .fadeIn(duration: 400.ms)
                                                  .blurXY(begin: 5, end: 0)
                                                  .slideY(begin: 0.3, end: 0),
                                              const SizedBox(height: 10),
                                              Text(
                                                    "${widget.TeacherData["major"]}"
                                                        .tr,
                                                    style: TextStyle(
                                                      fontSize:
                                                          globalFontSizeChange <=
                                                                  17
                                                              ? (globalFontSizeChange /
                                                                      5) +
                                                                  20
                                                              : 20 -
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
                                                      fontFamily:
                                                          globalFontFamily,
                                                    ),
                                                  )
                                                  .animate()
                                                  .fadeIn(duration: 400.ms)
                                                  .blurXY(begin: 5, end: 0)
                                                  .slideY(begin: 0.3, end: 0),
                                              const SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  widget.TeacherData["Facebook"] ==
                                                          null
                                                      ? const SizedBox()
                                                      : IconButton(
                                                        onPressed: () async {
                                                          _launchURL(
                                                            widget
                                                                .TeacherData["Facebook"],
                                                          );
                                                        },
                                                        icon: FaIcon(
                                                          FontAwesomeIcons
                                                              .facebook,
                                                          size: 40,
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
                                                  widget.TeacherData["Instagram"] ==
                                                          null
                                                      ? const SizedBox()
                                                      : IconButton(
                                                        onPressed: () async {
                                                          _launchURL(
                                                            widget
                                                                .TeacherData["Instagram"],
                                                          );
                                                        },
                                                        icon: FaIcon(
                                                          FontAwesomeIcons
                                                              .instagram,
                                                          size: 40,
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
                                                  widget.TeacherData["Telegram"] ==
                                                          null
                                                      ? const SizedBox()
                                                      : IconButton(
                                                        onPressed: () async {
                                                          _launchURL(
                                                            widget
                                                                .TeacherData["Telegram"],
                                                          );
                                                        },
                                                        icon: FaIcon(
                                                          FontAwesomeIcons
                                                              .telegram,
                                                          size: 40,
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
                                                  widget.TeacherData["YouTube"] ==
                                                          null
                                                      ? const SizedBox()
                                                      : IconButton(
                                                        onPressed: () async {
                                                          _launchURL(
                                                            widget
                                                                .TeacherData["YouTube"],
                                                          );
                                                        },
                                                        icon: FaIcon(
                                                          FontAwesomeIcons
                                                              .youtube,
                                                          size: 40,
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
                                                  widget.TeacherData["WhatsApp"] ==
                                                          null
                                                      ? const SizedBox()
                                                      : IconButton(
                                                        onPressed: () async {
                                                          _launchURL(
                                                            widget
                                                                .TeacherData["WhatsApp"],
                                                          );
                                                        },
                                                        icon: FaIcon(
                                                          FontAwesomeIcons
                                                              .whatsapp,
                                                          size: 40,
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
                                        fontFamily: globalFontFamily,
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
                                        ChosenScreen = "Courses";
                                      });
                                    },
                                    color:
                                        themeController.initialTheme ==
                                                Themes.customLightTheme
                                            ? Color.fromARGB(255, 210, 209, 224)
                                            : Color.fromARGB(255, 40, 41, 61),
                                    child: Text(
                                      "Courses",
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
                                        fontFamily: globalFontFamily,
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
                                        fontFamily: globalFontFamily,
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
                                          MainAxisAlignment.center,
                                      // spacing: 10,
                                      children: [
                                        StatefulBuilder(
                                          builder: (context, setDState) {
                                            bool isRated =
                                                ratedTeachers[widget
                                                    .TeacherData['id']] ??
                                                false;
                                            return Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    const SizedBox(width: 20),
                                                    Column(
                                                      children: [
                                                        IconButton(
                                                          onPressed: () async {
                                                            showRatingDailog(
                                                              context,
                                                              widget
                                                                  .TeacherData["id"],
                                                              token,
                                                              "$mainIP/api/rateteacher/${widget.TeacherData["id"]}",

                                                              () async {
                                                                setState(() {
                                                                  newUserRating =
                                                                      userRating;
                                                                  newFeaturedRating = List<
                                                                    Map<
                                                                      String,
                                                                      dynamic
                                                                    >
                                                                  >.from(
                                                                    newRatingData,
                                                                  );
                                                                  newBreakingDown =
                                                                      Map<
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
                                                                          .removeAt(
                                                                            0,
                                                                          );
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
                                                                          .removeAt(
                                                                            0,
                                                                          );
                                                                    }
                                                                  }
                                                                  widget.TeacherData['featuredRatings'] =
                                                                      featuredRatings;
                                                                  widget.TeacherData['rating_breakdown'] =
                                                                      newBreakingDown;
                                                                  widget.TeacherData['user_rating'] =
                                                                      newUserRating;
                                                                  widget.TeacherData['rating'] =
                                                                      newCTRLRating;

                                                                  ratedTeachers[widget
                                                                          .TeacherData["id"]] =
                                                                      true;
                                                                });
                                                                await sharedPrefs
                                                                    .saveMap(
                                                                      "ratedTeachers",
                                                                      ratedTeachers,
                                                                    );
                                                              },
                                                              newUserRating ??
                                                                  0,
                                                            );
                                                          },
                                                          icon: Icon(
                                                            (isRated)
                                                                ? Icons
                                                                    .star_outlined
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
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 50),
                                                    Icon(
                                                      Icons.star_outlined,
                                                      color: Colors.amber,
                                                      size: 25,
                                                    ),
                                                    Text(
                                                      "${(widget.TeacherData['rating'] == null)
                                                          ? "0"
                                                          : (newCTRLRating == null)
                                                          ? widget.TeacherData['rating'].toString()
                                                          : newCTRLRating.toString()}/5",
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
                                                        fontFamily:
                                                            globalFontFamily,
                                                        fontSize:
                                                            globalFontSizeChange <=
                                                                    17
                                                                ? (globalFontSizeChange /
                                                                        5) +
                                                                    22
                                                                : 22 -
                                                                    (globalFontSizeChange /
                                                                        5),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 20),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),

                                                Text(
                                                  "based on (${widget.TeacherData["ratings_count"].toString()}) reviews",
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
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
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
                                        widget.TeacherData["rating_breakdown"],
                                      ),
                                      const SizedBox(height: 6),
                                      buildRatingBar(
                                        4,
                                        _areBarsVisible,
                                        widget.TeacherData["rating_breakdown"],
                                      ),
                                      const SizedBox(height: 6),
                                      buildRatingBar(
                                        3,
                                        _areBarsVisible,
                                        widget.TeacherData["rating_breakdown"],
                                      ),
                                      const SizedBox(height: 6),
                                      buildRatingBar(
                                        2,
                                        _areBarsVisible,
                                        widget.TeacherData["rating_breakdown"],
                                      ),
                                      const SizedBox(height: 6),
                                      buildRatingBar(
                                        1,
                                        _areBarsVisible,
                                        widget.TeacherData["rating_breakdown"],
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
                                                    type: "getteacherratings",
                                                    sectionId:
                                                        widget
                                                            .TeacherData["id"],
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

                                  const SizedBox(height: 10),

                                  SizedBox(
                                    height:
                                        Get.height *
                                        0.6, // 40% of screen height, adjust as needed
                                    child: ListView.builder(
                                      physics: AlwaysScrollableScrollPhysics(),
                                      itemCount:
                                          widget
                                              .TeacherData["FeaturedRatings"]
                                              ?.length ??
                                          0,
                                      itemBuilder: (context, index) {
                                        // final review =
                                        //     widget.TeacherData["FeaturedRatings"]?[index]
                                        //         as Map<String, dynamic>? ??
                                        //     {};

                                        final review =
                                            featuredRatings[index]
                                                as Map<String, dynamic>? ??
                                            {};
                                        final reviewId = review['id'] ?? index;

                                        // Initialize state only if not present
                                        helpfulStates[reviewId] ??=
                                            review["isHelpful"] == true;
                                        unhelpfulStates[reviewId] ??=
                                            review["isUnhelpful"] == true;
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
                                              //     ratedTeachers[widget
                                              //         .TeacherData['id']] ??
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
                                                                            ? Colors.orangeAccent.shade400
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
                                                                                      'teacher_rating_id',
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
                                                                    "teacher_rating_id":
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
                                                                    "teacher_rating_id":
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
                              : ChosenScreen == "Courses"
                              ? SizedBox(
                                height: Get.height * 0.6,
                                child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(width: 5),
                                            Text(
                                              "Courses:".tr,
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
                                                fontFamily: globalFontFamily,
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
                                              widget.TeacherData['coursesNum']
                                                  .toString()
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
                                          ],
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                          ),
                                          child: Divider(
                                            height: 30,
                                            thickness: 1,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                            left: 5,
                                          ),
                                          child: Text(
                                            "My Courses".tr,
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
                                              fontSize:
                                                  globalFontSizeChange <= 17
                                                      ? (globalFontSizeChange /
                                                              5) +
                                                          18
                                                      : 18 -
                                                          (globalFontSizeChange /
                                                              5),
                                              fontFamily: globalFontFamily,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        isCoursesLoading
                                            ? Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                            : teacherCourses.isEmpty
                                            ? Center(
                                              child: Text(
                                                "No courses found".tr,
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
                                                ),
                                              ),
                                            )
                                            : ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  AlwaysScrollableScrollPhysics(),
                                              itemCount: teacherCourses.length,
                                              itemBuilder: (context, i) {
                                                final course =
                                                    teacherCourses[i];
                                                // final imageBytes =
                                                //     coursesImages[course['id']];
                                                return InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                CoursesLessons(
                                                                  CoursesData:
                                                                      course,
                                                                  index: i,
                                                                ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
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
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
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
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 80,
                                                          height: 80,
                                                          margin:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          child:
                                                              course["image"]! !=
                                                                      null
                                                                  ? Image.network(
                                                                    "$mainIP/${course["image"]!}",
                                                                    width:
                                                                        Get.width /
                                                                        2,
                                                                    height:
                                                                        Get.height *
                                                                        (1 / 6),
                                                                    fit:
                                                                        BoxFit
                                                                            .fill,
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
                                                                            (1 /
                                                                                6),
                                                                        fit:
                                                                            BoxFit.fill,
                                                                      );
                                                                    },
                                                                  )
                                                                  : Image.asset(
                                                                    ImageAssets
                                                                        .course,
                                                                    width:
                                                                        Get.width /
                                                                        2,
                                                                    height:
                                                                        Get.height *
                                                                        (1 / 6),
                                                                    fit:
                                                                        BoxFit
                                                                            .fill,
                                                                  ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                course['name'] ??
                                                                    '',
                                                                style: TextStyle(
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
                                                                          .w600,
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
                                                                ),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                'Type: Course',
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
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                'Duration: --',
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
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              : SizedBox(
                                height: Get.height * 0.8,
                                child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(
                                            left: 5,
                                          ),
                                          child: Text(
                                            "About Me".tr,
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
                                            top: 10,
                                          ),
                                          child: Text(
                                            "${widget.TeacherData['description']}"
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
                                        const Padding(
                                          padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                          ),
                                          child: Divider(
                                            height: 30,
                                            thickness: 1,
                                          ),
                                        ),
                                        // Container(
                                        //   padding: const EdgeInsets.only(
                                        //     left: 5,
                                        //   ),
                                        //   child: Text(
                                        //     "My Courses".tr,
                                        //     style: TextStyle(
                                        //       fontFamily: globalFontFamily,
                                        //       color:
                                        //           themeController
                                        //                       .initialTheme ==
                                        //                   Themes
                                        //                       .customLightTheme
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
                                        //               ? (globalFontSizeChange /
                                        //                       5) +
                                        //                   18
                                        //               : 18 -
                                        //                   (globalFontSizeChange /
                                        //                       5),
                                        //       fontWeight: FontWeight.w500,
                                        //     ),
                                        //   ),
                                        // ),

                                        // Container(
                                        //   padding: const EdgeInsets.only(
                                        //     left: 5,
                                        //     top: 10,
                                        //   ),
                                        //   child: Text(
                                        //     "${widget.TeacherData['courseNames']}"
                                        //         .tr,
                                        //     style: TextStyle(
                                        //       fontFamily: globalFontFamily,
                                        //       color:
                                        //           themeController
                                        //                       .initialTheme ==
                                        //                   Themes
                                        //                       .customLightTheme
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
                                        //               ? (globalFontSizeChange /
                                        //                       5) +
                                        //                   16
                                        //               : 16 -
                                        //                   (globalFontSizeChange /
                                        //                       5),
                                        //       fontWeight: FontWeight.w400,
                                        //     ),
                                        //   ),
                                        // ),
                                        // const Padding(
                                        //   padding: EdgeInsets.only(
                                        //     left: 20,
                                        //     right: 20,
                                        //   ),
                                        //   child: Divider(
                                        //     height: 30,
                                        //     thickness: 1,
                                        //   ),
                                        // ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(width: 5),
                                            Text(
                                              "Students:".tr,
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

                                            const SizedBox(width: 10),
                                            Text(
                                              widget.TeacherData['UserSubs']
                                                  .toString()
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
                                          ],
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                          ),
                                          child: Divider(
                                            height: 30,
                                            thickness: 1,
                                          ),
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(width: 5),
                                            Text(
                                              "Number:".tr,
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

                                            const SizedBox(width: 10),
                                            Text(
                                              "0${widget.TeacherData['number'].toString()}"
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
                                          ],
                                        ),
                                        const SizedBox(height: 60),
                                      ],
                                    ),
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
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}
