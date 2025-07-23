// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison, file_names

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../locale/LocaleController.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../core/constants/ImageAssets.dart';
import 'PDFOpener.dart';

class BookDetails extends StatefulWidget {
  final Map<String, dynamic> BookData;
  final Uint8List? bookImage;

  const BookDetails({
    super.key,
   required this.BookData,
    required this.bookImage,
  });

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  String filePath = "";
  bool isRated = false;

  void showErrorSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(message),
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

  Widget buildRatingBar(int rating) {
    final ratingBreakdown = widget.BookData["rating_breakdown"] ?? {};
    final totalReviews =
        (int.tryParse(ratingBreakdown["5"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["4"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["3"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["2"].toString()) ?? 0) +
        (int.tryParse(ratingBreakdown["1"].toString()) ?? 0);

    final count =
        int.tryParse(ratingBreakdown[rating.toString()].toString()) ?? 0;
    final percent = totalReviews > 0 ? count / totalReviews : 0.0;

    final ThemeController themeController = Get.find<ThemeController>();

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

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();
    final featuredRatings =
        widget.BookData["FeaturedRatings"] as List<dynamic>? ?? [];
    Uint8List? imageBytes = widget.bookImage;

    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body:
            widget.BookData == null || widget.BookData.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 40, 41, 61)
                      : Color.fromARGB(255, 210, 209, 224),
                ),
              )
                : SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                children: [
                  // Header section with layered container design
                  Container(
                        color:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                              ? Color.fromARGB(255, 40, 41, 61)
                              : Color.fromARGB(255, 210, 209, 224),
                          child: Column(
                            children: [
                            // Top header container
                            Padding(
                              padding: EdgeInsets.only(top: 40),
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
                                          : Color.fromARGB(255, 40, 41, 61),
                                    ),
                                  ),
                                  Text(
                                    "Book Details".tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              )
                                          : Color.fromARGB(255, 40, 41, 61),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.closed_caption,
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
                                          : Color.fromARGB(255, 40, 41, 61),
                                    ),
                                  ),
                                ],
                              ),
                          ),
                            SizedBox(height: 20),

                            // Rounded bottom container
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
                              child: Padding(
                                padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                                    // Book Image
                              SizedBox(
                                      width: Get.width / 3,
                                      height: Get.width / 2.5,
                                      child:
                                    imageBytes != null
                                        ? Image.memory(
                                          imageBytes,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                            return Image.asset(
                                                    ImageAssets.book,
                                                    fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                        : Image.asset(
                                                ImageAssets.book,
                                                fit: BoxFit.cover,
                                              ),
                                        ),
                                    SizedBox(height: 20),

                                    // Book Name
                                    Text(
                                      "${widget.BookData["name"]}".tr,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
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
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 15),

                                    // Author and Publish Date
                                    Column(
                                      children: [
                                        Text(
                                          "Author: ${widget.BookData["author"]}"
                                              .tr,
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
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "Publish Date: ${widget.BookData["publish date"]}"
                                              .tr,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
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
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),

                                    // Action Buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(right: 8),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  final PDFurl =
                                                      widget.BookData['url'];
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
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 12,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                      ),
                                      child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                        children: [
                                                  Icon(Icons.book, size: 18),
                                                  SizedBox(width: 5),
                                              Text(
                                                    "Read Book".tr,
                                                style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 8),
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 12,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                            children: [
                                                  Icon(
                                                    Icons.headphones,
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 5),
                                              Text(
                                                    "Listen To Audio Book".tr,
                                                style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 25),

                                    // Info Container
                                    Container(
                                      width: Get.width,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 20,
                                      ),
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
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  "${widget.BookData["rating"]}"
                                                      .tr,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
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
                                              Text(
                                                  "Rating".tr,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                  fontWeight: FontWeight.w400,
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
                                        ],
                                      ),
                                    ),

                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${widget.BookData["pages"]}"
                                                      .tr,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w300,
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
                                                Text(
                                                  "Pages".tr,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
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
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${widget.BookData["subjectName"]}"
                                                      .tr,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w300,
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
                                                Text(
                                                  widget.BookData["literaryOrScientific"] ==
                                                          1
                                                      ? "(Scientific)".tr
                                                      : "(Literary)".tr,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w300,
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
                                                Text(
                                                  "Subject".tr,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
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
                        padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Center(
                                    child: Row(
                                spacing: 10,
                                mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
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
                                            widget.BookData["rating"].toString(),
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
                                        "based on (${widget.BookData["ratings_count"].toString()}) reviews",
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
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),

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
                            SizedBox(height: 15),
                                  Container(
                                    height: 1,
                              width: Get.width,
                                    decoration: BoxDecoration(
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
                                      shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(60),
                                    ),
                                  ),
                            ),
                            SizedBox(height: 15),

                            // Reviews List
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: featuredRatings.length,
                                    itemBuilder: (context, index) {
                                final review =
                                    featuredRatings[index]
                                        as Map<String, dynamic>? ??
                                    {};
                                      return Container(
                                  margin: EdgeInsets.only(bottom: 15),
                                        child: StatefulBuilder(
                                          builder: (context, setState) {
                                            bool isExpanded = false;
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
                                        maxWidth: Get.width - 40,
                                      );
                                      final isLong =
                                          textPainter.didExceedMaxLines;
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
                                                          review["rating"]
                                                                  ?.toString()
                                                                  .tr ??
                                                              'no rating'.tr,
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
                                                            fontSize: 14,
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
                                                        fontWeight: FontWeight.w200,
                                                  ),
                                                  textAlign: TextAlign.end,
                                                ),
                                                    ),
                                                  ],
                                                ),
                                          SizedBox(height: 8),
                                                    Text(
                                                      reviewText,
                                                      maxLines: isExpanded ? null : 3,
                                            overflow:
                                                isExpanded
                                                    ? TextOverflow.visible
                                                    : TextOverflow.ellipsis,
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
                                                    ),
                                                    if (isLong && !isExpanded)
                                                      TextButton(
                                              onPressed:
                                                  () => setState(
                                                    () => isExpanded = true,
                                                  ),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Text(
                                                'Read more...'.tr,
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12,
                                                ),
                                              ),
                                                      ),
                                                    if (isExpanded && isLong)
                                                      TextButton(
                                              onPressed:
                                                  () => setState(
                                                    () => isExpanded = false,
                                                  ),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Text(
                                                'Show less'.tr,
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          if (index <
                                              featuredRatings.length - 1)
                                                    Container(
                                                      height: 1,
                                              margin: EdgeInsets.only(top: 15),
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
                                  SizedBox(height: 40),
                                ],
                          ),
                  ),
                ],
                  ),
              ),
      ),
    );
  }
}
