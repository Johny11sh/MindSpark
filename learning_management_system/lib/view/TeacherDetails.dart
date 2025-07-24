// ignore_for_file: non_constant_identifier_names, file_names, unnecessary_null_comparison

import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:url_launcher/url_launcher.dart';
// import '../controller/NetworkController.dart';
import '../controller/FavoriteController.dart';
import '../core/constants/ImageAssets.dart';
import '../locale/LocaleController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/SharedPrefs.dart';
import 'NavBar.dart';

class TeacherDetails extends StatefulWidget {
  final Map<String, dynamic> TeacherData;

  final Uint8List? teacherImage;

  const TeacherDetails({
    super.key,
    required this.TeacherData,
    required this.teacherImage,
  });

  @override
  State<TeacherDetails> createState() => _TeacherDetailsState();
}

class _TeacherDetailsState extends State<TeacherDetails> {
  String ChosenScreen = "About";
  bool isRated = false;

  // --- Teacher's Courses State ---
  List<Map<String, dynamic>> teacherCourses = [];
  final Map<int, Uint8List> coursesImages = {};
  bool isCoursesLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeacherCourses();
  }

  Future<void> _fetchTeacherCourses() async {
    setState(() { isCoursesLoading = true; });
    try {
      final sharedPrefs = await SharedPrefs.instance;
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) {
        setState(() { isCoursesLoading = false; });
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
        var baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: mainIP);
        final APIurl = '$baseUrl/api/getteachercourses/${widget.TeacherData['id']}';
        final response = await http.get(
          Uri.parse(APIurl),
          headers: {
            'Authorization': "Bearer $token",
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final List<dynamic> coursesList =
            responseBody is List ? responseBody : (responseBody['courses'] ?? [responseBody]);
          setState(() {
            teacherCourses = List<Map<String, dynamic>>.from(coursesList);
          });
          await sharedPrefs.prefs.setString(cacheKey, jsonEncode(teacherCourses));
          // Cache images
          for (final course in teacherCourses) {
            final imageKey = 'course_image_${course['id']}';
            if (!sharedPrefs.prefs.containsKey(imageKey)) {
              final imageUrl = course['image_url'];
              if (imageUrl != null && imageUrl.isNotEmpty) {
                try {
                  final imgResp = await http.get(Uri.parse(imageUrl));
                  if (imgResp.statusCode == 200) {
                    await sharedPrefs.prefs.setString(imageKey, base64Encode(imgResp.bodyBytes));
                    setState(() {
                      coursesImages[course['id']] = imgResp.bodyBytes;
                    });
                  }
                } catch (_) {}
              }
            } else {
              setState(() {
                coursesImages[course['id']] = base64Decode(sharedPrefs.prefs.getString(imageKey)!);
              });
            }
          }
        }
      }
    } catch (e) {
      // ignore
    }
    setState(() { isCoursesLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();
    Uint8List? imageBytes = widget.teacherImage;

    final featuredRatings =
        widget.TeacherData["FeaturedRatings"] as List<dynamic>? ?? [];

    // Calculate total reviews
    final totalReviews =
        (int.tryParse(widget.TeacherData["rating_breakdown"]["5"].toString()) ??
            0) +
        (int.tryParse(widget.TeacherData["rating_breakdown"]["4"].toString()) ??
            0) +
        (int.tryParse(widget.TeacherData["rating_breakdown"]["3"].toString()) ??
            0) +
        (int.tryParse(widget.TeacherData["rating_breakdown"]["2"].toString()) ??
            0) +
        (int.tryParse(widget.TeacherData["rating_breakdown"]["1"].toString()) ??
            0);

    Widget buildRatingBar(int rating) {
      final count =
          int.tryParse(
            widget.TeacherData["rating_breakdown"][rating.toString()]
                .toString(),
          ) ??
          0;
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

    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // appBar: AppBar(title: Text("Teacher Profile".tr), centerTitle: true),
        body:
            widget.TeacherData == null || widget.TeacherData.isEmpty
                ? Center(
                  child: CircularProgressIndicator(
                    color:
                        themeController.initialTheme == Themes.customLightTheme
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
                        Container(
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
                                    "Teacher".tr,
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
                                          controller.toggleFavoriteC(
                                            widget.TeacherData["id"].toString(),
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
                                height: Get.height / 3.005,
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
                                      padding: EdgeInsets.only(top: 20),
                                      alignment: Alignment.topCenter,
                                      child: CircleAvatar(
                                        backgroundColor: Color.fromARGB(
                                          255,
                                          40,
                                          41,
                                          61,
                                        ),
                                        radius: 60,
                                        child:
                                            imageBytes != null
                                                ? Image.memory(
                                                  imageBytes,
                                                  width: Get.width * (2 / 10),
                                                  height: Get.width * (2 / 10),
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Image.asset(
                                                      ImageAssets.teacher,
                                                      // height: 125,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                                : Image.asset(
                                                  ImageAssets.teacher,
                                                  width: Get.width * (2 / 10),
                                                  height: Get.width * (2 / 10),
                                                  fit: BoxFit.cover,
                                                ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "${widget.TeacherData["name"]}".tr,
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
                                    SizedBox(height: 10),
                                    Text(
                                      "${widget.TeacherData["major"]}".tr,
                                      style: TextStyle(
                                        fontSize: 20,
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
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        widget.TeacherData["Facebook"] == null
                                            ? SizedBox()
                                            : IconButton(
                                              onPressed: () async {
                                                _launchURL(
                                                  widget
                                                      .TeacherData["Facebook"],
                                                );
                                              },
                                              icon: FaIcon(
                                                FontAwesomeIcons.facebook,
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
                                        widget.TeacherData["Telegram"] == null
                                            ? SizedBox()
                                            : IconButton(
                                              onPressed: () async {
                                                _launchURL(
                                                  widget
                                                      .TeacherData["Telegram"],
                                                );
                                              },
                                              icon: FaIcon(
                                                FontAwesomeIcons.telegram,
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
                                        widget.TeacherData["YouTube"] == null
                                            ? SizedBox()
                                            : IconButton(
                                              onPressed: () async {
                                                _launchURL(
                                                  widget.TeacherData["YouTube"],
                                                );
                                              },
                                              icon: FaIcon(
                                                FontAwesomeIcons.youtube,
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
                                        widget.TeacherData["WhatsApp"] == null
                                            ? SizedBox()
                                            : IconButton(
                                              onPressed: () async {
                                                _launchURL(
                                                  widget
                                                      .TeacherData["WhatsApp"],
                                                );
                                              },
                                              icon: FaIcon(
                                                FontAwesomeIcons.whatsapp,
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
                                            onPressed: () {},
                                            icon: Icon(
                                              isRated == true
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
                                                "${widget.TeacherData["rating"].toString()}",
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
                                    itemCount: featuredRatings.length,
                                    itemBuilder: (context, index) {
                                      final review =
                                          featuredRatings[index]
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
                            : ChosenScreen == "Courses"
                            ? Container(
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
                                          SizedBox(width: 5),
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
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),

                                          SizedBox(width: 10),
                                          Text(
                                            "${widget.TeacherData['coursesNum'].toString()}"
                                                .tr,
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
                                          "My Courses".tr,
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
                                      SizedBox(height: 10),
                                      isCoursesLoading
                                        ? Center(child: CircularProgressIndicator())
                                        : teacherCourses.isEmpty
                                          ? Center(child: Text("No courses found".tr,style: TextStyle(color: themeController.initialTheme == Themes.customLightTheme
                                                                  ? Color.fromARGB(255, 40, 41, 61)
                                                                  : Color.fromARGB(255, 210, 209, 224),),))
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              physics: AlwaysScrollableScrollPhysics(),
                                              itemCount: teacherCourses.length,
                                              itemBuilder: (context, i) {
                                                final course = teacherCourses[i];
                                                final imageBytes = coursesImages[course['id']];
                                                return Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: themeController.initialTheme == Themes.customLightTheme
                                                        ? Color.fromARGB(255, 210, 209, 224)
                                                        : Color.fromARGB(255, 40, 41, 61),
                                                    borderRadius: BorderRadius.circular(12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: themeController.initialTheme == Themes.customLightTheme
                                                                  ? Color.fromARGB(255, 40, 41, 61)
                                                                  : Color.fromARGB(255, 210, 209, 224),
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
                                                        margin: EdgeInsets.all(8),
                                                        child: imageBytes != null
                                                          ? Image.memory(imageBytes, fit: BoxFit.cover)
                                                          : Image.asset(ImageAssets.book, fit: BoxFit.cover),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              course['name'] ?? '',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600,
                                                                color: themeController.initialTheme == Themes.customLightTheme
                                                                  ? Color.fromARGB(255, 40, 41, 61)
                                                                  : Color.fromARGB(255, 210, 209, 224),
                                                              ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              'Type: Course',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: themeController.initialTheme == Themes.customLightTheme
                                                                  ? Color.fromARGB(255, 40, 41, 61)
                                                                  : Color.fromARGB(255, 210, 209, 224),
                                                              ),
                                                            ),
                                                            SizedBox(height: 4),
                                                            Text(
                                                              'Duration: --',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: themeController.initialTheme == Themes.customLightTheme
                                                                  ? Color.fromARGB(255, 40, 41, 61)
                                                                  : Color.fromARGB(255, 210, 209, 224),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            : Container(
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
                                        padding: EdgeInsets.only(left: 5),
                                        child: Text(
                                          "About Me".tr,
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
                                        padding: EdgeInsets.only(
                                          left: 5,
                                          top: 10,
                                        ),
                                        child: Text(
                                          "${widget.TeacherData['description']}"
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
                                      SizedBox(height: 20),
                                      Container(
                                        padding: EdgeInsets.only(left: 5),
                                        child: Text(
                                          "My Courses".tr,
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
                                        padding: EdgeInsets.only(
                                          left: 5,
                                          top: 10,
                                        ),
                                        child: Text(
                                          "${widget.TeacherData['courses']}".tr,
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
                                      SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(width: 5),
                                          Text(
                                            "Students:".tr,
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
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),

                                          SizedBox(width: 10),
                                          Text(
                                            "${widget.TeacherData['UserSubs'].toString()}"
                                                .tr,
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
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(width: 5),
                                          Text(
                                            "Number:".tr,
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
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),

                                          SizedBox(width: 10),
                                          Text(
                                            "0${widget.TeacherData['number'].toString()}"
                                                .tr,
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
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 60),
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
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}
