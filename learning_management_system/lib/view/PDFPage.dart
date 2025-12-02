// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:like_button/like_button.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../controller/LikesController.dart';
import '../controller/ProfileController.dart';
import '../core/classes/PDFOpener.dart';
import '../core/function/CustomRatingDialog.dart';
import '../core/classes/ReviewsPage.dart';
import '../core/constants/FontGlobals.dart';
import '../core/function/buildRatingBar.dart';
import '../locale/LocaleController.dart';
import '../services/SharedPrefs.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'NavBar.dart';

class PDFPage extends StatefulWidget {
  final Map<String, dynamic> PDFData;
  final int? index;

  const PDFPage({super.key, required this.PDFData, this.index});

  @override
  State<PDFPage> createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  final ThemeController themeController = Get.find<ThemeController>();

  final LikesController likesController = Get.find<LikesController>();
  Set<int> expandedReviews = {};
  final TextEditingController reportController = TextEditingController();
  final ProfileController profileController = Get.find<ProfileController>();

  late bool IsLiked;
  late bool isDisLiked;
  late String token;
  late SharedPrefs sharedPrefs;

  Map<int, bool> ratedLessons = {};
  double? newUserRating;
  List<Map<String, dynamic>> newFeaturedRating = [];
  Map<String, dynamic> newBreakingDown = {};
  String? newCTRLRating;

  List<String> ReportList = [];

  bool report1 = false;
  bool report2 = false;
  bool report3 = false;
  bool? isConnected;
  // late bool IsHelpful;
  // late bool IsUnHelpful;
  Map<int, bool> helpfulStates = {};
  Map<int, bool> unhelpfulStates = {};

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
    final storedMap = await sharedPrefs.loadMap("ratedLessons");
    setState(() {
      ratedLessons = storedMap;
    });
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PDFOpener(
              PDFfile: file,
              // PDFData: widget.BookData
            ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Animations();
    sharedPrefs = SharedPrefs.instance;
    token = sharedPrefs.prefs.getString("token")!;
    profileController.getProfileData();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    IsLiked = widget.PDFData["isLiked"] == true;
    isDisLiked = widget.PDFData["isDisliked"] == true;
    loadRatedLessons();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratingBreakdown = widget.PDFData["rating_breakdown"] ?? {};
    final totalReviews =
        (int.tryParse(ratingBreakdown["5"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["4"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["3"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["2"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["1"].toString()) ?? 0);
    final ThemeController themeController = Get.find<ThemeController>();
    Get.find<LocaleController>();

    final featuredRatings =
        widget.PDFData["FeaturedRatings"] as List<dynamic>? ?? [];

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
                                "PDF Page".tr,
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
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 210, 209, 224)
                            : Color.fromARGB(255, 40, 41, 61),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                            top: 10,
                            right: 5,
                            left: 5,
                          ),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  StatefulBuilder(
                                    builder: (context, setDState) {
                                      bool isRated =
                                          ratedLessons[widget.PDFData['id']] ??
                                          false;
                                      return Row(
                                        // spacing: 10,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          // const SizedBox(width: 10),
                                          Column(
                                            children: [
                                              Icon(
                                                Icons.remove_red_eye_rounded,
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
                                                size: 30,
                                              ),
                                              Text(
                                                widget.PDFData["views"]
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
                                                              12
                                                          : 12 -
                                                              (globalFontSizeChange /
                                                                  5),
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 10),

                                          Column(
                                            children: [
                                              LikeButton(
                                                size: 30,
                                                isLiked: IsLiked,
                                                likeBuilder: (bool isLiked) {
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
                                                    size: 30,
                                                  );
                                                },
                                                onTap: (bool isLiked) async {
                                                  // print(widget.PDFData["id"].toString());

                                                  await likesController
                                                      .toggleLikes(
                                                        widget.PDFData["id"]
                                                            .toString(),
                                                      );
                                                  setState(() {
                                                    widget.PDFData["likes"] =
                                                        likesController
                                                            .likesCount;
                                                    widget.PDFData["dislikes"] =
                                                        likesController
                                                            .dislikesCount;

                                                    widget.PDFData["isLiked"] =
                                                        likesController.isLiked;
                                                    widget.PDFData["isDisliked"] =
                                                        likesController
                                                            .isDisliked;
                                                  });
                                                  setDState(() {
                                                    IsLiked = !isLiked;
                                                    if (IsLiked) {
                                                      isDisLiked = false;
                                                    }
                                                  });

                                                  return !isLiked;
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                widget.PDFData["likes"]
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
                                                              12
                                                          : 12 -
                                                              (globalFontSizeChange /
                                                                  5),
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),

                                          Column(
                                            children: [
                                              LikeButton(
                                                size: 30,
                                                isLiked: isDisLiked,
                                                likeBuilder: (bool isLiked) {
                                                  return Icon(
                                                    isLiked
                                                        ? Icons.thumb_down_alt
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
                                                    size: 30,
                                                  );
                                                },
                                                onTap: (bool isLiked) async {
                                                  // print(widget.PDFData["id"].toString());
                                                  await likesController
                                                      .toggleDisLikes(
                                                        widget.PDFData["id"]
                                                            .toString(),
                                                      );
                                                  setState(() {
                                                    widget.PDFData["likes"] =
                                                        likesController
                                                            .likesCount;
                                                    widget.PDFData["dislikes"] =
                                                        likesController
                                                            .dislikesCount;

                                                    widget.PDFData["isLiked"] =
                                                        likesController.isLiked;
                                                    widget.PDFData["isDisliked"] =
                                                        likesController
                                                            .isDisliked;
                                                  });

                                                  setDState(() {
                                                    isDisLiked = !isLiked;
                                                    if (isDisLiked) {
                                                      IsLiked = false;
                                                    }
                                                  });
                                                  return !isLiked;
                                                },
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                widget.PDFData["dislikes"]
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
                                                              12
                                                          : 12 -
                                                              (globalFontSizeChange /
                                                                  5),
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 10),

                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  showRatingDailog(
                                                    context,
                                                    widget.PDFData["id"],
                                                    token,
                                                    "$mainIP/api/ratelecture/${widget.PDFData["id"]}",

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
                                                        widget.PDFData['featuredRatings'] =
                                                            featuredRatings;

                                                        widget.PDFData['rating_breakdown'] =
                                                            newBreakingDown;
                                                        widget.PDFData['user_rating'] =
                                                            newUserRating;
                                                        widget.PDFData['rating'] =
                                                            newCTRLRating;

                                                        ratedLessons[widget
                                                                .PDFData["id"]] =
                                                            true;
                                                      });
                                                      await sharedPrefs.saveMap(
                                                        "ratedLessons",
                                                        ratedLessons,
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
                                                iconSize: 25,
                                              ),
                                              Text(
                                                (isRated)
                                                    ? widget
                                                        .PDFData['user_rating']
                                                        .toString()
                                                        .tr
                                                    : "Rate This".tr,
                                                style: TextStyle(
                                                  fontFamily: globalFontFamily,
                                                  color: Colors.blue,
                                                  fontSize:
                                                      globalFontSizeChange <= 17
                                                          ? (globalFontSizeChange /
                                                                  5) +
                                                              12
                                                          : 12 -
                                                              (globalFontSizeChange /
                                                                  5),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // const SizedBox(width: 10),
                                        ],
                                      );
                                    },
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Text(
                                          "Description".tr,
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
                                                        20
                                                    : 20 -
                                                        (globalFontSizeChange /
                                                            5),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 10),

                                        Text(
                                          "${widget.PDFData["description"]}".tr,
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

                                        const SizedBox(height: 20),

                                        Center(
                                          child: SizedBox(
                                            width: 120,
                                            height: 40,
                                            child: MaterialButton(
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
                                              textColor:
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

                                              onPressed: () async {
                                                try {
                                                  final PDFurl =
                                                      (widget.PDFData['urlpdf'] ==
                                                              null)
                                                          ? widget
                                                              .PDFData['pdf_file_url']
                                                          : widget
                                                              .PDFData['urlpdf'];
                                                  // "http://www.pdf995.com/samples/pdf.pdf";
                                                  final file =
                                                      await loadNetwork(PDFurl);
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
                                              },
                                              child: Text(
                                                "Open PDF".tr,
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

                                        const SizedBox(height: 20),

                                        Wrap(
                                          children: [
                                            Text(
                                              "Course Name:".tr,
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
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 5),

                                            Text(
                                              "${widget.PDFData["courseName"]}"
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

                                        const SizedBox(height: 20),

                                        Wrap(
                                          children: [
                                            Text(
                                              "Teacher Name:".tr,
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
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 5),

                                            Text(
                                              "${widget.PDFData["teacherName"]}"
                                                  .tr,
                                              textAlign: TextAlign.center,
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

                                        const SizedBox(height: 30),

                                        Center(
                                          child: Row(
                                            spacing: 10,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
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
                                                        "${(widget.PDFData['rating'] == null)
                                                            ? "0"
                                                            : (newCTRLRating == null)
                                                            ? widget.PDFData['rating'].toString()
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
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  Text(
                                                    "based on (${totalReviews.toString()}) reviews",
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
                                                                  20
                                                              : 20 -
                                                                  (globalFontSizeChange /
                                                                      5),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        Column(
                                          children: [
                                            buildRatingBar(
                                              5,
                                              _areBarsVisible,
                                              widget
                                                  .PDFData["rating_breakdown"],
                                            ),
                                            const SizedBox(height: 6),
                                            buildRatingBar(
                                              4,
                                              _areBarsVisible,
                                              widget
                                                  .PDFData["rating_breakdown"],
                                            ),
                                            const SizedBox(height: 6),
                                            buildRatingBar(
                                              3,
                                              _areBarsVisible,
                                              widget
                                                  .PDFData["rating_breakdown"],
                                            ),
                                            const SizedBox(height: 6),
                                            buildRatingBar(
                                              2,
                                              _areBarsVisible,
                                              widget
                                                  .PDFData["rating_breakdown"],
                                            ),
                                            const SizedBox(height: 6),
                                            buildRatingBar(
                                              1,
                                              _areBarsVisible,
                                              widget
                                                  .PDFData["rating_breakdown"],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        Container(
                                          height: 1,
                                          width: Get.width,
                                          decoration: BoxDecoration(
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
                                              textColor:
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

                                              onPressed: () async {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => ReviewsPage(
                                                          type:
                                                              "getlectureratings",
                                                          sectionId:
                                                              widget
                                                                  .PDFData["id"],
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
                                        const SizedBox(height: 20),

                                        Container(
                                          height: 1,
                                          width: Get.width,
                                          decoration: BoxDecoration(
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
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(60),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // Reviews List
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount:
                                              (featuredRatings.length < 4)
                                                  ? featuredRatings.length
                                                  : 3,
                                          itemBuilder: (context, index) {
                                            featuredRatings.length;

                                            final review =
                                                // (newFeaturedRating.isNotEmpty)
                                                //     ? newFeaturedRating[index]
                                                //             as Map<
                                                //               String,
                                                //               dynamic
                                                //             >? ??
                                                //         {}
                                                //     :
                                                featuredRatings[index]
                                                    as Map<String, dynamic>? ??
                                                {};

                                            print("ffff $review");
                                            final reviewId =
                                                review['id'] ?? index;

                                            helpfulStates[reviewId] ??=
                                                review["isHelpful"] == true;
                                            unhelpfulStates[reviewId] ??=
                                                review["isUnhelpful"] == true;
                                            // IsHelpful =
                                            //     widget
                                            //         .PDFData["FeaturedRatings"][index]["isHelpful"] ==
                                            //     true;
                                            // IsUnHelpful =
                                            //     widget
                                            //         .PDFData["FeaturedRatings"][index]["isUnhelpful"] ==
                                            //     true;
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
                                                builder: (
                                                  context,
                                                  setDiaState,
                                                ) {
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                                        globalFontSizeChange <=
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
                                                                      size: 20,
                                                                    ),
                                                                    Text(
                                                                      "${review["rating"]?.toString()}"
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
                                                                    globalFontSizeChange <=
                                                                            17
                                                                        ? (globalFontSizeChange /
                                                                                5) +
                                                                            10
                                                                        : 10 -
                                                                            (globalFontSizeChange /
                                                                                5),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                              ),
                                                              textAlign:
                                                                  TextAlign.end,
                                                            ),
                                                          ),
                                                          PopupMenuButton<
                                                            String
                                                          >(
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
                                                                  context:
                                                                      context,
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
                                                                              "Reasons:".tr,
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
                                                                      report1 =
                                                                          false;
                                                                      report2 =
                                                                          false;
                                                                      report3 =
                                                                          false;
                                                                    },
                                                                    value:
                                                                        'report',
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
                                                      const SizedBox(height: 8),
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
                                                                  FontWeight
                                                                      .w200,
                                                            ),
                                                          ),
                                                          if (isLong &&
                                                              !isExpanded)
                                                            TextButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  expandedReviews
                                                                      .add(
                                                                        index,
                                                                      );
                                                                });
                                                              },
                                                              style: TextButton.styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                              child: Text(
                                                                'Read more...',
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
                                                                  fontFamily:
                                                                      globalFontFamily,
                                                                ),
                                                              ),
                                                            ),
                                                          if (isExpanded &&
                                                              isLong)
                                                            TextButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  expandedReviews
                                                                      .remove(
                                                                        index,
                                                                      );
                                                                });
                                                              },
                                                              style: TextButton.styleFrom(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                              child: Text(
                                                                'Show less',
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
                                                                  // print(widget.PDFData["id"].toString());

                                                                  await likesController
                                                                      .toggleHelpful({
                                                                        "lecture_rating_id":
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
                                                                  // print(widget.PDFData["id"].toString());
                                                                  await likesController
                                                                      .toggleUnhelpful({
                                                                        "lecture_rating_id":
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
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
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
                                                          shape:
                                                              BoxShape
                                                                  .rectangle,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  60,
                                                                ),
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
            ],
          ),
        ),
      ),
    );
  }
}
