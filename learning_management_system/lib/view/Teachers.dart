// ignore_for_file: must_be_immutable, use_build_context_synchronously, unnecessary_null_comparison
// ignore_for_file: avoid_print, non_constant_identifier_names, file_names

import 'dart:async';
import 'dart:convert';
import 'package:like_button/like_button.dart';

import '../controller/FavoriteController.dart';
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

class Teachers extends StatefulWidget {
  const Teachers({super.key});

  @override
  State<Teachers> createState() => _TeachersState();
}

class _TeachersState extends State<Teachers> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final NetworkController networkController = Get.find<NetworkController>();
  ScrollController scrollController = ScrollController();
  late SharedPrefs sharedPrefs;
  late FavoriteController favoriteController;

  List<Map<String, dynamic>> teachers = [];
  Map<int, Uint8List> teachersImages = {};

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
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    // Try to load from cache first
    await _loadCachedTeachers();

    // Then try to fetch fresh data if online
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getTeachersData();
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

        // Load cached images
        for (final teacher in teachers) {
          final imageKey = 'teacher_image_${teacher['id']}';
          final imageString = sharedPrefs.prefs.getString(imageKey);
          if (imageString != null && mounted) {
            setState(() {
              teachersImages[teacher['id']] = base64Decode(imageString);
            });
          }
        }
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

  Future<void> _cacheTeacherImage(int teacherId, Uint8List imageBytes) async {
    try {
      await sharedPrefs.prefs.setString(
        'teacher_image_$teacherId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching teacher image: $e");
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
          await _cacheTeachers();
        }

        // 6. Parallel Image Loading and caching
        await Future.wait(
          teachersList.map((teacher) async {
            final teacherId = teacher['id'] as int;
            final imageBytes = await getTeachersImage(teacher);
            if (imageBytes != null && mounted) {
              setState(() {
                teachersImages[teacherId] = imageBytes;
              });
              await _cacheTeacherImage(teacherId, imageBytes);
            }
          }),
        );
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

  Future<Uint8List?> getTeachersImage(dynamic teacher) async {
    // First try to get from cache
    final teacherId = teacher is Map ? teacher['id'] as int : teacher as int;
    final cachedImage = sharedPrefs.prefs.getString('teacher_image_$teacherId');
    if (cachedImage != null) {
      return base64Decode(cachedImage);
    }

    // If not in cache and offline, return null
    if (sharedPrefs.prefs.getBool('isConnected') == false) {
      return null;
    }

    // Otherwise fetch from API
    try {
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) return null;

      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final url = '$baseUrl/api/getteacherimage/$teacherId';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': "Bearer $token",
              'Accept': 'application/octet-stream',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 404) {
        debugPrint("Teacher image not found for ID: $teacherId");
        return null;
      } else {
        throw Exception("Image fetch failed: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for teacher $teacherId");
      return null;
    } catch (e) {
      debugPrint("Error fetching teacher image: $e");
      return null;
    }
  }

  void showErrorSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(message),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red[800]!,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Favorites()),
              );
            },
            icon: Icon(Icons.favorite),
          ),
          title: Text("Teachers".tr),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SearchCustom(teachers, teachersImages),
                );
              },
              icon: Icon(Icons.search_outlined),
            ),
          ],
        ),
        body:
            teachers.isEmpty
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
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      Text(
                        "Choose a teacher for more details".tr,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                        ),
                      ),
                      SizedBox(height: 50),
                      Expanded(
                        child: GridView.builder(
                          scrollDirection: Axis.vertical,
                          physics: AlwaysScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                              ),
                          controller: scrollController,
                          itemCount: teachers.length,
                          itemBuilder: (context, i) {
                            int teacherId = teachers[i]["id"];
                            Uint8List? imageBytes = teachersImages[teacherId];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => TeacherDetails(
                                          TeacherData: teachers[i],
                                          teacherImage:
                                              teachersImages[teacherId],
                                        ),
                                  ),
                                );
                              },
                              child: Card(
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
                                      GetBuilder<FavoriteController>(
                                        builder: (controller) {
                                          final isFav =
                                              controller.isFavorite[teacherId
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
                                                teacherId.toString(),
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
                                          SizedBox(height: 20),
                                          Expanded(
                                            flex: 5,
                                            child:
                                                imageBytes != null
                                                    ? Image.memory(
                                                      imageBytes,
                                                      fit: BoxFit.fill,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Image.asset(
                                                          ImageAssets.teacher,
                                                          height: 125,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    )
                                                    : Image.asset(
                                                      ImageAssets.teacher,
                                                    ),
                                          ),
                                          SizedBox(height: 30),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              "${teachers[i]["name"]}".tr,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

class SearchCustom extends SearchDelegate {
  final List elements;
  final Map<int, Uint8List> elementsImages;

  SearchCustom(this.elements, this.elementsImages);

  List? sortedItems;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.cleaning_services),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    sortedItems =
        elements
            .where(
              (element) =>
                  element["name"].toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return ListView.builder(
      itemCount: sortedItems!.length,
      itemBuilder: (context, index) {
        int elementsId = sortedItems![index]["id"];
        Uint8List? imageBytes =
            elementsImages[elementsId]; // Fetch from storeImages map

        return InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TeacherDetails(
                      TeacherData: sortedItems![index],
                      teacherImage: elementsImages[elementsId],
                    ),
              ),
            );
          },
          child: SizedBox(
            height: 100,
            child: Card(
              child: ListTile(
                leading:
                    imageBytes != null
                        ? Image.memory(
                          imageBytes,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              ImageAssets.teacher,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                        : Image.asset(
                          ImageAssets.teacher,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                title: Text(
                  sortedItems![index]["name"],
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 40, 41, 61)
                            : Color.fromARGB(255, 210, 209, 224),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    sortedItems =
        elements
            .where(
              (element) =>
                  element["name"].toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    return ListView.builder(
      itemCount: sortedItems!.length,
      itemBuilder: (context, index) {
        int elementsId = sortedItems![index]["id"];
        Uint8List? imageBytes =
            elementsImages[elementsId]; // Fetch from storeImages map

        return SizedBox(
          height: 100,
          child: Card(
            child: ListTile(
              leading:
                  imageBytes != null
                      ? Image.memory(
                        imageBytes,
                        // height: 80,
                        // width:80,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            ImageAssets.teacher,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                      : Image.asset(
                        ImageAssets.teacher,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
              title: Center(
                child: Text(
                  sortedItems![index]["name"],
                  style: TextStyle(
                    fontSize: 20,
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 40, 41, 61)
                            : Color.fromARGB(255, 210, 209, 224),
                  ),
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TeacherDetails(
                          TeacherData: sortedItems![index],
                          teacherImage: elementsImages[elementsId],
                        ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
