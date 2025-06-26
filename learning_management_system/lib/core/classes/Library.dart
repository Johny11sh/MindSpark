// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controller/NetworkController.dart';
import '../../locale/LocaleController.dart';
import '../../services/SharedPrefs.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../view/Favorites.dart';
import '../../view/LogIn.dart';
import '../../view/NavBar.dart';
import '../constants/ImageAssets.dart';
import 'BookDetails.dart';
import 'RecommendedBooks.dart';
import 'TopRatedBooks.dart';
import 'SubjectsBooks.dart';
// import '../constants/ImageAssets.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final NetworkController networkController = Get.find<NetworkController>();
  ScrollController scrollController = ScrollController();
  late SharedPrefs sharedPrefs;

  List<Map<String, dynamic>> recommendedBooks = [];
  Map<int, Uint8List> recommendedBooksImages = {};
  List<Map<String, dynamic>> topRatedBooks = [];
  Map<int, Uint8List> topRatedBooksImages = {};

  // Add recent books data
  List<Map<String, dynamic>> recentBooks = [];
  Map<int, Uint8List> recentBooksImages = {};

  // Add cache variables
  List<Map<String, dynamic>> cachedRecommendedBooks = [];
  List<Map<String, dynamic>> cachedTopRatedBooks = [];
  List<Map<String, dynamic>> cachedRecentBooks = [];

  // Add subjects data
  List<Map<String, dynamic>> scientificSubjects = [];
  List<Map<String, dynamic>> literarySubjects = [];
  final Map<int, Uint8List> subjectsImages = {};

  @override
  void initState() {
    super.initState();
    _initSharedPreferences().then((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

  Future<void> _loadInitialData() async {
    await _loadCachedData();
    await _loadCachedRecommendedBooks();
    await _loadCachedTopRatedBooks();
    await _loadCachedRecentBooks();
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await Future.wait([
        getSubjectsData('scientific'),
        getSubjectsData('literary'),
        getRecommendedBooksData(),
        getTopRatedBooksData(),
        getRecentBooksData(),
      ]);
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load scientific subjects data
      final cachedScientificSubjects = sharedPrefs.prefs.getString(
        'cached_scientific_subjects',
      );
      if (cachedScientificSubjects != null) {
        final List<dynamic> parsedScientificList = jsonDecode(
          cachedScientificSubjects,
        );
        scientificSubjects = List<Map<String, dynamic>>.from(
          parsedScientificList,
        );
      }

      // Load literary subjects data
      final cachedLiterarySubjects = sharedPrefs.prefs.getString(
        'cached_literary_subjects',
      );
      if (cachedLiterarySubjects != null) {
        final List<dynamic> parsedLiteraryList = jsonDecode(
          cachedLiterarySubjects,
        );
        literarySubjects = List<Map<String, dynamic>>.from(parsedLiteraryList);
      }

      // Load recommended books data
      final cachedRecommended = sharedPrefs.prefs.getString(
        'cached_recommended_books',
      );
      if (cachedRecommended != null) {
        final List<dynamic> parsedRecommendedList = jsonDecode(
          cachedRecommended,
        );
        cachedRecommendedBooks = List<Map<String, dynamic>>.from(
          parsedRecommendedList,
        );
        recommendedBooks = List.from(cachedRecommendedBooks);
      }

      // Load top-rated books data
      final cachedTopRated = sharedPrefs.prefs.getString(
        'cached_top_rated_books',
      );
      if (cachedTopRated != null) {
        final List<dynamic> parsedTopRatedList = jsonDecode(cachedTopRated);
        cachedTopRatedBooks = List<Map<String, dynamic>>.from(
          parsedTopRatedList,
        );
        topRatedBooks = List.from(cachedTopRatedBooks);
      }

      // Load recent books data
      await _loadCachedRecentBooks();

      // Load images for all types in parallel
      await Future.wait([
        _loadRecommendedBooksImages(),
        _loadTopRatedBooksImages(),
        _loadSubjectsImages(),
        _loadRecentBooksImages(),
      ]);
    } catch (e) {
      debugPrint("Error loading cached data: $e");
    }
  }

  Future<void> _loadSubjectsImages() async {
    for (var subject in scientificSubjects) {
      final imageKey = 'subject_image_${subject['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          subjectsImages[subject['id']] = base64Decode(cachedImage);
        });
      }
    }
    for (var subject in literarySubjects) {
      final imageKey = 'subject_image_${subject['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          subjectsImages[subject['id']] = base64Decode(cachedImage);
        });
      }
    }
  }

  Future<void> getSubjectsData(String subjectType) async {
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
      final APIurl = '$baseUrl/api/subjects/$subjectType';

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

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> subjectsList =
            responseBody is List
                ? responseBody
                : (responseBody['subjects'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            if (subjectType == 'scientific') {
              scientificSubjects = List<Map<String, dynamic>>.from(
                subjectsList,
              );
            } else {
              literarySubjects = List<Map<String, dynamic>>.from(subjectsList);
            }
          });
          await _cacheSubjectsData(subjectType);
        }

        await Future.wait(
          subjectsList.map((subject) async {
            final subjectId = subject['id'] as int;
            final imageBytes = await getSubjectImage(subject);
            if (imageBytes != null && mounted) {
              setState(() {
                subjectsImages[subjectId] = imageBytes;
              });
              await _cacheSubjectImage(subjectId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        showErrorSnackbar(
          "Failed to load $subjectType subjects: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Error fetching subjects for $subjectType: $e");
      showErrorSnackbar("Error loading $subjectType subjects: $e");
    }
  }

  Future<void> _cacheSubjectsData(String subjectType) async {
    try {
      if (subjectType == 'scientific') {
        await sharedPrefs.prefs.setString(
          'cached_scientific_subjects',
          jsonEncode(scientificSubjects),
        );
      } else {
        await sharedPrefs.prefs.setString(
          'cached_literary_subjects',
          jsonEncode(literarySubjects),
        );
      }
    } catch (e) {
      debugPrint("Error caching subjects data: $e");
    }
  }

  Future<void> _cacheSubjectImage(int subjectId, Uint8List imageBytes) async {
    try {
      await sharedPrefs.prefs.setString(
        'subject_image_$subjectId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching subject image: $e");
    }
  }

  Future<Uint8List?> getSubjectImage(dynamic subject) async {
    final subjectId = subject is Map ? subject['id'] as int : subject as int;
    final cachedImage = sharedPrefs.prefs.getString('subject_image_$subjectId');
    if (cachedImage != null) {
      return base64Decode(cachedImage);
    }

    if (sharedPrefs.prefs.getBool('isConnected') == false) {
      return null;
    }

    try {
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) return null;

      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final url = '$baseUrl/api/getsubjectimage/$subjectId';

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
        debugPrint("Subject image not found for ID: $subjectId");
        return null;
      } else {
        throw Exception("Image fetch failed: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for subject $subjectId");
      return null;
    } catch (e) {
      debugPrint("Error fetching subject image: $e");
      return null;
    }
  }

  Future<void> _loadRecommendedBooksImages() async {
    for (var book in recommendedBooks) {
      final imageKey = 'recommended_book_image_${book['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          recommendedBooksImages[book['id']] = base64Decode(cachedImage);
        });
      }
    }
  }

  Future<void> _loadTopRatedBooksImages() async {
    for (var book in topRatedBooks) {
      final imageKey = 'top_rated_book_image_${book['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          topRatedBooksImages[book['id']] = base64Decode(cachedImage);
        });
      }
    }
  }

  Future<void> _cacheRecommendedBooks() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_recommended_books',
        jsonEncode(recommendedBooks),
      );
      cachedRecommendedBooks = List.from(recommendedBooks);
    } catch (e) {
      debugPrint("Error caching recommended books: $e");
    }
  }

  Future<void> _cacheTopRatedBooks() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_top_rated_books',
        jsonEncode(topRatedBooks),
      );
      cachedTopRatedBooks = List.from(topRatedBooks);
    } catch (e) {
      debugPrint("Error caching top-rated books: $e");
    }
  }

  Future<void> _cacheRecommendedBookImage(
    int bookId,
    Uint8List imageBytes,
  ) async {
    try {
      await sharedPrefs.prefs.setString(
        'recommended_book_image_$bookId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching recommended book image: $e");
    }
  }

  Future<void> _cacheTopRatedBookImage(int bookId, Uint8List imageBytes) async {
    try {
      await sharedPrefs.prefs.setString(
        'top_rated_book_image_$bookId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching top-rated book image: $e");
    }
  }

  Future<void> getRecommendedBooksData() async {
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
      final APIurl = '$baseUrl/api/getallresourcesrecommended';

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

      if (response.statusCode == 200) {
        print("StatusCode                     200");

        final responseBody = jsonDecode(response.body);
        final List<dynamic> recommendedBooksList =
            responseBody is List
                ? responseBody
                : (responseBody['resources'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            recommendedBooks = List<Map<String, dynamic>>.from(
              recommendedBooksList,
            );
          });
          await _cacheRecommendedBooks();
        }

        await Future.wait(
          recommendedBooksList.map((book) async {
            final bookId = book['id'] as int;
            final imageBytes = await getRecommendedBookImage(book);
            if (imageBytes != null && mounted) {
              setState(() {
                recommendedBooksImages[bookId] = imageBytes;
              });
              await _cacheRecommendedBookImage(bookId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        print("StatusCode             not        200");

        if (recommendedBooks.isEmpty) {
          setState(() {
            recommendedBooks = List.from(cachedRecommendedBooks);
          });
          if (recommendedBooks.isEmpty) {
            showErrorSnackbar("Request timeout. Please try again.");
          } else {
            showErrorSnackbar("Using cached data - connection is slow");
          }
        }
      }
    } on TimeoutException {
      if (recommendedBooks.isEmpty) {
        setState(() {
          recommendedBooks = List.from(cachedRecommendedBooks);
        });
        if (recommendedBooks.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (recommendedBooks.isEmpty) {
        setState(() {
          recommendedBooks = List.from(cachedRecommendedBooks);
        });
        if (recommendedBooks.isEmpty) {
          showErrorSnackbar("Failed to load recommended books");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching recommended books: $e");
    }
  }

  Future<void> getTopRatedBooksData() async {
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
      final APIurl = '$baseUrl/api/getallresourcesrated';

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

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> topRatedBooksList =
            responseBody is List
                ? responseBody
                : (responseBody['resources'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            topRatedBooks = List<Map<String, dynamic>>.from(topRatedBooksList);
          });
          await _cacheTopRatedBooks();
        }

        await Future.wait(
          topRatedBooksList.map((book) async {
            final bookId = book['id'] as int;
            final imageBytes = await getTopRatedBookImage(book);
            if (imageBytes != null && mounted) {
              setState(() {
                topRatedBooksImages[bookId] = imageBytes;
              });
              await _cacheTopRatedBookImage(bookId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (topRatedBooks.isEmpty) {
          setState(() {
            topRatedBooks = List.from(cachedTopRatedBooks);
          });
          if (topRatedBooks.isEmpty) {
            showErrorSnackbar("Request timeout. Please try again.");
          } else {
            showErrorSnackbar("Using cached data - connection is slow");
          }
        }
      }
    } on TimeoutException {
      if (topRatedBooks.isEmpty) {
        setState(() {
          topRatedBooks = List.from(cachedTopRatedBooks);
        });
        if (topRatedBooks.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (topRatedBooks.isEmpty) {
        setState(() {
          topRatedBooks = List.from(cachedTopRatedBooks);
        });
        if (topRatedBooks.isEmpty) {
          showErrorSnackbar("Failed to load top-rated books");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching top-rated books: $e");
    }
  }

  Future<Uint8List?> getRecommendedBookImage(dynamic book) async {
    final bookId = book is Map ? book['id'] as int : book as int;
    final cachedImage = sharedPrefs.prefs.getString(
      'recommended_book_image_$bookId',
    );
    if (cachedImage != null) {
      return base64Decode(cachedImage);
    }

    if (sharedPrefs.prefs.getBool('isConnected') == false) {
      return null;
    }

    try {
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) return null;

      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final url = '$baseUrl/api/getresourceimage/$bookId';

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
        debugPrint("Recommended book image not found for ID: $bookId");
        return null;
      } else {
        throw Exception("Image fetch failed: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for recommended book $bookId");
      return null;
    } catch (e) {
      debugPrint("Error fetching recommended book image: $e");
      return null;
    }
  }

  Future<Uint8List?> getTopRatedBookImage(dynamic book) async {
    final bookId = book is Map ? book['id'] as int : book as int;
    final cachedImage = sharedPrefs.prefs.getString(
      'top_rated_book_image_$bookId',
    );
    if (cachedImage != null) {
      return base64Decode(cachedImage);
    }

    if (sharedPrefs.prefs.getBool('isConnected') == false) {
      return null;
    }

    try {
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) return null;

      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final url = '$baseUrl/api/getresourceimage/$bookId';

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
        debugPrint("Top-rated book image not found for ID: $bookId");
        return null;
      } else {
        throw Exception("Image fetch failed: ${response.statusCode}");
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for top-rated book $bookId");
      return null;
    } catch (e) {
      debugPrint("Error fetching top-rated book image: $e");
      return null;
    }
  }

  Future<void> _loadCachedRecentBooks() async {
    try {
      final cachedRecent = sharedPrefs.prefs.getString('cached_recent_books');
      if (cachedRecent != null) {
        final List<dynamic> parsedRecentList = jsonDecode(cachedRecent);
        cachedRecentBooks = List<Map<String, dynamic>>.from(parsedRecentList);
        recentBooks = List.from(cachedRecentBooks);
      }
      // Load images for recent books
      await _loadRecentBooksImages();
    } catch (e) {
      debugPrint("Error loading cached recent books: $e");
    }
  }

  Future<void> _loadRecentBooksImages() async {
    for (var book in recentBooks) {
      final imageKey = 'recent_book_image_${book['id']}';
      final cachedImage = sharedPrefs.prefs.getString(imageKey);
      if (cachedImage != null && mounted) {
        setState(() {
          recentBooksImages[book['id']] = base64Decode(cachedImage);
        });
      }
    }
  }

  Future<void> _cacheRecentBooks() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_recent_books',
        jsonEncode(recentBooks),
      );
      cachedRecentBooks = List.from(recentBooks);
    } catch (e) {
      debugPrint("Error caching recent books: $e");
    }
  }

  Future<void> _cacheRecentBookImage(int bookId, Uint8List imageBytes) async {
    try {
      await sharedPrefs.prefs.setString(
        'recent_book_image_$bookId',
        base64Encode(imageBytes),
      );
    } catch (e) {
      debugPrint("Error caching recent book image: $e");
    }
  }

  Future<void> getRecentBooksData() async {
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
      final APIurl = '$baseUrl/api/getallresourcesrecent';

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

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> recentBooksList =
            responseBody is List
                ? responseBody
                : (responseBody['resources'] ?? [responseBody]);

        if (mounted) {
          setState(() {
            recentBooks = List<Map<String, dynamic>>.from(recentBooksList);
          });
          await _cacheRecentBooks();
        }

        await Future.wait(
          recentBooksList.map((book) async {
            final bookId = book['id'] as int;
            final imageBytes = await getRecentBookImage(book);
            if (imageBytes != null && mounted) {
              setState(() {
                recentBooksImages[bookId] = imageBytes;
              });
              await _cacheRecentBookImage(bookId, imageBytes);
            }
          }),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        if (recentBooks.isEmpty) {
          setState(() {
            recentBooks = List.from(cachedRecentBooks);
          });
          if (recentBooks.isEmpty) {
            showErrorSnackbar("Request timeout. Please try again.");
          } else {
            showErrorSnackbar("Using cached data - connection is slow");
          }
        }
      }
    } on TimeoutException {
      if (recentBooks.isEmpty) {
        setState(() {
          recentBooks = List.from(cachedRecentBooks);
        });
        if (recentBooks.isEmpty) {
          showErrorSnackbar("Request timeout. Please try again.");
        } else {
          showErrorSnackbar("Using cached data - connection is slow");
        }
      }
    } catch (e) {
      if (recentBooks.isEmpty) {
        setState(() {
          recentBooks = List.from(cachedRecentBooks);
        });
        if (recentBooks.isEmpty) {
          showErrorSnackbar("Failed to load recent books");
        } else {
          showErrorSnackbar("Using cached data - ${e.toString()}");
        }
      }
      debugPrint("Error fetching recent books: $e");
    }
  }

  Future<Uint8List?> getRecentBookImage(dynamic book) async {
    final bookId = book is Map ? book['id'] as int : book as int;
    final cachedImage = sharedPrefs.prefs.getString(
      'recent_book_image_$bookId',
    );
    if (cachedImage != null) {
      return base64Decode(cachedImage);
    }

    if (sharedPrefs.prefs.getBool('isConnected') == false) {
      return null;
    }

    try {
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) return null;

      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final url = '$baseUrl/api/getresourceimage/$bookId';

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
        debugPrint("Recent book image not found for ID: $bookId");
        return null;
      } else {
        throw Exception(
          "Image fetch failed: " + response.statusCode.toString(),
        );
      }
    } on TimeoutException {
      debugPrint("Timeout loading image for recent book $bookId");
      return null;
    } catch (e) {
      debugPrint("Error fetching recent book image: $e");
      return null;
    }
  }

  Future<void> _loadCachedRecommendedBooks() async {
    try {
      final cachedRecommended = sharedPrefs.prefs.getString(
        'cached_recommended_books',
      );
      if (cachedRecommended != null) {
        final List<dynamic> parsedRecommendedList = jsonDecode(
          cachedRecommended,
        );
        cachedRecommendedBooks = List<Map<String, dynamic>>.from(
          parsedRecommendedList,
        );
        recommendedBooks = List.from(cachedRecommendedBooks);
      }
      await _loadRecommendedBooksImages();
    } catch (e) {
      debugPrint("Error loading cached recommended books: $e");
    }
  }

  Future<void> _loadCachedTopRatedBooks() async {
    try {
      final cachedTopRated = sharedPrefs.prefs.getString(
        'cached_top_rated_books',
      );
      if (cachedTopRated != null) {
        final List<dynamic> parsedTopRatedList = jsonDecode(cachedTopRated);
        cachedTopRatedBooks = List<Map<String, dynamic>>.from(
          parsedTopRatedList,
        );
        topRatedBooks = List.from(cachedTopRatedBooks);
      }
      await _loadTopRatedBooksImages();
    } catch (e) {
      debugPrint("Error loading cached top rated books: $e");
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
        // appBar: AppBar(
        //   leading: IconButton(
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => Favorites()),
        //       );
        //     },
        //     icon: Icon(Icons.favorite),
        //   ),
        //   title: Text("Library".tr),
        //   centerTitle: true,
        //   actions: [
        //     // IconButton(
        //     //   onPressed: () async {
        //     //     await networkController.checkConnectivityManually();
        //     //     await Future.wait([
        //     //       getSubjectsData('scientific'),
        //     //       getSubjectsData('literary'),
        //     //       getRecommendedBooksData(),
        //     //       getTopRatedBooksData(),
        //     //       getRecentBooksData(),
        //     //     ]);
        //     //   },
        //     //   icon: Icon(Icons.refresh),
        //     // ),
        //   ],
        // ),
        body:
            (scientificSubjects.isEmpty && literarySubjects.isEmpty)
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
                    await Future.wait([
                      getSubjectsData('scientific'),
                      getSubjectsData('literary'),
                      getRecommendedBooksData(),
                      getTopRatedBooksData(),
                      getRecentBooksData(),
                    ]);
                  },
                  child: Column(
                    // scrollDirection: Axis.vertical,
                    // physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 30),
                        height: 100,
                        color:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 210, 209, 224)
                                : Color.fromARGB(255, 40, 41, 61),
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
                                    right: Get.width / 8,
                                  ),

                                  child: Text(
                                    "Library".tr,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color:
                                themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Center(
                                child: Text(
                                  "Scientific Subjects".tr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color:
                                        themeController.initialTheme ==
                                                Themes.customLightTheme
                                            ? Color.fromARGB(255, 210, 209, 224)
                                            : Color.fromARGB(255, 40, 41, 61),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                // margin: EdgeInsets.only(left: 10),
                                height: 150,
                                child:
                                    scientificSubjects.isEmpty
                                        ? Center(
                                          child: Text(
                                            "No scientific subjects found",
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
                                            ),
                                          ),
                                        )
                                        : ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          itemCount: scientificSubjects.length,
                                          itemBuilder: (context, index) {
                                            int subjectId =
                                                scientificSubjects[index]["id"];
                                            Uint8List? imageBytes =
                                                subjectsImages[subjectId];

                                            return Container(
                                              margin: EdgeInsets.only(
                                                right: 10,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => SubjectsBooks(
                                                            subjectId:
                                                                subjectId,
                                                            subjectName:
                                                                scientificSubjects[index]["name"],
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                        left: 1,
                                                      ),
                                                      padding: EdgeInsets.all(
                                                        10,
                                                      ),
                                                      height: 120,
                                                      width: 120,
                                                      decoration: BoxDecoration(
                                                        // color: Colors.red,
                                                        border: Border.all(
                                                          color: Color.fromARGB(
                                                            255,
                                                            40,
                                                            41,
                                                            61,
                                                          ),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              15,
                                                            ),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          imageBytes != null
                                                              ?
                                                              //  CachedNetworkImage(
                                                              //   imageUrl:
                                                              //       "$mainIP/${scientificSubjects[index]["image"]}",
                                                              //   height: 60,
                                                              //   width: 60,
                                                              // )
                                                              Image.asset(
                                                                // ImageAssets.UserDarkMode,
                                                                ImageAssets
                                                                    .book,
                                                                height: 70,
                                                                width: 70,
                                                              )
                                                              : Image.asset(
                                                                // ImageAssets.UserDarkMode,
                                                                ImageAssets
                                                                    .book,
                                                                height: 70,
                                                                width: 70,
                                                              ),
                                                          // const SizedBox(
                                                          //   height: 10,
                                                          // ),
                                                          Text(
                                                            "${scientificSubjects[index]["name"]}"
                                                                .tr,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
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
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                              // SizedBox(height: 30),
                              // Literary Subjects Section
                              Center(
                                child: Text(
                                  "Literary Subjects".tr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color:
                                        themeController.initialTheme ==
                                                Themes.customLightTheme
                                            ? Color.fromARGB(255, 210, 209, 224)
                                            : Color.fromARGB(255, 40, 41, 61),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 120,
                                child:
                                    literarySubjects.isEmpty
                                        ? Center(
                                          child: Text(
                                            "No literary subjects found",
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
                                            ),
                                          ),
                                        )
                                        : ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          itemCount: literarySubjects.length,
                                          itemBuilder: (context, index) {
                                            int subjectId =
                                                literarySubjects[index]["id"];
                                            Uint8List? imageBytes =
                                                subjectsImages[subjectId];

                                            return Container(
                                              margin: EdgeInsets.only(
                                                right: 10,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => SubjectsBooks(
                                                            subjectId:
                                                                subjectId,
                                                            subjectName:
                                                                literarySubjects[index]["name"],
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                    left: 1,
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  height: 120,
                                                  width: 120,
                                                  decoration: BoxDecoration(
                                                    // color: Colors.red,
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                        255,
                                                        40,
                                                        41,
                                                        61,
                                                      ),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      imageBytes != null
                                                          ?
                                                          //  CachedNetworkImage(
                                                          //   imageUrl:
                                                          //       "$mainIP/${literarySubjects[index]["image"]}",
                                                          //   height: 60,
                                                          //   width: 60,
                                                          // )
                                                          Image.asset(
                                                            ImageAssets.book,
                                                            height: 70,
                                                            width: 70,
                                                          )
                                                          : Icon(
                                                            Icons.science,
                                                            size: 30,
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
                                                      // const SizedBox(
                                                      //   height: 10,
                                                      // ),
                                                      Text(
                                                        "${literarySubjects[index]["name"]}"
                                                            .tr,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                              ),
                              SizedBox(height: 25),
                              Center(
                                child: Text(
                                  "Recommended Books".tr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color:
                                        themeController.initialTheme ==
                                                Themes.customLightTheme
                                            ? Color.fromARGB(255, 210, 209, 224)
                                            : Color.fromARGB(255, 40, 41, 61),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 180,
                                child: GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                      ),
                                  controller: scrollController,
                                  itemCount: recommendedBooks.length + 1,
                                  itemBuilder: (context, i) {
                                    if (i == recommendedBooks.length) {
                                      return InkWell(
                                        onTap: () {
                                          //   Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder:
                                          //         (context) => RecommendedCourses(
                                          //         ),
                                          //   ),
                                          // );
                                        },
                                        child: Card(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                child: Icon(
                                                  Icons
                                                      .arrow_circle_right_outlined,
                                                  size: 40,
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
                                              Text(
                                                "More".tr,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18,
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
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    int uniId = recommendedBooks[i]["id"];
                                    Uint8List? imageBytes =
                                        recommendedBooksImages[uniId];

                                    return InkWell(
                                      onTap: () {
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder:
                                        //         (context) => CoursesLessons(
                                        //           CoursesData: recommendedCourses[i],
                                        //           index: i,
                                        //         ),
                                        //   ),
                                        // );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: 1,
                                          right: 10,
                                        ),
                                        // padding: EdgeInsets.only(left: 10,right: 10),
                                        padding: EdgeInsets.all(10),
                                        height: 130,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color.fromARGB(
                                              255,
                                              40,
                                              41,
                                              61,
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            if (recommendedBooks[i]["rating"] !=
                                                null)
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Container(
                                                  height: 23,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    // vertical: ,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    // color: Color(0XFF89EBB8),
                                                    // color: Color(0XFF76C49A),
                                                    // color: Color(0xFF94DDB3),
                                                    color: Color(0xFFCCF2E0),
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                        255,
                                                        40,
                                                        41,
                                                        61,
                                                      ),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        color: Color(
                                                          0XFFE6D827,
                                                        ),
                                                        // color:Color(0XFFEA4468),
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 2),
                                                      Text(
                                                        // "${recommendedBooks[i]["rating"]}",
                                                        double.parse(
                                                          recommendedBooks[i]["rating"]
                                                              .toString(),
                                                        ).toStringAsFixed(1),
                                                        style: TextStyle(
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          fontSize: 16,
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
                                              ),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(height: 24),
                                                  imageBytes != null
                                                      ? Image.asset(
                                                        ImageAssets.book,
                                                        height: 90,
                                                        width: 90,
                                                      )
                                                      : Image.asset(
                                                        ImageAssets.subject,
                                                      ),

                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "${recommendedBooks[i]["name"]}"
                                                          .tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
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

                              SizedBox(height: 30),
                              Center(
                                child: Text(
                                  "Top Rated Books".tr,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color:
                                        themeController.initialTheme ==
                                                Themes.customLightTheme
                                            ? Color.fromARGB(255, 210, 209, 224)
                                            : Color.fromARGB(255, 40, 41, 61),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 180,
                                child: GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                      ),
                                  controller: scrollController,
                                  itemCount: topRatedBooks.length + 1,
                                  itemBuilder: (context, i) {
                                    if (i == topRatedBooks.length) {
                                      return InkWell(
                                        onTap: () {
                                          //   Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder:
                                          //         (context) => RecommendedCourses(
                                          //         ),
                                          //   ),
                                          // );
                                        },
                                        child: Card(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                child: Icon(
                                                  Icons
                                                      .arrow_circle_right_outlined,
                                                  size: 40,
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
                                              Text(
                                                "More".tr,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18,
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
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    int uniId = topRatedBooks[i]["id"];
                                    Uint8List? imageBytes =
                                        topRatedBooksImages[uniId];

                                    return InkWell(
                                      onTap: () {
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder:
                                        //         (context) => CoursesLessons(
                                        //           CoursesData: recommendedCourses[i],
                                        //           index: i,
                                        //         ),
                                        //   ),
                                        // );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: 1,
                                          right: 10,
                                        ),
                                        // padding: EdgeInsets.only(left: 10,right: 10),
                                        padding: EdgeInsets.all(10),
                                        height: 130,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color.fromARGB(
                                              255,
                                              40,
                                              41,
                                              61,
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            if (topRatedBooks[i]["rating"] != null)
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Container(
                                                  height: 23,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    // vertical: ,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    // color: Color(0XFF89EBB8),
                                                    // color: Color(0XFF76C49A),
                                                    // color: Color(0xFF94DDB3),
                                                    color: Color(0xFFCCF2E0),
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                        255,
                                                        40,
                                                        41,
                                                        61,
                                                      ),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        color: Color(
                                                          0XFFE6D827,
                                                        ),
                                                        // color:Color(0XFFEA4468),
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 2),
                                                      Text(
                                                        double.parse(
                                                          topRatedBooks[i]["rating"]
                                                              .toString(),
                                                        ).toStringAsFixed(1),
                                                        style: TextStyle(
                                                          fontSize: 16,
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
                                              ),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(height: 24),
                                                  imageBytes != null
                                                      ? Image.asset(
                                                        ImageAssets.book,
                                                        height: 90,
                                                        width: 90,
                                                      )
                                                      : Image.asset(
                                                        ImageAssets.subject,
                                                      ),

                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "${topRatedBooks[i]["name"]}"
                                                          .tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
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

                              SizedBox(height: 30),
                              Center(
                                child: Text(
                                  "Most Recent Books".tr,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    color:
                                        themeController.initialTheme ==
                                                Themes.customLightTheme
                                            ? Color.fromARGB(255, 210, 209, 224)
                                            : Color.fromARGB(255, 40, 41, 61),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 180,
                                child: GridView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                      ),
                                  controller: scrollController,
                                  itemCount: recentBooks.length + 1,
                                  itemBuilder: (context, i) {
                                    if (i == recentBooks.length) {
                                      return InkWell(
                                        onTap: () {
                                          //   Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder:
                                          //         (context) => RecommendedCourses(
                                          //         ),
                                          //   ),
                                          // );
                                        },
                                        child: Card(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                child: Icon(
                                                  Icons
                                                      .arrow_circle_right_outlined,
                                                  size: 40,
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
                                              Text(
                                                "More".tr,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18,
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
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    int uniId = recentBooks[i]["id"];
                                    Uint8List? imageBytes =
                                        recentBooksImages[uniId];

                                    return InkWell(
                                      onTap: () {
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder:
                                        //         (context) => CoursesLessons(
                                        //           CoursesData: recommendedCourses[i],
                                        //           index: i,
                                        //         ),
                                        //   ),
                                        // );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          left: 1,
                                          right: 10,
                                        ),
                                        // padding: EdgeInsets.only(left: 10,right: 10),
                                        padding: EdgeInsets.all(10),
                                        height: 130,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color.fromARGB(
                                              255,
                                              40,
                                              41,
                                              61,
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            if(recentBooks[i]["rating"] != null)
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                height: 23,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  // vertical: ,
                                                ),
                                                decoration: BoxDecoration(
                                                  // color: Color(0XFF89EBB8),
                                                  // color: Color(0XFF76C49A),
                                                  // color: Color(0xFF94DDB3),
                                                  color: Color(0xFFCCF2E0),
                                                  border: Border.all(
                                                    color: Color.fromARGB(
                                                      255,
                                                      40,
                                                      41,
                                                      61,
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      color: Color(0XFFE6D827),
                                                      // color:Color(0XFFEA4468),
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 2),
                                                    Text(
                                                      // "4.3",
                                                      double.parse(
                                                        recentBooks[i]["rating"]
                                                            .toString(),
                                                      ).toStringAsFixed(1),

                                                      style: TextStyle(
                                                        fontSize: 16,
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
                                            ),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(height: 24),
                                                  imageBytes != null
                                                      ? Image.asset(
                                                        ImageAssets.book,
                                                        height: 90,
                                                        width: 90,
                                                      )
                                                      : Image.asset(
                                                        ImageAssets.subject,
                                                      ),

                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "${recentBooks[i]["name"]}"
                                                          .tr,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                              SizedBox(height: 30),
                            ],
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
