// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison, file_names, dead_code

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learning_management_system/view/PDFPage.dart';
import 'package:like_button/like_button.dart';
import '../../controller/LikesController.dart';
import '../../controller/NetworkController.dart';
import '../../controller/ProfileController.dart';
import '../../services/SharedPrefs.dart';
import '../../view/NavBar.dart';
import '../../widget/AnimatedWatchlistButton.dart';
import '../constants/FontGlobals.dart';
import '../function/CustomRatingDialog.dart';
import '../function/buildRatingBar.dart';
import '../function/noDataLottie.dart';
import 'AudioBook.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../locale/LocaleController.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../core/constants/ImageAssets.dart';
import 'PDFOpener.dart';
import 'ReviewsPage.dart';

class BookDetails extends StatefulWidget {
  final Map<String, dynamic> BookData;
  // final Uint8List? bookImage;

  const BookDetails({
    super.key,
    required this.BookData,
    // required this.bookImage,
  });

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  final TextEditingController reportController = TextEditingController();
  final NetworkController networkController = Get.find<NetworkController>();
  final ProfileController profileController = Get.find<ProfileController>();

  late LikesController likesController;

  Set<int> expandedReviews = {};

  List<String> ReportList = [];

  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  String filePath = "";
  bool isRated = false;

  double? newUserRating;
  List<Map<String, dynamic>> newFeaturedRating = [];
  Map<String, dynamic> newBreakingDown = {};
  String? newCTRLRating;

  Map<int, bool> ratedBooks = {};

  bool report1 = false;
  bool report2 = false;
  bool report3 = false;
  bool? isConnected;
  // late bool IsHelpful;
  // late bool IsUnHelpful;
  Map<int, bool> helpfulStates = {};
  Map<int, bool> unhelpfulStates = {};

  late String token;
  late SharedPrefs sharedPrefs;
  // late int userRating;
  late int userId;

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
    final storedMap = await sharedPrefs.loadMap("ratedBooks");
    setState(() {
      ratedBooks = storedMap;
    });
  }

  @override
  void initState() {
    super.initState();

    Animations();
    sharedPrefs = SharedPrefs.instance;
    token = sharedPrefs.prefs.getString("token")!;
    profileController.getProfileData();

    likesController = Get.put(LikesController());
    loadRatedLessons();

    // userId = sharedPrefs.prefs.getInt("user_id")!;
    // userRating = 1;
    // print("FeaturedRatings :${widget.BookData["FeaturedRatings"]}");
    // print("$userId");
    // checkIfRatedLocally();
  }

  // void checkIfRatedLocally() {

  //   final ratings = widget.BookData["ratings"] as List<dynamic>? ?? [];

  //   final userReview = ratings.firstWhere(
  //         (review) => review["user_id"] == userId,
  //     orElse: () => null,
  //   );

  //   if (userReview != null) {
  //     setState(() {
  //       isRated = true;
  //       userRating = userReview["rating"];
  //     });
  //   }
  // }

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
  Widget build(BuildContext context) {
    final ratingBreakdown = widget.BookData["rating_breakdown"] ?? {};
    final totalReviews =
        (int.tryParse(ratingBreakdown["5"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["4"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["3"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["2"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["1"].toString()) ?? 0);
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();
    final featuredRatings =
        widget.BookData["FeaturedRatings"] as List<dynamic>? ?? [];

    if (newFeaturedRating.isNotEmpty) {
      featuredRatings.addAll(newFeaturedRating);
    }

    newUserRating =
        widget.BookData['user_rating'] != null
            ? double.tryParse(widget.BookData['user_rating'].toString())
            : 0;
    // Uint8List? imageBytes = widget.bookImage;

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
              widget.BookData == null || widget.BookData.isEmpty
                  ? Center(
                    child: CircularProgressIndicator(
                      color:
                          themeController.initialTheme ==
                                  Themes.customLightTheme
                              ? Color.fromARGB(255, 40, 41, 61)
                              : Color.fromARGB(255, 210, 209, 224),
                    ),
                  )
                  : SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Row(
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
                                          "Book Details".tr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
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
                                    // IconButton(
                                    //   onPressed: () {},
                                    //   icon: Icon(
                                    //     Icons.closed_caption,
                                    //     size: 35,
                                    //     color:
                                    //         themeController.initialTheme ==
                                    //                 Themes.customLightTheme
                                    //             ? Color.fromARGB(
                                    //               255,
                                    //               210,
                                    //               209,
                                    //               224,
                                    //             )
                                    //             : Color.fromARGB(255, 40, 41, 61),
                                    //   ),
                                    // ),
                                    AnimatedWatchlistButton(
                                      itemId:
                                          widget.BookData["id"]?.toString() ??
                                          "0",
                                      itemType: "resource",
                                      itemTitle:
                                          widget.BookData["name"]?.toString() ??
                                          "Book",
                                      itemImage:
                                          widget.BookData["image"]
                                              ?.toString() ??
                                          "",
                                      size: 24,
                                      isCourse: false,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              Container(
                                width: Get.width,
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
                                    (widget.BookData.isEmpty)
                                        ? noDataLottie("No data available")
                                        : Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: Get.width / 3,
                                                height: Get.width / 2.5,
                                                child:
                                                    widget.BookData['image'] !=
                                                            null
                                                        ? CachedNetworkImage(
                                                          imageUrl:
                                                              "$mainIP/${widget.BookData['image']}",
                                                          height: 60,
                                                          width: 60,
                                                        )
                                                        : Image.asset(
                                                          ImageAssets.book,
                                                          fit: BoxFit.cover,
                                                        ),
                                              ),
                                              const SizedBox(height: 20),

                                              Text(
                                                "${widget.BookData["name"]}".tr,
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
                                                            40,
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
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 15),

                                              Column(
                                                children: [
                                                  Text(
                                                    "Author: ${widget.BookData["author"]}"
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
                                                                40,
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
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "Publish Date: ${widget.BookData["publish date"]}"
                                                        .tr,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          globalFontFamily,
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
                                                      fontStyle:
                                                          FontStyle.normal,
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
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            right: 8,
                                                          ),
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          // try {
                                                          //   final PDFurl =
                                                          //       widget
                                                          //           .BookData['pdf_file_url'];
                                                          //   // "http://www.pdf995.com/samples/pdf.pdf";
                                                          //   final file =
                                                          //       await loadNetwork(
                                                          //         PDFurl,
                                                          //       );
                                                          //   if (mounted) {
                                                          //     openPDF(
                                                          //       context,
                                                          //       file,
                                                          //     );
                                                          //   }
                                                          // } catch (e) {
                                                          //   if (mounted) {
                                                          //     showErrorSnackbar(
                                                          //       "Failed to load PDF: ${e.toString()}",
                                                          //     );
                                                          //   }
                                                          // }

                                                          Navigator.of(
                                                            context,
                                                          ).push(
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (
                                                                    context,
                                                                  ) => PDFPage(
                                                                    PDFData:
                                                                        widget
                                                                            .BookData,
                                                                    // PDFData: widget.BookData
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Color.fromARGB(
                                                                255,
                                                                190,
                                                                0,
                                                                0,
                                                              ),
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 12,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons.book,
                                                              size: 18,
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              "Read Book".tr,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    globalFontFamily,
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
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            left: 8,
                                                          ),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          if (widget
                                                                  .BookData["audio_file_url"] !=
                                                              null) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => AudioBook(
                                                                      audioBookData:
                                                                          widget
                                                                              .BookData,
                                                                      // audioBookImage:
                                                                      //     imageBytes,
                                                                    ),
                                                              ),
                                                            );
                                                          } else {
                                                            Get.rawSnackbar(
                                                              messageText: Text(
                                                                "Audio is not available for this book",
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      globalFontFamily,
                                                                ),
                                                              ),
                                                              snackPosition:
                                                                  SnackPosition
                                                                      .BOTTOM,
                                                              duration:
                                                                  const Duration(
                                                                    seconds: 3,
                                                                  ),
                                                              backgroundColor:
                                                                  Colors
                                                                      .red[800]!,
                                                              icon: const Icon(
                                                                Icons
                                                                    .error_outline,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 12,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons.headphones,
                                                              size: 18,
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              "Listen To Audio Book"
                                                                  .tr,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    globalFontFamily,
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
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 25),

                                              Container(
                                                width: Get.width,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 20,
                                                    ),
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
                                                  borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(20),
                                                      ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            ((widget.BookData['rating'] ==
                                                                        null)
                                                                    ? "0"
                                                                    : (newCTRLRating ==
                                                                        null)
                                                                    ? widget
                                                                        .BookData['rating']
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
                                                                          16
                                                                      : 16 -
                                                                          (globalFontSizeChange /
                                                                              5),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
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
                                                            "Rating".tr,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  globalFontFamily,
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
                                                                  FontWeight
                                                                      .w400,
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
                                                    ),

                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "${widget.BookData["pdf_file_pages"]}"
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
                                                                  FontWeight
                                                                      .w300,
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
                                                            "Pages".tr,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  globalFontFamily,
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
                                                                  FontWeight
                                                                      .w400,
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
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "${widget.BookData["subjectName"]}"
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
                                                                  FontWeight
                                                                      .w300,
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
                                                            widget.BookData["literaryOrScientific"] ==
                                                                    1
                                                                ? "(Scientific)"
                                                                    .tr
                                                                : "(Literary)"
                                                                    .tr,
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
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
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
                                                            "Subject".tr,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  globalFontFamily,
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
                                                                  FontWeight
                                                                      .w400,
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
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        ),

                        // Reviews section
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: StatefulBuilder(
                            builder: (context, setDState) {
                              bool isRated =
                                  ratedBooks[widget.BookData['id']] ?? false;
                              return Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Center(
                                    child: Row(
                                      spacing: 10,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                showRatingDailog(
                                                  context,
                                                  widget.BookData["id"],
                                                  token,
                                                  "$mainIP/api/rateresource/${widget.BookData["id"]}",

                                                  () async {
                                                    setState(() {
                                                      newUserRating =
                                                          userRating;
                                                      newFeaturedRating = List<
                                                        Map<String, dynamic>
                                                      >.from(newRatingData);
                                                      newBreakingDown = Map<
                                                        String,
                                                        dynamic
                                                      >.from(
                                                        newRatingsBreakingDown,
                                                      );
                                                      newCTRLRating = newRating;

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
                                                      widget.BookData['featuredRatings'] =
                                                          featuredRatings;
                                                      widget.BookData['rating_breakdown'] =
                                                          newBreakingDown;
                                                      widget.BookData['user_rating'] =
                                                          newUserRating;
                                                      widget.BookData['rating'] =
                                                          newCTRLRating;

                                                      ratedBooks[widget
                                                              .BookData["id"]] =
                                                          true;
                                                    });
                                                    await sharedPrefs.saveMap(
                                                      "ratedBooks",
                                                      ratedBooks,
                                                    );
                                                  },
                                                  newUserRating ?? 0,
                                                );
                                              },

                                              // IconButton(     onPressed: () async {

                                              // },
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
                                                  ? newUserRating.toString().tr
                                                  : "Rate This".tr,
                                              style: TextStyle(
                                                fontFamily: globalFontFamily,
                                                color: Colors.blue,
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
                                                  "${(widget.BookData['rating'] == null)
                                                      ? "0"
                                                      : (newCTRLRating == null)
                                                      ? widget.BookData['rating'].toString()
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
                                  const SizedBox(height: 20),

                                  Column(
                                    children: [
                                      buildRatingBar(
                                        5,
                                        _areBarsVisible,
                                        widget.BookData["rating_breakdown"],
                                      ),
                                      const SizedBox(height: 6),
                                      buildRatingBar(
                                        4,
                                        _areBarsVisible,
                                        widget.BookData["rating_breakdown"],
                                      ),
                                      const SizedBox(height: 6),
                                      buildRatingBar(
                                        3,
                                        _areBarsVisible,
                                        widget.BookData["rating_breakdown"],
                                      ),
                                      const SizedBox(height: 6),
                                      buildRatingBar(
                                        2,
                                        _areBarsVisible,
                                        widget.BookData["rating_breakdown"],
                                      ),
                                      const SizedBox(height: 6),
                                      buildRatingBar(
                                        1,
                                        _areBarsVisible,
                                        widget.BookData["rating_breakdown"],
                                      ),
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
                                                    type: "getresourceratings",
                                                    sectionId:
                                                        widget.BookData["id"],
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
                                    width: Get.width,
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
                                  const SizedBox(height: 15),

                                  // Reviews List
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        (featuredRatings.length < 4)
                                            ? featuredRatings.length
                                            : 3,
                                    itemBuilder: (context, index) {
                                      // final review =
                                      //     featuredRatings[index]
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

                                      // bool IsHelpful =
                                      //     widget
                                      //         .BookData["FeaturedRatings"][index]["isHelpful"] ==
                                      //     true;
                                      // bool IsUnHelpful =
                                      //     widget
                                      //         .BookData["FeaturedRatings"][index]["isUnhelpful"] ==
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
                                                  ? (globalFontSizeChange / 5) +
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

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 15,
                                        ),
                                        child: StatefulBuilder(
                                          builder: (context, setDiaState) {
                                            // bool isRated =
                                            //     ratedBooks[widget
                                            //         .BookData['id']] ??
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
                                                                          profileController
                                                                              .profileData['userName'])
                                                                      ? themeController.initialTheme ==
                                                                              Themes.customLightTheme
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
                                                      onSelected: (
                                                        value,
                                                      ) async {
                                                        if (value == 'report') {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
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
                                                                                    'resource_rating_id',
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
                                                                                40,
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
                                                            expandedReviews.add(
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
                                                                .remove(index);
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
                                                                  ? Icons
                                                                      .thumb_up_alt
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
                                                            // print(widget.videoData["id"].toString());

                                                            await likesController
                                                                .toggleHelpful({
                                                                  "resource_rating_id":
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
                                                            // print(widget.videoData["id"].toString());
                                                            await likesController
                                                                .toggleUnhelpful({
                                                                  "resource_rating_id":
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
                                  const SizedBox(height: 40),
                                ],
                              );
                            },
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
