// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import '../../controller/LikesController.dart';
import '../../controller/NetworkController.dart';
import '../../controller/ProfileController.dart';
import '../../locale/LocaleController.dart';
import '../../services/CacheManager.dart';
import '../../services/SharedPrefs.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../view/LogIn.dart';
import '../../view/NavBar.dart';
import '../constants/FontGlobals.dart';

class ReviewsPage extends StatefulWidget {
  final String type;
  final int sectionId;

  const ReviewsPage({super.key, required this.type, required this.sectionId});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final ThemeController themeController = Get.find<ThemeController>();
  final ProfileController profileController = Get.find<ProfileController>();

  late LikesController likesController;

  Set<int> expandedReviews = {};
  final TextEditingController reportController = TextEditingController();
  final CacheManager cacheManager = CacheManager();
  final NetworkController networkController = Get.find<NetworkController>();

  late String token;
  late SharedPrefs sharedPrefs;
  Map<int, bool> ratedLessons = {};
  List<String> ReportList = [];

  bool report1 = false;
  bool report2 = false;
  bool report3 = false;
  bool? isConnected;
  late String helpfulType;
  Map<int, bool> helpfulStates = {};
  Map<int, bool> unhelpfulStates = {};
  List<Map<String, dynamic>> commentsData = [];

  Future<void> getReviewsData() async {
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
      final APIurl = '$baseUrl/api/${widget.type}/${widget.sectionId}';
      print('api url $APIurl');

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

        final List<dynamic> commentsDataList =
            responseBody is List
                ? responseBody
                : (responseBody['featuredRatings'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            commentsData = List<Map<String, dynamic>>.from(commentsDataList);
          });
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (commentsData.isEmpty) {
          throw Exception("Failed to load lectures: ${response.statusCode}");
        }
      }
    } on TimeoutException {
      if (commentsData.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      if (commentsData.isEmpty) {
        showErrorSnackbar("Failed to load lectures");
      } else {
        showErrorSnackbar("Using cached data - ${e.toString()}");
      }
      debugPrint("Error fetching lectures: $e");
    }
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getReviewsData();
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _initSharedPreferences().then((_) {
      profileController.getProfileData();

      cacheManager.init();
      networkController.onInit();
      print(widget.type);
      print('caching: ${cacheManager.isCacheEnabled.value}');
      print('connection: ${networkController.isConnected}');
      (cacheManager.isCacheEnabled.value == false &&
              networkController.isConnected == false)
          ? print('caching is disabled')
          : _loadInitialData();
    });
    likesController = Get.put(LikesController());
    token = sharedPrefs.prefs.getString("token")!;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    Get.find<LocaleController>();

    final featuredRatings = commentsData as List<dynamic>? ?? [];
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: Container(
          color:
              themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 30),
                height: 100,
                // color: Colors.red,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
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
                          padding: EdgeInsets.only(right: Get.width / 8),

                          child: Text(
                                "Reviews".tr,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  fontFamily: globalFontFamily,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 210, 209, 224)
                                          : Color.fromARGB(255, 40, 41, 61),
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      globalFontSizeChange <= 17
                                          ? (globalFontSizeChange / 5) + 23
                                          : 23 - (globalFontSizeChange / 5),
                                ),
                              )
                              .animate(
                                onPlay: (controller) => controller.loop(),
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
                  ],
                ),
              ),
              (commentsData.isEmpty)
                  ? Container(
                    height: Get.height / 1.32,
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
                    child: Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        "No Reviews",
                        style: TextStyle(
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                          fontSize:
                              globalFontSizeChange <= 17
                                  ? (globalFontSizeChange / 5) + 18
                                  : 18 - (globalFontSizeChange / 5),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  )
                  : Flexible(
                    child: Container(
                      height: Get.height,
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
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: featuredRatings.length,
                              itemBuilder: (context, index) {
                                featuredRatings.length;

                                final review =
                                    featuredRatings[index]
                                        as Map<String, dynamic>? ??
                                    {};

                                print("ffff $review");
                                final reviewId = review['id'] ?? index;

                                helpfulStates[reviewId] ??=
                                    review["isHelpful"] == true;
                                unhelpfulStates[reviewId] ??=
                                    review["isUnhelpful"] == true;
                                // IsHelpful =
                                //     widget
                                //         .commentsData["featuredRatings"][index]["isHelpful"] ==
                                //     true;
                                // IsUnHelpful =
                                //     widget
                                //         .commentsData["featuredRatings"][index]["isUnhelpful"] ==
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
                                            ? Color.fromARGB(255, 40, 41, 61)
                                            : Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                    fontSize:
                                        globalFontSizeChange <= 17
                                            ? (globalFontSizeChange / 5) + 12
                                            : 12 - (globalFontSizeChange / 5),
                                    fontWeight: FontWeight.w200,
                                  ),
                                );
                                final textPainter = TextPainter(
                                  text: textSpan,
                                  maxLines: 3,
                                  textDirection: TextDirection.ltr,
                                );
                                textPainter.layout(maxWidth: Get.width / 1.1);
                                final isLong = textPainter.didExceedMaxLines;
                                final isExpanded = expandedReviews.contains(
                                  index,
                                );

                                return SizedBox(
                                  width: Get.width / 1.1,
                                  child: StatefulBuilder(
                                    builder: (context, setDiaState) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                                    profileController
                                                                        .profileData['userName'])
                                                                ? themeController
                                                                            .initialTheme ==
                                                                        Themes
                                                                            .customLightTheme
                                                                    ? Colors
                                                                        .orangeAccent
                                                                        .shade400
                                                                    : Colors
                                                                        .amber
                                                                : themeController
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
                                                                    16
                                                                : 16 -
                                                                    (globalFontSizeChange /
                                                                        5),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star_outlined,
                                                          color: Colors.amber,
                                                          size: 20,
                                                        ),
                                                        Text(
                                                          "${review["rating"]?.toString()}"
                                                              .tr,
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
                                                                        14
                                                                    : 14 -
                                                                        (globalFontSizeChange /
                                                                            5),
                                                            fontWeight:
                                                                FontWeight.w400,
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
                                                        globalFontSizeChange <=
                                                                17
                                                            ? (globalFontSizeChange /
                                                                    5) +
                                                                10
                                                            : 10 -
                                                                (globalFontSizeChange /
                                                                    5),
                                                    fontWeight: FontWeight.w200,
                                                  ),
                                                  textAlign: TextAlign.end,
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
                                                icon: Icon(
                                                  Icons.more_vert_rounded,
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
                                                onSelected: (value) async {
                                                  if (value == 'report') {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        bool localReport1 =
                                                            report1;
                                                        bool localReport2 =
                                                            report2;
                                                        bool localReport3 =
                                                            report3;
                                                        return StatefulBuilder(
                                                          builder:
                                                              (
                                                                context,
                                                                setDialogState,
                                                              ) => AlertDialog(
                                                                title: Text(
                                                                  "Reasons:".tr,
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
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                                content: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    CheckboxListTile(
                                                                      title: Text(
                                                                        "Offensive:"
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
                                                                        setDialogState(() {
                                                                          localReport1 =
                                                                              value ??
                                                                              false;
                                                                        });
                                                                        setDiaState(() {
                                                                          report1 =
                                                                              value ??
                                                                              false;
                                                                        });
                                                                      },
                                                                    ),
                                                                    CheckboxListTile(
                                                                      title: Text(
                                                                        "Inappropriate:"
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
                                                                        setDialogState(() {
                                                                          localReport2 =
                                                                              value ??
                                                                              false;
                                                                        });
                                                                        setDiaState(() {
                                                                          report2 =
                                                                              value ??
                                                                              false;
                                                                        });
                                                                      },
                                                                    ),
                                                                    CheckboxListTile(
                                                                      title: Text(
                                                                        "Unrelated:"
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
                                                                        setDialogState(() {
                                                                          localReport3 =
                                                                              value ??
                                                                              false;
                                                                        });
                                                                        setDiaState(() {
                                                                          report3 =
                                                                              value ??
                                                                              false;
                                                                        });
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
                                                                        isConnected = sharedPrefs
                                                                            .prefs
                                                                            .getBool(
                                                                              'isConnected',
                                                                            );
                                                                        if (isConnected ==
                                                                            true) {
                                                                          if (ReportList
                                                                              .isNotEmpty) {
                                                                            likesController.reportReview(
                                                                              'lecture_rating_id',
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
                                                                      color:
                                                                          Color.fromARGB(
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
                                                                        "Submit"
                                                                            .tr,
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
                                                                          color: const Color.fromARGB(
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
                                                          report1 = false;
                                                          report2 = false;
                                                          report3 = false;
                                                        },
                                                        value: 'report',
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "report".tr,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    globalFontFamily,
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
                                                                fontSize:
                                                                    globalFontSizeChange <=
                                                                            17
                                                                        ? (globalFontSizeChange /
                                                                                5) +
                                                                            14
                                                                        : 14 -
                                                                            (globalFontSizeChange /
                                                                                5),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                reviewText,
                                                maxLines: isExpanded ? null : 3,
                                                overflow:
                                                    isExpanded
                                                        ? TextOverflow.visible
                                                        : TextOverflow.ellipsis,
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
                                                              12
                                                          : 12 -
                                                              (globalFontSizeChange /
                                                                  5),
                                                  fontWeight: FontWeight.w200,
                                                ),
                                              ),
                                              if (isLong && !isExpanded)
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      expandedReviews.add(
                                                        index,
                                                      );
                                                    });
                                                  },
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
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
                                                    ),
                                                  ),
                                                ),
                                              if (isExpanded && isLong)
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      expandedReviews.remove(
                                                        index,
                                                      );
                                                    });
                                                  },
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
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
                                                    ),
                                                  ),
                                                ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
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
                                                            ? Icons.thumb_up_alt
                                                            : Icons
                                                                .thumb_up_alt_outlined,
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
                                                        size: 20,
                                                      );
                                                    },
                                                    onTap: (
                                                      bool isLiked,
                                                    ) async {
                                                      // print(commentsData["id"].toString());
                                                      widget.type ==
                                                              'getresourceratings'
                                                          ? helpfulType =
                                                              'resource_rating_id'
                                                          : widget.type ==
                                                              'getlectureratings'
                                                          ? helpfulType =
                                                              'lecture_rating_id'
                                                          : widget.type ==
                                                              'getteacherratings'
                                                          ? helpfulType =
                                                              'teacher_rating_id'
                                                          : helpfulType =
                                                              'course_rating_id';

                                                      await likesController
                                                          .toggleHelpful({
                                                            helpfulType:
                                                                featuredRatings[index]['id'],
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
                                                  const SizedBox(width: 10),

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
                                                        size: 20,
                                                      );
                                                    },
                                                    onTap: (
                                                      bool isLiked,
                                                    ) async {
                                                      // print(commentsData["id"].toString());
                                                      widget.type ==
                                                              'getresourceratings'
                                                          ? helpfulType =
                                                              'resource_rating_id'
                                                          : widget.type ==
                                                              'getlectureratings'
                                                          ? helpfulType =
                                                              'lecture_rating_id'
                                                          : widget.type ==
                                                              'getteacherratings'
                                                          ? helpfulType =
                                                              'teacher_rating_id'
                                                          : helpfulType =
                                                              'course_rating_id';

                                                      await likesController
                                                          .toggleUnhelpful({
                                                            helpfulType:
                                                                featuredRatings[index]['id'],
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
                                                  const SizedBox(width: 10),
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
                                              borderRadius: BorderRadius.all(
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
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
