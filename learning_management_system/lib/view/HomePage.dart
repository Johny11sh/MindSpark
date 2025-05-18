// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:learning_management_system/view/SubjectTeachers.dart';
import '../controller/NetworkController.dart';
import '../locale/LocaleController.dart';
import '../services/SharedPrefs.dart';
import '../core/constants/ImageAssets.dart';
import '../themes/ThemeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'LogIn.dart';
import 'NavBar.dart';
import '../themes/Themes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController scrollController = ScrollController();
  late SharedPrefs sharedPrefs;

  final ThemeController themeController = Get.find<ThemeController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final LocaleController localeController = Get.find<LocaleController>();

  List<Map<String, dynamic>> universities = [];
  final Map<int, Uint8List> universitiesImages = {};
  bool isFavorite = false;

  List<bool> isSelected = [true, false];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _initSharedPreferences().then((_) => _loadInitialData());
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    // Try to load from cache first
    await _loadCachedData();

    // Then try to fetch fresh data if online
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getUniversitiesData();
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load universities data
      final cachedUniversities = sharedPrefs.prefs.getString(
        'cached_universities',
      );
      if (cachedUniversities != null) {
        final List<dynamic> parsedList = jsonDecode(cachedUniversities);
        setState(() {
          universities = List<Map<String, dynamic>>.from(parsedList);
        });
      }

      // Load universities images
      universities.forEach((uni) async {
        final imageKey = 'university_image_${uni['id']}';
        final cachedImage = sharedPrefs.prefs.getString(imageKey);
        if (cachedImage != null && mounted) {
          setState(() {
            universitiesImages[uni['id']] = base64Decode(cachedImage);
          });
        }
      });
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  Future<void> _cacheUniversitiesData() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_universities',
        jsonEncode(universities),
      );
    } catch (e) {
      debugPrint("Error caching universities data: $e");
    }
  }

  Future<void> _cacheUniversityImage(int uniId, Uint8List imageBytes) async {
    try {
      await sharedPrefs.prefs.setString(
        'university_image_$uniId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching university image: $e");
    }
  }

  Future<void> getUniversitiesData() async {
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
      const baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://192.168.1.7:8000',
      );
      final APIurl = '$baseUrl/api/getalluniversities';

      // 3. API Request
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

      debugPrint("Universities API response: ${response.statusCode}");

      // 4. Response Handling
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Handle both array and object responses
        final List<dynamic> universitiesList =
            responseBody is List
                ? responseBody
                : (responseBody['universities'] ?? [responseBody]);

        // 5. Update state and cache
        if (mounted) {
          setState(() {
            universities = List<Map<String, dynamic>>.from(universitiesList);
          });
          await _cacheUniversitiesData();
        }

        // 6. Parallel Image Loading and caching
        await Future.wait(
          universitiesList.map((uni) async {
            final uniId = uni["id"] as int;
            final imageBytes = await getUniversityImage(uni);
            if (imageBytes != null && mounted) {
              setState(() {
                universitiesImages[uniId] = imageBytes;
              });
              await _cacheUniversityImage(uniId, imageBytes);
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
        if (universities.isEmpty) {
          throw Exception(
            "Failed to load universities: ${response.statusCode}",
          );
        }
      }
    } on TimeoutException {
      // If we have cached data, just show a warning
      if (universities.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.");
      } else {
        showErrorSnackbar("Using cached data - connection is slow");
      }
    } catch (e) {
      // If we have cached data, just show a warning
      if (universities.isEmpty) {
        showErrorSnackbar("Failed to load universities");
      } else {
        showErrorSnackbar("Using cached data - ${e.toString()}");
      }
      debugPrint("Error fetching universities: $e");
    }
  }

  Future<Uint8List?> getUniversityImage(dynamic university) async {
    // First try to get from cache
    final uniId =
        university is Map ? university['id'] as int : university as int;
    final cachedImage = sharedPrefs.prefs.getString('university_image_$uniId');
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

      const baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://192.168.1.7:8000',
      );
      final url = '$baseUrl/api/getuniversityimage/$uniId';

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
        debugPrint("University image not found for ID: $uniId");
        return null;
      } else {
        throw Exception("Image fetch failed: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for university $uniId");
      return null;
    } catch (e) {
      debugPrint("Error fetching university image: $e");
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
          title: Text("Home Page".tr),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SearchCustom(universities, universitiesImages),
                );
              },
              icon: Icon(Icons.search_outlined),
            ),
          ],
        ),
        body:
            universities.isEmpty
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
                    await getUniversitiesData();
                  },
                  child: Column(
                    children: [
                      SizedBox(height: 30),

                      ToggleButtons(
                        isSelected: isSelected,

                        direction: Axis.horizontal,
                        constraints: BoxConstraints(
                          minWidth: Get.width / 3,
                          maxWidth: Get.width / 3,
                        ),
                        borderWidth: 3,
                        borderRadius: BorderRadius.circular(25),
                        borderColor:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                        selectedBorderColor:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                        fillColor:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                        selectedColor:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 210, 209, 224)
                                : Color.fromARGB(255, 40, 41, 61),
                        // highlightColor:Color.fromARGB(255, 254, 233, 204),
                        onPressed: (int newIndex) {
                          setState(() {
                            // for ( int index = 0; index <isSelected.length; index++){
                            //   if(index == newIndex){
                            //     isSelected[index] = true;
                            //   }else{
                            //     isSelected[index]= false;
                            //   }
                            // }
                          });
                        },

                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelected[0] = true;
                                isSelected[1] = false;
                              });
                            },
                            child: Text(
                              "Scientific".tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? isSelected[0]
                                            ? Color.fromARGB(255, 210, 209, 224)
                                            : Color.fromARGB(255, 40, 41, 61)
                                        : isSelected[0]
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSelected[1] = true;
                                isSelected[0] = false;
                              });
                            },
                            child: Text(
                              "Literary".tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? isSelected[1]
                                            ? Color.fromARGB(255, 210, 209, 224)
                                            : Color.fromARGB(255, 40, 41, 61)
                                        : isSelected[1]
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30),
                      Text(
                        "Choose a subject".tr,
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
                          itemCount: universities.length,
                          itemBuilder: (context, i) {
                            int uniId = universities[i]["id"];
                            Uint8List? imageBytes = universitiesImages[uniId];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => SubjectTeachers(
                                          SubjectData: universities[i],
                                        ),
                                  ),
                                );
                              },
                              child: Card(
                                child: Column(
                                  children: [
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
                                                    ImageAssets.university,
                                                    height: 125,
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              )
                                              : Image.asset(
                                                ImageAssets.university,
                                              ),
                                    ),
                                    SizedBox(height: 30),
                                    Expanded(
                                      flex: 2,
                                      child: 
                                          Text(
                                            "${universities[i]["name"]}".tr,
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
        Uint8List? imageBytes = elementsImages[elementsId];

        return InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        SubjectTeachers(SubjectData: sortedItems![index]),
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
                              ImageAssets.university,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                        : Image.asset(
                          ImageAssets.university,
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
        Uint8List? imageBytes = elementsImages[elementsId];

        return SizedBox(
          height: 100,
          child: Card(
            child: ListTile(
              leading:
                  imageBytes != null
                      ? Image.memory(
                        imageBytes,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            ImageAssets.university,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                      : Image.asset(
                        ImageAssets.university,
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
                        (context) =>
                            SubjectTeachers(SubjectData: sortedItems![index]),
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
