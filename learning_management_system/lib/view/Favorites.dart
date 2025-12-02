// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learning_management_system/view/CoursesLessons.dart';
import 'package:learning_management_system/view/TeacherDetails.dart';
import '../controller/ViewFavoriteController.dart';
import '../core/constants/FontGlobals.dart';
import '../core/function/loadingLottie.dart';
import '../core/function/noDataLottie.dart';

import '../themes/Themes.dart';
import '../widget/ViewCFavoriteCard.dart';
import '../widget/ViewTFavoriteCard.dart';
import 'LogIn.dart';
import 'NavBar.dart';
import 'OnBoarding.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorites> {
  List<Map<String, dynamic>> coursesDataList = [];
  List<Map<String, dynamic>> teacherDataList = [];

  Future<void> getCourseData(String ID) async {
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
      final APIurl = '$baseUrl/api/getcourse/$ID';

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

      debugPrint("Course API response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        List<Map<String, dynamic>> CoursesList = [];

        if (responseBody is List) {
          CoursesList = List<Map<String, dynamic>>.from(responseBody);
        } else if (responseBody is Map && responseBody.containsKey('course')) {
          CoursesList = [Map<String, dynamic>.from(responseBody['course'])];
        } else if (responseBody is Map) {
          CoursesList = [responseBody['course']];
        } else {
          debugPrint("Unexpected response type: ${responseBody.runtimeType}");
        }

        if (mounted) {
          setState(() {
            coursesDataList = List<Map<String, dynamic>>.from(CoursesList);
            print(coursesDataList);
          });
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (coursesDataList.isEmpty) {
          throw Exception("Failed to load course: ${response.statusCode}");
        }
      }
    } on TimeoutException {
      if (coursesDataList.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      if (coursesDataList.isEmpty) {
        showErrorSnackbar("Failed to load course");
      } else {
        showErrorSnackbar("Using cached data - ${e.toString()}");
      }
      debugPrint("Error fetching course: $e");
    }
  }

  Future<void> getTeacherData(String ID) async {
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
      final APIurl = '$baseUrl/api/getteacher/$ID';

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

      debugPrint("Teachers API response: ${response.statusCode}");

      print("ggggggggggggggg");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        List<Map<String, dynamic>> TeachersList = [];

        if (responseBody is List) {
          TeachersList = List<Map<String, dynamic>>.from(responseBody);
        } else if (responseBody is Map && responseBody.containsKey('teacher')) {
          TeachersList = [Map<String, dynamic>.from(responseBody['teacher'])];
        } else if (responseBody is Map) {
          TeachersList = [responseBody['teacher']];
        } else {
          debugPrint("Unexpected response type: ${responseBody.runtimeType}");
        }
        print("hjhhhhhhhhhhhhhhhhhhhhhhhhhhhh");
        print(TeachersList);
        print("hjhhhhhhhhhhhhhhhhhhhhhhhhhhhh");

        if (mounted) {
          setState(() {
            teacherDataList = List<Map<String, dynamic>>.from(TeachersList);
          });
        }
      } else if (response.statusCode == 401) {
        print("hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh");
        print("hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        print("hjhhhhhhhhhhhhhhhhhhhhhhhhhhhh");
        print("hjhhhhhhhhhhhhhhhhhhhhhhhhhhhh");
        if (teacherDataList.isEmpty) {
          throw Exception("Failed to load teachers: ${response.statusCode}");
        }
      }
    } on TimeoutException {
      if (teacherDataList.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      if (teacherDataList.isEmpty) {
        showErrorSnackbar("Failed to load teachers");
      } else {
        showErrorSnackbar("Using cached data - ${e.toString()}");
      }
      debugPrint("Error fetching teachers: $e");
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
  void dispose() {
    super.dispose();
    Get.delete<ViewFavoriteController>();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(ViewFavoriteController());
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: GetBuilder<ViewFavoriteController>(
          builder: (controller) {
            return RefreshIndicator(
              onRefresh: () async {
                controller.onInit();
                controller.getCFavorite();
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
                      height: 100,
                      // color: Colors.red,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: Color.fromARGB(255, 210, 209, 224),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(right: Get.width / 8),

                                child: Text(
                                  "My Favorite".tr,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.copyWith(
                                    fontFamily: globalFontFamily,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        globalFontSizeChange <= 17
                                            ? (globalFontSizeChange / 5) + 23
                                            : 23 - (globalFontSizeChange / 5),
                                    color:
                                        themeController.initialTheme ==
                                                Themes.customLightTheme
                                            ? Color.fromARGB(255, 210, 209, 224)
                                            : Color.fromARGB(255, 40, 41, 61),
                                  ),
                                ),
                              ),
                            ),
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
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              width: 200,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFFE0DEF0), // Light background
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Color(0xFFE0DEF0)),
                              ),
                              child: Row(
                                // mainAxisSize: MainAxisSize.min,
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        controller.change("teacher");
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              controller.favCh == "teacher"
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
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(25),
                                            bottomLeft: Radius.circular(25),
                                          ),
                                        ),

                                        alignment: Alignment.center,
                                        child: Text(
                                          "Teacher",
                                          style: TextStyle(
                                            fontFamily: globalFontFamily,
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        18
                                                    : 18 -
                                                        (globalFontSizeChange /
                                                            5),
                                            color:
                                                controller.favCh == "teacher"
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
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        controller.change("course");
                                        controller.getCFavorite();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              controller.favCh == "teacher"
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
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(25),
                                            bottomRight: Radius.circular(25),
                                          ),
                                        ),

                                        alignment: Alignment.center,
                                        child: Text(
                                          "Course",
                                          style: TextStyle(
                                            fontFamily: globalFontFamily,
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        18
                                                    : 18 -
                                                        (globalFontSizeChange /
                                                            5),
                                            color:
                                                controller.favCh == "teacher"
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
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  controller.loading
                                      ? loadingLottie()
                                      : controller.favCh == "teacher"
                                      ? controller.tFav.isEmpty
                                          ? noDataLottie()
                                          : GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  mainAxisSpacing: 10,
                                                  crossAxisSpacing: 10,
                                                ),
                                            itemCount: controller.tFav.length,
                                            itemBuilder:
                                                (context, index) => InkWell(
                                                  onTap: () async {
                                                    final raw =
                                                        controller.tFav[index]
                                                            .toJson();
                                                    final Map<String, dynamic>
                                                    payload =
                                                        raw is List
                                                            ? (raw.isNotEmpty
                                                                ? Map<
                                                                  String,
                                                                  dynamic
                                                                >.from(raw)
                                                                : <
                                                                  String,
                                                                  dynamic
                                                                >{})
                                                            : Map<
                                                              String,
                                                              dynamic
                                                            >.from(raw as Map);

                                                    await getTeacherData(
                                                      payload['id'].toString(),
                                                    );

                                                    final Map<String, dynamic>
                                                    payload2 =
                                                        teacherDataList is List
                                                            ? (teacherDataList
                                                                    .isNotEmpty
                                                                ? Map<
                                                                  String,
                                                                  dynamic
                                                                >.from(
                                                                  teacherDataList[0],
                                                                )
                                                                : <
                                                                  String,
                                                                  dynamic
                                                                >{})
                                                            : Map<
                                                              String,
                                                              dynamic
                                                            >.from(
                                                              teacherDataList
                                                                  as Map,
                                                            );
                                                    print(teacherDataList);
                                                    print(payload2);
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                TeacherDetails(
                                                                  TeacherData:
                                                                      payload2,
                                                                ),
                                                      ),
                                                    );
                                                  },
                                                  child: ViewTFavoriteCard(
                                                    tFavoriteModel:
                                                        controller.tFav[index],
                                                  ),
                                                ),
                                          )
                                      : controller.loading2
                                      ? loadingLottie()
                                      : controller.cFav.isEmpty
                                      ? noDataLottie()
                                      : GridView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                            ),
                                        itemCount: controller.cFav.length,
                                        itemBuilder:
                                            (context, index) => InkWell(
                                              onTap: () async {
                                                final raw =
                                                    controller.cFav[index]
                                                        .toJson();
                                                final Map<String, dynamic>
                                                payload =
                                                    raw is List
                                                        ? (raw.isNotEmpty &&
                                                                raw[0] is Map
                                                            ? Map<
                                                              String,
                                                              dynamic
                                                            >.from(raw[0])
                                                            : <
                                                              String,
                                                              dynamic
                                                            >{})
                                                        : Map<
                                                          String,
                                                          dynamic
                                                        >.from(raw as Map);
                                                await getCourseData(
                                                  payload['id'].toString(),
                                                );
                                                Future.delayed(
                                                  Duration(seconds: 2),
                                                );

                                                final Map<String, dynamic>
                                                payload2 =
                                                    coursesDataList is List
                                                        ? (coursesDataList
                                                                .isNotEmpty
                                                            ? Map<
                                                              String,
                                                              dynamic
                                                            >.from(
                                                              coursesDataList[0],
                                                            )
                                                            : <
                                                              String,
                                                              dynamic
                                                            >{})
                                                        : Map<
                                                          String,
                                                          dynamic
                                                        >.from(
                                                          coursesDataList
                                                              as Map,
                                                        );
                                                print(coursesDataList);
                                                print(payload2);

                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            CoursesLessons(
                                                              CoursesData:
                                                                  payload2,
                                                              index: index,
                                                            ),
                                                  ),
                                                );
                                              },
                                              child: ViewCFavoriteCard(
                                                cFavoriteModel:
                                                    controller.cFav[index],
                                              ),
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
            );
          },
        ),
      ),
    );
  }
}
