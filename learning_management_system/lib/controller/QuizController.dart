// ignore_for_file: file_names,non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/function/SnackBarFun.dart';
import '../../view/LogIn.dart';
import '../../view/NavBar.dart';
import '../../view/OnBoarding.dart';
import '../core/classes/Quiz.dart';
import '../core/classes/QuizScreen.dart';

class QuizController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> shakeAnimation;

  final QuizService _quizService = QuizService();
  var questions = <Question>[].obs;
  var userAnswers = <int?>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  var currentQuestionIndex = 0.obs;
  var selectedAnswerIndex = Rxn<int>();
  var score = 0.obs;
  var quizCompleted = false.obs;
  var quizResultsList = {}.obs;

  String? quiz_id;
  String? lessonID;
  @override
  void onInit() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 500),
    );

    shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(animationController);
    userAnswers.clear();
    super.onInit();
  }

  Future<void> loadQuiz(String lessonId) async {
    try {
      isLoading(true);
      error.value = '';
      questions.clear();
      quiz_id = '';

      final quizResponse = await _quizService.fetchQuiz(lessonId);

      if (quizResponse.success && quizResponse.quiz != null) {
        final quiz = quizResponse.quiz!;

        if (quiz.questions.isNotEmpty) {
          questions.assignAll(quiz.questions);
          quiz_id = quiz.id.toString();
          userAnswers.value = List.filled(quiz.questions.length, null);
          debugPrint(
            "Loaded quiz ${quiz.id} with ${quiz.questions.length} questions",
          );
        } else {
          error.value = 'The quiz doesn\'t contain any questions'.tr;
          Get.snackbar(
            'Warning'.tr,
            error.value,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
          );
        }
      } else {
        error.value =
            quizResponse.quiz == null
                ? 'There is no quiz for this lesson'.tr
                : 'Failed to load the quiz'.tr;

        Get.snackbar(
          'Error'.tr,
          error.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      error.value = 'Technical error: ${e.toString().split(':').first}';
      debugPrint("Error loading quiz: $e");
      Get.snackbar(
        'Critical error'.tr,
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[800]!,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading(false);

      if (questions.isNotEmpty && !Get.isRegistered<QuizScreen>()) {
        Get.to(() => QuizScreen(lessonId: ''));
      }
    }
  }

  Future<void> SendScore(String lessonId, List<int> answers) async {
    int? quizId = int.tryParse(lessonId);
    if (quizId == null) {
      debugPrint("Invalid quizId: $lessonId");
      return;
    }
    isLoading(true);
    await _quizService.sendScore(quizId, answers);
    quizResultsList.value = Map<String, dynamic>.from(
      _quizService.quizResult.value,
    );
    debugPrint("Quiz results: $quizResultsList");
    isLoading(false);
  }

  void selectAnswer(int index) {
    // selectedAnswerIndex.value = index;

    // final currentQuestion = questions[currentQuestionIndex.value];
    // if (index == currentQuestion.correctAnswerIndex) {
    //   //  score.value += currentQuestion.points;
    //   score.value += 1;

    //   _showCorrectAnswerAnimation();
    // } else {
    //   _showWrongAnswerAnimation();
    // }
    final currentIndex = currentQuestionIndex.value;
    final question = questions[currentIndex];

    selectedAnswerIndex.value = index;

    if (index == question.correctAnswerIndex) {
      score.value += 1;
      userAnswers[currentIndex] = 1;
      _showCorrectAnswerAnimation();
    } else {
      userAnswers[currentIndex] = 0;
      _showWrongAnswerAnimation();
    }
  }

  void _showCorrectAnswerAnimation() {
    Get.snackbar(
      'Correct!'.tr,
      'Good'.tr,
      animationDuration: const Duration(milliseconds: 450),
      //  '+${questions[currentQuestionIndex.value].points} points',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    // nextQuestion();
  }

  void _showWrongAnswerAnimation() {
    animationController.reset();
    animationController.forward().then((_) {
      animationController.reverse();
    });
    Get.snackbar(
      'Wrong!'.tr,
      'Try again'.tr,
      animationDuration: const Duration(milliseconds: 600),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      selectedAnswerIndex.value = null;
    } else {
      quizCompleted.value = true;
      submitResults();
    }
  }

  void prevQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void completeQuiz() async {
    quizCompleted.value = true;
    await submitResults();
  }

  Future<void> submitResults() async {
    if (quiz_id == null) return;

    int? quizId = int.tryParse(quiz_id!);
    if (quizId == null) {
      debugPrint("Invalid quizId: $quiz_id");
      return;
    }

    try {
      await _quizService.sendScore(
        quizId,
        userAnswers.map((a) => a ?? 0).toList(),
      );
      quizResultsList.value = Map<String, dynamic>.from(
        _quizService.quizResult.value,
      );
      debugPrint("Quiz results: $quizResultsList");
    } catch (e) {
      debugPrint("Error submitting results: $e");
    }
  }

  void resetQuiz() {
    currentQuestionIndex.value = 0;
    selectedAnswerIndex.value = null;
    score.value = 0;
    quizCompleted.value = false;
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

class QuizService {
  var quizResult = {}.obs;

  Future<QuizResponse> fetchQuiz(String lessonId) async {
    final token = sharedPrefs.prefs.getString('token') ?? '';
    if (token.isEmpty) {
      debugPrint("Token empty, redirecting to login");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => LogIn());
        showErrorSnackbar("Session expired. Please log in again.");
      });
      return QuizResponse(success: false); // Return empty response
    }

    try {
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/getlecturequiz/$lessonId';

      debugPrint("Fetching quiz for lesson: $lessonId");
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

      debugPrint("Quiz API response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          return QuizResponse.fromJson(jsonResponse);
        } catch (e) {
          debugPrint("Error parsing quiz response: $e");
          debugPrint("Problematic response body: ${response.body}");
          showErrorSnackbar("Error loading quiz data");
          return QuizResponse(success: false); // Return empty response
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
        return QuizResponse(success: false); // Return empty response
      } else {
        debugPrint("Failed to load quiz: ${response.statusCode}");
        showErrorSnackbar("Failed to load quiz: ${response.statusCode}");
        return QuizResponse(success: false); // Return empty response
      }
    } on TimeoutException {
      debugPrint("Timeout loading quiz");
      showErrorSnackbar("Request timeout. Please try again.");
      return QuizResponse(success: false); // Return empty response
    } catch (e) {
      debugPrint("Error fetching quiz: $e");
      debugPrint("Error stack trace: ${StackTrace.current}");
      showErrorSnackbar("Failed to load quiz: $e");
      return QuizResponse(success: false); // Return empty response
    }
  }

  Future<bool> submitQuizResults({
    required String quizId,
    required int score,
    required int totalPoints,
  }) async {
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
      final APIurl = '$baseUrl/api/submitquiz';

      debugPrint("Submitting quiz results for quiz: $quizId");
      debugPrint("API URL: $APIurl");
      debugPrint("Score: $score/$totalPoints");

      final response = await http
          .post(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'quizId': quizId,
              'score': score,
              'totalPoints': totalPoints,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("Submit quiz API response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
      if (response.statusCode == 200) {
        debugPrint("Quiz results submitted successfully");
        return true;
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
        return false;
      } else {
        debugPrint("Failed to submit quiz results: ${response.statusCode}");

        String errorMessage = "Failed to submit quiz results";
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
      debugPrint("Timeout submitting quiz results");
      showErrorSnackbar("Request timeout. Please try again.");
      return false;
    } catch (e) {
      debugPrint("Error submitting quiz results: $e");
      debugPrint("Error stack trace: ${StackTrace.current}");
      showErrorSnackbar("Failed to submit quiz results: $e");
      return false;
    }
  }

  Future<bool> sendScore(int quizId, List<int> answers) async {
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
      final APIurl = '$baseUrl/api/finishquiz/$quizId';

      debugPrint("Sending answers for quiz: $quizId");
      debugPrint("API URL: $APIurl");
      debugPrint("Answers: $answers");

      final response = await http
          .post(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({'correctAnswers': answers}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("Send answers API response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("Answers submitted successfully");
        final responseBody = jsonDecode(response.body);
        final quizResultList = Map<String, dynamic>.from(responseBody);

        quizResult.value = quizResultList;

        return true;
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.");
        });
        return false;
      } else {
        debugPrint("Failed to send answers: ${response.statusCode}");

        String errorMessage = "Failed to send quiz answers";
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
      debugPrint("Timeout sending answers");
      showErrorSnackbar("Request timeout. Please try again.");
      return false;
    } catch (e) {
      debugPrint("Error sending answers: $e");
      debugPrint("Error stack trace: ${StackTrace.current}");
      showErrorSnackbar("Failed to send quiz answers: $e");
      return false;
    }
  }
}
