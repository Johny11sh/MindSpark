// ignore_for_file: avoid_print, non_constant_identifier_names, file_names, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';
import '../controller/FavoriteController.dart';
import '../core/constants/FontGlobals.dart';
import '../core/function/noDataLottie.dart';
import '../services/CacheManager.dart';
import '../services/SharedPrefs.dart';
import '../view/LogIn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../controller/NetworkController.dart';
import '../core/constants/ImageAssets.dart';
import '../locale/LocaleController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'Favorites.dart';
import 'NavBar.dart';
import 'TeachersCourses.dart';
import '../core/function/DynamicSearch.dart';

class SubjectTeachers extends StatefulWidget {
  final Map<String, dynamic> SubjectData;

  const SubjectTeachers({super.key, required this.SubjectData});

  @override
  State<SubjectTeachers> createState() => _SubjectTeachersState();
}

class _SubjectTeachersState extends State<SubjectTeachers> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final NetworkController networkController = Get.find<NetworkController>();
  ScrollController scrollController = ScrollController();
  late SharedPrefs sharedPrefs;
  late FavoriteController favoriteController;

  List<Map<String, dynamic>> subjectTeachers = [];
  // final Map<int, Uint8List> teachersImages = {};
  bool isFavorite = false;
  final CacheManager cacheManager = CacheManager();

  @override
  void initState() {
    super.initState();
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
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    // Try to load from cache first
    // await _loadCachedTeachers();

    // Then try to fetch fresh data if online
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getSubTeachersData();
    } else {
      if (cacheManager.isCacheEnabled.value == true) {
        await _loadCachedTeachers();
      }
    }
  }

  Future<void> _loadCachedTeachers() async {
    try {
      final cacheKey = 'cached_teachers_${widget.SubjectData['id']}';
      final cachedData = sharedPrefs.prefs.getString(cacheKey);

      if (cachedData != null) {
        final List<dynamic> parsedList = jsonDecode(cachedData);
        setState(() {
          subjectTeachers = List<Map<String, dynamic>>.from(parsedList);
        });
      }
    } catch (e) {
      debugPrint("Error loading cached teachers: $e");
    }
  }

  Future<void> _cacheTeachers() async {
    try {
      final cacheKey = 'cached_teachers_${widget.SubjectData['id']}';
      await sharedPrefs.prefs.setString(cacheKey, jsonEncode(subjectTeachers));
    } catch (e) {
      debugPrint("Error caching teachers: $e");
    }
  }

  Future<void> getSubTeachersData() async {
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
      final APIurl =
          '$baseUrl/api/subjects/${widget.SubjectData['id']}/teachers';

      // 3. API Request with timeout
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

      // 4. Response Handling
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Handle both array and object responses
        final List<dynamic> teachersList =
            responseBody is List
                ? responseBody
                : (responseBody['teachers'] ?? [responseBody]);

        // 5. State Management and caching
        if (mounted) {
          setState(() {
            subjectTeachers = List<Map<String, dynamic>>.from(teachersList);
          });
          if (cacheManager.isCacheEnabled.value == true) {
            await _cacheTeachers();
          }
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        // If API fails but we have cached data, don't throw error
        if (subjectTeachers.isEmpty) {
          throw Exception("Failed to load teachers: ${response.statusCode}");
        }
      }
    } on TimeoutException {
      // If we have cached data, just show a warning
      if (subjectTeachers.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      // If we have cached data, just show a warning
      if (subjectTeachers.isEmpty) {
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
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body:
            (cacheManager.isCacheEnabled.value == false &&
                        sharedPrefs.prefs.getBool('isConnected') == false) ||
                    (widget.SubjectData.isEmpty && subjectTeachers.isEmpty)
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
                              await _loadCachedTeachers();
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
                : subjectTeachers.isEmpty
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
                    await getSubTeachersData();
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
                                          "Subject's Teachers ".tr,
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
                                            elements: subjectTeachers,
                                            // elementsImages: teachersImages,
                                            searchType: 'teachers',
                                            onItemTap: (teacher) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          TeachersCourses(
                                                            TeacherData:
                                                                teacher,
                                                          ),
                                                ),
                                              );
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
                                topLeft: Radius.circular(60),
                                topRight: Radius.circular(60),
                              ),
                            ),
                            child:
                                (subjectTeachers.isEmpty)
                                    ? noDataLottie("No data available".tr)
                                    : Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Text(
                                          "Choose a teacher".tr,
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
                                            fontWeight: FontWeight.bold,
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
                                        ),
                                        const SizedBox(height: 20),
                                        Expanded(
                                          child: GridView.builder(
                                            scrollDirection: Axis.vertical,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                ),
                                            controller: scrollController,
                                            itemCount: subjectTeachers.length,
                                            itemBuilder: (context, i) {
                                              int teacherId =
                                                  subjectTeachers[i]["id"];
                                              // Uint8List? imageBytes =
                                              //     teachersImages[teacherId];
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => TeachersCourses(
                                                            TeacherData:
                                                                subjectTeachers[i],
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            left: 1,
                                                            right: 1,
                                                            top: 2,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.all(
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
                                                      child: Stack(
                                                        children: [
                                                          Positioned(
                                                            right: 10,
                                                            top: 3,
                                                            child:
                                                            // InkWell(
                                                            //   onTap: () {
                                                            //     favoriteController.toggleFavorite(
                                                            //       teacherId.toString(),
                                                            //     );
                                                            //   },
                                                            //   child: GetBuilder<FavoriteController>(
                                                            //     builder: (controller) {
                                                            //       final isFav =
                                                            //           controller.isFavorite[teacherId
                                                            //               .toString()] ??
                                                            //           false;
                                                            //
                                                            //       return Icon(
                                                            //         isFav
                                                            //             ? Icons.favorite
                                                            //             : Icons
                                                            //                 .favorite_border_outlined,
                                                            //         size: 30,
                                                            //         color: Colors.red,
                                                            //       );
                                                            //     },
                                                            //   ),
                                                            // ),
                                                            GetBuilder<
                                                              FavoriteController
                                                            >(
                                                              builder: (
                                                                controller,
                                                              ) {
                                                                final isFav =
                                                                    controller
                                                                        .isFavorite[teacherId
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
                                                                    controller.toggleFavorite(
                                                                      teacherId
                                                                          .toString(),
                                                                    );
                                                                    return !isLiked;
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          Center(
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(
                                                                  height: 15,
                                                                ),
                                                                subjectTeachers[i]["image"] !=
                                                                        null
                                                                    ? CachedNetworkImage(
                                                                      imageUrl:
                                                                          "$mainIP/${subjectTeachers[i]["image"]}",
                                                                      height:
                                                                          60,
                                                                      width: 60,
                                                                    )
                                                                    : Image.asset(
                                                                      ImageAssets
                                                                          .teacherAvatar,
                                                                    ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                      "${subjectTeachers[i]["name"]}"
                                                                          .tr,
                                                                      style: TextStyle(
                                                                        fontFamily:
                                                                            globalFontFamily,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        fontSize:
                                                                            globalFontSizeChange >=
                                                                                    17
                                                                                ? (globalFontSizeChange /
                                                                                        5) +
                                                                                    18
                                                                                : 16 -
                                                                                    (globalFontSizeChange /
                                                                                        5),
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        fontStyle:
                                                                            FontStyle.normal,
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
                                                                    )
                                                                    .animate()
                                                                    .fadeIn(
                                                                      delay:
                                                                          200.ms,
                                                                    )
                                                                    .slideY(
                                                                      begin:
                                                                          0.5,
                                                                      end: 0,
                                                                    ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                    .animate(
                                                      delay: (i * 100).ms,
                                                    )
                                                    .fadeIn(duration: 400.ms)
                                                    .slideY(
                                                      begin: 0.5,
                                                      end: 0,
                                                      curve: Curves.easeOutBack,
                                                      duration: 500.ms,
                                                    )
                                                    .scaleXY(
                                                      begin: 0.8,
                                                      end: 1,
                                                      duration: 600.ms,
                                                      curve: Curves.elasticOut,
                                                    ),
                                              );
                                            },
                                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        // ),
      ),
    );
  }
}
