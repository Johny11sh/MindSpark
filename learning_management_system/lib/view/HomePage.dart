// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:learning_management_system/view/Favorites.dart';
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

  List<Map<String, dynamic>> subjects = [];
  final Map<int, Uint8List> subjectsImages = {};
  bool isFavorite = false;
  bool isLiterary = false;
  String subjectType = 'scientific';

  List<bool> isSelected = [true, false];

  // Add new variables for caching
  List<Map<String, dynamic>> scientificSubjects = [];
  List<Map<String, dynamic>> literarySubjects = [];

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
      await getSubjectsData(subjectType);
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load scientific subjects data
      final cachedScientificSubjects = sharedPrefs.prefs.getString('cached_scientific_subjects');
      if (cachedScientificSubjects != null) {
        final List<dynamic> parsedScientificList = jsonDecode(cachedScientificSubjects);
        scientificSubjects = List<Map<String, dynamic>>.from(parsedScientificList);
      }

      // Load literary subjects data
      final cachedLiterarySubjects = sharedPrefs.prefs.getString('cached_literary_subjects');
      if (cachedLiterarySubjects != null) {
        final List<dynamic> parsedLiteraryList = jsonDecode(cachedLiterarySubjects);
        literarySubjects = List<Map<String, dynamic>>.from(parsedLiteraryList);
      }

      // Set initial subjects based on current subjectType
      setState(() {
        subjects = subjectType == 'scientific' ? scientificSubjects : literarySubjects;
      });

      // Load subjects images for both lists
      await _loadImagesForSubjects(scientificSubjects);
      await _loadImagesForSubjects(literarySubjects);
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  Future<void> _loadImagesForSubjects(List<Map<String, dynamic>> subjectList) async {
    for (var subject in subjectList) {
      final imageKey = 'subject_image_${subject['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          subjectsImages[subject['id']] = base64Decode(cachedImage);
        });
      }
    }
  }

  Future<void> _cacheSubjectsData() async {
    try {
      if (subjectType == 'scientific') {
        await sharedPrefs.prefs.setString(
          'cached_scientific_subjects',
          jsonEncode(subjects),
        );
        scientificSubjects = List.from(subjects);
      } else {
        await sharedPrefs.prefs.setString(
          'cached_literary_subjects',
          jsonEncode(subjects),
        );
        literarySubjects = List.from(subjects);
      }
    } catch (e) {
      debugPrint("Error caching subjects data: $e");
    }
  }

  Future<void> _cacheSubjectImage(int uniId, Uint8List imageBytes) async {
    try {
      await sharedPrefs.prefs.setString(
        'subject_image_$uniId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching subject image: $e");
    }
  }

  Future<void> getSubjectsData(String subjectType) async {
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
      final APIurl = '$baseUrl/api/subjects/$subjectType';

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

      debugPrint("Subjects API response: ${response.statusCode}");

      // 4. Response Handling
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Handle both array and object responses
        final List<dynamic> subjectsList =
            responseBody is List
                ? responseBody
                : (responseBody['subjects'] ?? [responseBody]);

        // 5. Update state and cache
        if (mounted) {
          setState(() {
            subjects = List<Map<String, dynamic>>.from(subjectsList);
          });
          await _cacheSubjectsData();
        }

        // 6. Parallel Image Loading and caching
        await Future.wait(
          subjectsList.map((uni) async {
            final uniId = uni["id"] as int;
            final imageBytes = await getSubjectImage(uni);
            if (imageBytes != null && mounted) {
              setState(() {
                subjectsImages[uniId] = imageBytes;
              });
              await _cacheSubjectImage(uniId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        // If API fails, use cached data for the current subject type
        if (subjects.isEmpty) {
          setState(() {
            subjects = subjectType == 'scientific' ? scientificSubjects : literarySubjects;
          });
          if (subjects.isEmpty) {
            throw Exception(
              "Failed to load subjects: ${response.statusCode}",
            );
          }
        }
      }
    } on TimeoutException {
      // If we have cached data, use it
      if (subjects.isEmpty) {
        setState(() {
          subjects = subjectType == 'scientific' ? scientificSubjects : literarySubjects;
        });
        if (subjects.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      // If we have cached data, use it
      if (subjects.isEmpty) {
        setState(() {
          subjects = subjectType == 'scientific' ? scientificSubjects : literarySubjects;
        });
        if (subjects.isEmpty) {
          showErrorSnackbar("Failed to load subjects");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching subjects: $e");
    }
  }

  Future<Uint8List?> getSubjectImage(dynamic subject) async {
    // First try to get from cache
    final uniId =
        subject is Map ? subject['id'] as int : subject as int;
    final cachedImage = sharedPrefs.prefs.getString('subject_image_$uniId');
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
      final url = '$baseUrl/api/getsubjectimage/$uniId';

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
        debugPrint("Subject image not found for ID: $uniId");
        return null;
      } else {
        throw Exception("Image fetch failed: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for subject $uniId");
      return null;
    } catch (e) {
      debugPrint("Error fetching subject image: $e");
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
          title: Text("Home Page".tr),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SearchCustom(subjects, subjectsImages),
                );
              },
              icon: Icon(Icons.search_outlined),
            ),
          ],
        ),
        body: subjects.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                  color: themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 40, 41, 61)
                      : Color.fromARGB(255, 210, 209, 224),
                ),
              )
            : RefreshIndicator(
                color: themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 40, 41, 61)
                    : Color.fromARGB(255, 210, 209, 224),
                backgroundColor: themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 46, 48, 97),
                onRefresh: () async {
                  await networkController.checkConnectivityManually();
                  await getSubjectsData(subjectType);
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
                      borderColor: themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 40, 41, 61)
                          : Color.fromARGB(255, 210, 209, 224),
                      selectedBorderColor: themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 40, 41, 61)
                          : Color.fromARGB(255, 210, 209, 224),
                      fillColor: themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 40, 41, 61)
                          : Color.fromARGB(255, 210, 209, 224),
                      selectedColor: themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 210, 209, 224)
                          : Color.fromARGB(255, 40, 41, 61),
                      onPressed: (int newIndex) {
                        setState(() {
                          for (int index = 0; index < isSelected.length; index++) {
                            isSelected[index] = index == newIndex;
                          }
                          isLiterary = newIndex == 1;
                          subjectType = isLiterary ? 'literary' : 'scientific';
                          subjects = subjectType == 'scientific' ? scientificSubjects : literarySubjects;
                        });
                        if (sharedPrefs.prefs.getBool('isConnected') == true) {
                          getSubjectsData(subjectType);
                        }
                      },
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isSelected[0] = true;
                              isSelected[1] = false;
                              isLiterary = false;
                              subjectType = "scientific";
                              subjects = scientificSubjects;
                            });
                            if (sharedPrefs.prefs.getBool('isConnected') == true) {
                              getSubjectsData(subjectType);
                            }
                          },
                          child: Text(
                            "Scientific".tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: themeController.initialTheme == Themes.customLightTheme
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
                              isLiterary = true;
                              subjectType = "literary";
                              subjects = literarySubjects;
                            });
                            if (sharedPrefs.prefs.getBool('isConnected') == true) {
                              getSubjectsData(subjectType);
                            }
                          },
                          child: Text(
                            "Literary".tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: themeController.initialTheme == Themes.customLightTheme
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
                    SizedBox(height: 30),
                    Expanded(
                      child: GridView.builder(
                        scrollDirection: Axis.vertical,
                        physics: AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                        controller: scrollController,
                        itemCount: subjects.length,
                        itemBuilder: (context, i) {
                          int uniId = subjects[i]["id"];
                          Uint8List? imageBytes = subjectsImages[uniId];

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SubjectTeachers(
                                        SubjectData: subjects[i],
                                      ),
                                ),
                              );
                            },
                            child: Card(
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 3,
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
                                                  ImageAssets.subject,
                                                  height: 125,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )
                                            : Image.asset(
                                              ImageAssets.subject,
                                            ),
                                  ),
                                  SizedBox(height: 30),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "${subjects[i]["name"]}".tr,
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
                              ImageAssets.subject,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                        : Image.asset(
                          ImageAssets.subject,
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
                            ImageAssets.subject,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                      : Image.asset(
                        ImageAssets.subject,
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
