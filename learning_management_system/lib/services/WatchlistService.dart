// ignore_for_file: file_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/WatchlistModel.dart';
import '../view/NavBar.dart';
import 'SharedPrefs.dart';

class WatchlistService {
  static final String _baseUrl = '$mainIP/api';
  static const Duration _timeout = Duration(seconds: 30);

  late SharedPrefs _sharedPrefs;

  WatchlistService() {
    _sharedPrefs = SharedPrefs.instance;
  }

  Future<String?> _getAuthToken() async {
    return _sharedPrefs.prefs.getString('token');
  }

  Map<String, String> _getAuthHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  Future<Map<String, String>> _getAuthHeadersWithToken() async {
    final token = await _getAuthToken();
    final headers = _getAuthHeaders();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Get user's watchlist lectures
  Future<List<WatchlistModel>> getWatchlistLectures() async {
    try {
      final headers = await _getAuthHeadersWithToken();
      final response = await http
          .get(Uri.parse('$_baseUrl/getwatchlistlectures'), headers: headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => WatchlistModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 404) {
        return []; // No watchlist items found
      } else {
        throw Exception(
          'Failed to load watchlist lectures: ${response.statusCode}',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Connection error. Please check your internet connection.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Get user's watchlist courses
  Future<List<WatchlistModel>> getWatchlistCourses() async {
    try {
      final headers = await _getAuthHeadersWithToken();
      final response = await http
          .get(Uri.parse('$_baseUrl/getwatchlistcourses'), headers: headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => WatchlistModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 404) {
        return []; // No watchlist items found
      } else {
        throw Exception(
          'Failed to load watchlist courses: ${response.statusCode}',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Connection error. Please check your internet connection.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Toggle lecture in watchlist
  Future<bool> toggleWatchlistLecture(String lectureId) async {
    try {
      final headers = await _getAuthHeadersWithToken();
      final response = await http
          .post(
            Uri.parse('$_baseUrl/togglewatchlistlecture/$lectureId'),
            headers: headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData['success'] ?? false;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception(
          'Failed to toggle lecture watchlist: ${response.statusCode}',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Connection error. Please check your internet connection.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Toggle course in watchlist
  Future<bool> toggleWatchlistCourse(String courseId) async {
    try {
      final headers = await _getAuthHeadersWithToken();
      final response = await http
          .post(
            Uri.parse('$_baseUrl/togglewatchlistcourse/$courseId'),
            headers: headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData['success'] ?? false;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception(
          'Failed to toggle course watchlist: ${response.statusCode}',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Connection error. Please check your internet connection.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Update watchlist item status
  Future<bool> updateWatchlistItemStatus(String itemId, String status) async {
    try {
      final headers = await _getAuthHeadersWithToken();
      final response = await http
          .put(
            Uri.parse('$_baseUrl/watchlist/$itemId'),
            headers: headers,
            body: jsonEncode({'status': status}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData['success'] ?? false;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception(
          'Failed to update watchlist item: ${response.statusCode}',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Connection error. Please check your internet connection.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Remove item from watchlist
  Future<bool> removeFromWatchlist(String itemId) async {
    try {
      final headers = await _getAuthHeadersWithToken();
      final response = await http
          .delete(Uri.parse('$_baseUrl/watchlist/$itemId'), headers: headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData['success'] ?? false;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception(
          'Failed to remove item from watchlist: ${response.statusCode}',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Connection error. Please check your internet connection.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
