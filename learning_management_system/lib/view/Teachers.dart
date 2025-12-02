// ignore_for_file: must_be_immutable, use_build_context_synchronously, unnecessary_null_comparison
// ignore_for_file: avoid_print, non_constant_identifier_names, file_names

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';

import '../controller/BackButtonController.dart';
import '../controller/FavoriteController.dart';
import '../core/constants/FontGlobals.dart';
import '../core/function/noDataLottie.dart';
import '../services/CacheManager.dart';
import '../view/LogIn.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../controller/NetworkController.dart';
import '../core/constants/ImageAssets.dart';
import '../locale/LocaleController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import '../services/SharedPrefs.dart';
import 'package:flutter/material.dart';
import 'Favorites.dart';
import 'NavBar.dart';
import 'TeacherDetails.dart';
import '../core/function/DynamicSearch.dart';

class Teachers extends StatefulWidget {
  const Teachers({super.key});

  @override
  State<Teachers> createState() => _TeachersState();
}

class _TeachersState extends State<Teachers> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final BackButtonController controller = Get.put(BackButtonController());

  ScrollController scrollController = ScrollController();
  late SharedPrefs sharedPrefs;
  late FavoriteController favoriteController;

  List<Map<String, dynamic>> teachers = [];
  // Map<int, Uint8List> teachersImages = {};
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
      await getTeachersData();
    } else {
      if (cacheManager.isCacheEnabled.value == true) {
        await _loadCachedTeachers();
      }
    }
  }

  Future<void> _loadCachedTeachers() async {
    try {
      final cachedData = sharedPrefs.prefs.getString('cached_teachers');
      if (cachedData != null) {
        final List<dynamic> parsedList = jsonDecode(cachedData);
        setState(() {
          teachers = List<Map<String, dynamic>>.from(parsedList);
        });
      }
    } catch (e) {
      debugPrint("Error loading cached teachers: $e");
    }
  }

  Future<void> _cacheTeachers() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_teachers',
        jsonEncode(teachers),
      );
    } catch (e) {
      debugPrint("Error caching teachers: $e");
    }
  }

  Future<void> getTeachersData() async {
    // 1. Token validation with early return
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
      final APIurl = '$baseUrl/api/getallteachers';

      // 3. API request with timeout
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

      // 4. Response handling
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
            teachers = List<Map<String, dynamic>>.from(teachersList);
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
        if (teachers.isEmpty) {
          throw Exception("Failed to load teachers: ${response.statusCode}");
        }
      }
    } on TimeoutException {
      // If we have cached data, just show a warning
      if (teachers.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      // If we have cached data, just show a warning
      if (teachers.isEmpty) {
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
      onWillPop: controller.onWillPop,

      child: Scaffold(
        body:
            (cacheManager.isCacheEnabled.value == false &&
                    sharedPrefs.prefs.getBool('isConnected') == false)
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
                : teachers.isEmpty
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
                    await getTeachersData();
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
                          height: 80,
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
                                          "Teachers".tr,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall!.copyWith(
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
                                            fontFamily: globalFontFamily,
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
                                            elements: teachers,
                                            // elementsImages: teachersImages,
                                            searchType: 'teachers',
                                            onItemTap: (teacher) {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => TeacherDetails(
                                                        TeacherData: teacher,
                                                        // teacherImage:
                                                        //     teachersImages[teacher['id']],
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
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .slideX(begin: 0.5),
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
                                (teachers.isEmpty)
                                    ? noDataLottie("No data available")
                                    : Column(
                                      // shrinkWrap: true,
                                      children: [
                                        const SizedBox(height: 20),
                                        Center(
                                          child: Text(
                                            "Choose for more details".tr,
                                            style: TextStyle(
                                              fontSize:
                                                  globalFontSizeChange <= 17
                                                      ? (globalFontSizeChange /
                                                              5) +
                                                          22
                                                      : 22 -
                                                          (globalFontSizeChange /
                                                              5),
                                              fontWeight: FontWeight.bold,
                                              fontFamily: globalFontFamily,
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
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Expanded(
                                          child: GridView.builder(
                                            shrinkWrap: true,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                ),
                                            controller: scrollController,
                                            itemCount: teachers.length,
                                            itemBuilder: (context, i) {
                                              int teacherId = teachers[i]["id"];
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
                                                          ) => TeacherDetails(
                                                            TeacherData:
                                                                teachers[i],
                                                            // teacherImage:
                                                            //     teachersImages[teacherId],
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
                                                                teachers[i]["image"] !=
                                                                        null
                                                                    ? CachedNetworkImage(
                                                                      imageUrl:
                                                                          "$mainIP/${teachers[i]["image"]}",
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
                                                                  "${teachers[i]["name"]}"
                                                                      .tr,
                                                                  style: TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontSize:
                                                                        globalFontSizeChange >=
                                                                                17
                                                                            ? (globalFontSizeChange /
                                                                                    5) +
                                                                                16
                                                                            : 16 -
                                                                                (globalFontSizeChange /
                                                                                    5),
                                                                    fontFamily:
                                                                        globalFontFamily,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .normal,
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
                                                                ).animate().fadeIn(
                                                                  delay: 100.ms,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                    .animate(delay: (i * 50).ms)
                                                    .fadeIn(duration: 400.ms)
                                                    .slideY(
                                                      begin: 0.5,
                                                      end: 0,
                                                      curve: Curves.easeOutBack,
                                                      duration: 400.ms,
                                                    )
                                                    .scaleXY(
                                                      begin: 0.8,
                                                      end: 1,
                                                      duration: 500.ms,
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
      ),
    );
  }
}
