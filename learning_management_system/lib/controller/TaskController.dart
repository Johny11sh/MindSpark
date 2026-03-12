// ignore_for_file: file_names, unrelated_type_equality_checks, non_constant_identifier_names, duplicate_ignore
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/constants/FontGlobals.dart';
import '../core/function/SnackBarFun.dart';
import '../view/LogIn.dart';
import '../view/NavBar.dart';
import '../view/OnBoarding.dart';
// import '../core/classes/TasksScreen.dart';

class Task {
  int id;
  String title;
  String description;
  DateTime createdAt;
  DateTime? dueDate;
  double estimatedHours;
  bool isChecked;
  bool isTrashed;
  final int userId;

  // ignore: non_constant_identifier_names
  DateTime? trashed_at;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.dueDate,
    this.estimatedHours = 1,
    this.isChecked = false,
    this.isTrashed = false,
    required this.userId,

    // ignore: non_constant_identifier_names
    this.trashed_at,
  });
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isChecked: (json['isChecked'] as int?) == 1,
      isTrashed: (json['isTrashed'] as int?) == 1,
      userId: json['user_id'] as int? ?? 0,
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble() ?? 0.0,
      // trashed_at: DateTime.parse(json['trashed_at'] as String? ?? '2025-01-01'),
      dueDate: DateTime.parse(
        json['dueDate'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['created_at'] as String? ??
            DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'estimatedHours': estimatedHours,
      'isChecked': isChecked,
      'isTrashed': isTrashed,
      if (trashed_at != null) 'deletedAt': trashed_at!.toIso8601String(),
    };
  }
}

class TaskController extends GetxController {
  final ApiService apiService = ApiService();
  final RxList<Task> tasks = <Task>[].obs;
  final RxList<Task> deletedTasks = <Task>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      tasks.value = await apiService.getTasks();
      deletedTasks.value = await apiService.getTrashTasks();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  List<Task> get activeTasks =>
      tasks.where((task) => !task.isTrashed && !task.isChecked).toList();
  List<Task> get completedTasks =>
      tasks.where((task) => !task.isTrashed && task.isChecked).toList();

  Future<void> addTask(
    String title,
    String text,
    double estimatedHours,
    String dueDate,
  ) async {
    try {
      isLoading.value = true;
      final newTask = await apiService.addTask(
        title,
        text,
        estimatedHours,
        dueDate,
      );
      tasks.add(newTask);
      fetchTasks();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleComplete(int taskId) async {
    try {
      await apiService.checkTask(taskId);
      final taskIndex = tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        tasks[taskIndex].isChecked = !tasks[taskIndex].isChecked;
        tasks.refresh();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> moveToTrash(int taskId) async {
    try {
      isLoading.value = true;
      await apiService.trashTask(taskId);
      await fetchTasks();
    } catch (e) {
      //errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTask(
    String taskId,
    String text,
    double estimatedHours,
  ) async {
    try {
      isLoading.value = true;
      final updatedTask = await apiService.editTask(
        taskId as int,
        text,
        estimatedHours,
      );

      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        tasks[index] = updatedTask!;
        tasks.refresh();
      }
      Get.back();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> permanentDelete(int taskId) async {
    try {
      isLoading.value = true;
      await apiService.deleteTask(taskId);
      await fetchTasks();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restoreTask(int taskId) async {
    try {
      isLoading.value = true;
      await apiService.restoreTask(taskId);
      await fetchTasks();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

class ApiService {
  Future<List<Task>> getTasks() async {
    final token = sharedPrefs.prefs.getString('token') ?? '';
    if (token.isEmpty) {
      debugPrint("Token empty, redirecting to login");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => LogIn());
        showErrorSnackbar("Session expired. Please log in again.");
      });
      return [];
    }

    try {
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/gettasks';

      debugPrint("Fetching tasks");
      debugPrint("API URL: $APIurl");

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

      debugPrint("Tasks API response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final dynamic responseBody = jsonDecode(response.body);

          List<dynamic> tasksList;

          if (responseBody is Map<String, dynamic>) {
            tasksList = responseBody['tasks'] ?? [];
          } else if (responseBody is List) {
            tasksList = responseBody;
          } else {
            debugPrint("Unexpected response format: $responseBody");
            showErrorSnackbar("Unexpected response format from server");
            return [];
          }

          debugPrint("Loaded ${tasksList.length} tasks");
          return tasksList.map((taskJson) => Task.fromJson(taskJson)).toList();
        } catch (e) {
          debugPrint("JSON decoding error: $e");
          debugPrint("Problematic response body: ${response.body}");
          showErrorSnackbar("Data format error. Please try again later.");
          return [];
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
        return [];
      } else {
        debugPrint("Failed to load tasks: ${response.statusCode}");
        showErrorSnackbar("Failed to load tasks: ${response.statusCode}");
        return [];
      }
    } on TimeoutException {
      debugPrint("Timeout loading tasks");
      showErrorSnackbar("Request timeout. Please try again.");
      return [];
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
      debugPrint("Error stack trace: ${StackTrace.current}");
      showErrorSnackbar("Failed to load tasks: $e");
      return [];
    }
  }

  Future<Task> addTask(
    String title,
    String text,
    double estimatedHours,
    String dueDate,
  ) async {
    final token = sharedPrefs.prefs.getString('token') ?? '';
    if (token.isEmpty) {
      debugPrint("Token empty, redirecting to login");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => LogIn());
        showErrorSnackbar("Session expired. Please log in again.");
      });
      throw Exception('Token not available');
    }

    try {
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/addtask';

      debugPrint("Adding new task");
      debugPrint("API URL: $APIurl");

      final response = await http
          .post(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'title': title,
              'description': text,
              'estimatedHours': estimatedHours,
              'dueDate': dueDate,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("Add task API response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Task.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
        throw Exception('Unauthorized: Invalid token');
      } else {
        String errorMessage = "Failed to create task";
        try {
          final errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (e) {
          debugPrint("Error parsing error response: $e");
        }
        showErrorSnackbar("$errorMessage (${response.statusCode})");
        throw Exception('$errorMessage (${response.statusCode})');
      }
    } on TimeoutException {
      debugPrint("Timeout adding task");
      showErrorSnackbar("Request timeout. Please try again.");
      throw Exception('Request timeout');
    } catch (e) {
      debugPrint("Error adding task: $e");
      showErrorSnackbar("Failed to add task: $e");
      throw Exception('Failed to add task: $e');
    }
  }

  Future<void> checkTask(int taskId) async {
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
      final APIurl = '$baseUrl/api/checktask/$taskId';

      debugPrint("Updating task status for task ID: $taskId");
      debugPrint("API URL: $APIurl");

      final response = await http
          .put(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("Check task API response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("Task $taskId status updated successfully");
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        debugPrint("Failed to update task status: ${response.statusCode}");
        debugPrint("Error response: ${response.body}");

        String errorMessage = "Failed to update task status";
        try {
          final errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (e) {
          debugPrint("Error parsing error response: $e");
        }

        showErrorSnackbar("$errorMessage (${response.statusCode})");
      }
    } on TimeoutException {
      debugPrint("Timeout updating task status");
      showErrorSnackbar("Request timeout. Please try again.");
    } catch (e) {
      debugPrint("Error updating task status: $e");
      debugPrint("Error stack trace: ${StackTrace.current}");
      showErrorSnackbar("Failed to update task status: $e");
    }
  }

  Future<void> trashTask(int taskId) async {
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
      final APIurl = '$baseUrl/api/trashtask/$taskId';

      debugPrint("Moving task to trash: $taskId");
      debugPrint("API URL: $APIurl");

      final response = await http
          .put(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("Trash task API response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("Task $taskId moved to trash successfully");
        // Optional: Show success notification
        Get.rawSnackbar(
          messageText: Text(
            "Task moved to trash",
            style: TextStyle(fontFamily: globalFontFamily),
          ),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green[800]!,
          icon: const Icon(Icons.delete_outline, color: Colors.white),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        debugPrint("Failed to trash task: ${response.statusCode}");

        String errorMessage = "Failed to move task to trash";
        try {
          final errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (e) {
          debugPrint("Error parsing error response: $e");
        }

        showErrorSnackbar("$errorMessage (${response.statusCode})");
      }
    } on TimeoutException {
      debugPrint("Timeout moving task to trash");
      showErrorSnackbar("Request timeout. Please try again.");
    } catch (e) {
      debugPrint("Error trashing task: $e");
      debugPrint("Error stack trace: ${StackTrace.current}");
      showErrorSnackbar("Failed to move task to trash: $e");
    }
  }

  Future<Task?> editTask(int taskId, String text, double estimatedHours) async {
    final token = sharedPrefs.prefs.getString('token') ?? '';
    if (token.isEmpty) {
      debugPrint("Token empty, redirecting to login");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => LogIn());
        showErrorSnackbar("Session expired. Please log in again.");
      });
      return null;
    }

    try {
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/edittask/$taskId';

      debugPrint("Editing task: $taskId");
      debugPrint("API URL: $APIurl");
      debugPrint("New text: $text, Estimated hours: $estimatedHours");

      final response = await http
          .put(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({'text': text, 'estimatedHours': estimatedHours}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("Edit task API response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final updatedTask = Task.fromJson(jsonDecode(response.body));
          debugPrint("Task $taskId updated successfully");
          return updatedTask;
        } catch (e) {
          debugPrint("Error parsing updated task: $e");
          showErrorSnackbar("Error processing updated task data");
          return null;
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
        return null;
      } else {
        debugPrint("Failed to edit task: ${response.statusCode}");

        String errorMessage = "Failed to edit task";
        try {
          final errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (e) {
          debugPrint("Error parsing error response: $e");
        }

        showErrorSnackbar("$errorMessage (${response.statusCode})");
        return null;
      }
    } on TimeoutException {
      debugPrint("Timeout editing task");
      showErrorSnackbar("Request timeout. Please try again.");
      return null;
    } catch (e) {
      debugPrint("Error editing task: $e");
      debugPrint("Error stack trace: ${StackTrace.current}");
      showErrorSnackbar("Failed to edit task: $e");
      return null;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    final token = sharedPrefs.prefs.getString('token') ?? '';
    if (token.isEmpty) {
      debugPrint("Token empty, redirecting to login");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => LogIn());
        showErrorSnackbar("Session expired. Please log in again.");
      });
      return false;
    }

    try {
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/deletetask/$taskId';

      debugPrint("Permanently deleting task: $taskId");
      debugPrint("API URL: $APIurl");

      final response = await http
          .delete(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("Delete task API response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("Task $taskId deleted permanently ${response.body}");
        return true;
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
        return false;
      } else {
        debugPrint("Failed to delete task: ${response.statusCode}");

        String errorMessage = "Failed to delete task";
        try {
          final errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (e) {
          debugPrint("Error parsing error response: $e");
        }

        showErrorSnackbar("$errorMessage (${response.statusCode})");
        return false;
      }
    } on TimeoutException {
      debugPrint("Timeout deleting task");
      showErrorSnackbar("Request timeout. Please try again.");
      return false;
    } catch (e) {
      debugPrint("Error deleting task: $e");
      debugPrint("Error stack trace: ${StackTrace.current}");
      showErrorSnackbar("Failed to delete task: $e");
      return false;
    }
  }

  Future<List<Task>> getTrashTasks() async {
    final token = sharedPrefs.prefs.getString('token') ?? '';
    if (token.isEmpty) {
      debugPrint("Token empty, redirecting to login");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => LogIn());
        showErrorSnackbar("Session expired. Please log in again.");
      });
      return [];
    }

    try {
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/gettrashedtasks';

      debugPrint("Fetching trashed tasks");
      debugPrint("API URL: $APIurl");

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

      debugPrint("Trashed tasks API response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final dynamic responseBody = jsonDecode(response.body);

          List<dynamic> tasksList;

          if (responseBody is Map<String, dynamic>) {
            tasksList = responseBody['tasks'] ?? [];
          } else if (responseBody is List) {
            tasksList = responseBody;
          } else {
            debugPrint("Unexpected response format: $responseBody");
            showErrorSnackbar("Unexpected response format from server");
            return [];
          }

          debugPrint("Loaded ${tasksList.length} trashed tasks");
          return tasksList.map((taskJson) => Task.fromJson(taskJson)).toList();
        } catch (e) {
          debugPrint("JSON decoding error: $e");
          debugPrint("Problematic response body: ${response.body}");
          showErrorSnackbar("Data format error. Please try again later.");
          return [];
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
        return [];
      } else {
        debugPrint("Failed to load trashed tasks: ${response.statusCode}");
        showErrorSnackbar(
          "Failed to load trashed tasks: ${response.statusCode}",
        );
        return [];
      }
    } on TimeoutException {
      debugPrint("Timeout loading trashed tasks");
      showErrorSnackbar("Request timeout. Please try again.");
      return [];
    } catch (e) {
      debugPrint("Error fetching trashed tasks: $e");
      debugPrint("Error stack trace: ${StackTrace.current}");
      showErrorSnackbar("Failed to load trashed tasks: $e");
      return [];
    }
  }

  Future<void> restoreTask(int taskId) async {
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
      final APIurl = '$baseUrl/api/restoretask/$taskId';

      debugPrint("Restoring task: $taskId");
      debugPrint("API URL: $APIurl");

      final response = await http
          .put(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("Restore task API response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("Task $taskId restored successfully");
        Get.rawSnackbar(
          messageText: Text(
            "Task restored successfully",
            style: TextStyle(fontFamily: globalFontFamily),
          ),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green[800]!,
          icon: const Icon(Icons.restore, color: Colors.white),
        );
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
      } else {
        debugPrint("Failed to restore task: ${response.statusCode}");

        String errorMessage = "Failed to restore task";
        try {
          final errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (e) {
          debugPrint("Error parsing error response: $e");
        }

        showErrorSnackbar("$errorMessage (${response.statusCode})");
      }
    } on TimeoutException {
      debugPrint("Timeout restoring task");
      showErrorSnackbar("Request timeout. Please try again.");
    } catch (e) {
      debugPrint("Error restoring task: $e");
      debugPrint("Error stack trace: ${StackTrace.current}");
      showErrorSnackbar("Failed to restore task: $e");
    }
  }
}
