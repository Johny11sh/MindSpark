// ignore_for_file: file_names,library_private_types_in_public_api
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controller/QuizController.dart';
import '../classes/Quiz.dart';
import 'package:lottie/lottie.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import 'Calculator.dart';
import '../constants/FontGlobals.dart';

class QuizScreen extends StatefulWidget {
  final String lessonId;

  const QuizScreen({super.key, required this.lessonId});

  @override
  _QuizScreen createState() => _QuizScreen();
}

class _QuizScreen extends State<QuizScreen> {
  bool _isConfirm = false;
  int? _index;
  bool isselect = false;
  final QuizController _quizController = Get.put(QuizController());
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quizController.loadQuiz(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;
    final Color primaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);
    final Color secondaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 210, 209, 224)
            : const Color.fromARGB(255, 40, 41, 61);

    return Scaffold(
      body: Container(
        color: primaryColor,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 25),
              height: 100,
              child: Center(
                child: Text(
                  'Quiz',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontFamily: globalFontFamily,
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        globalFontSizeChange <= 17
                            ? (globalFontSizeChange / 5) + 23
                            : 23 - (globalFontSizeChange / 5),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Obx(() {
                  if (_quizController.isLoading.value) {
                    return _buildLoadingScreen(primaryColor);
                  }

                  if (_quizController.error.isNotEmpty) {
                    return _buildErrorScreen(primaryColor);
                  }

                  if (_quizController.quizCompleted.value) {
                    return const ResultsScreen();
                  }

                  return _quizController.questions.isNotEmpty
                      ? _buildQuizScreen(primaryColor, secondaryColor)
                      : Center(
                        child: Text(
                          'No Questions Available',
                          style: TextStyle(
                            color: primaryColor,
                            fontFamily: globalFontFamily,
                          ),
                        ),
                      );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (context) => Calculator());
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.calculate_outlined, size: 30, color: secondaryColor),
      ),
    );
  }

  Widget _buildQuizScreen(Color primaryColor, Color secondaryColor) {
    final question =
        _quizController.questions[_quizController.currentQuestionIndex.value];

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          Text(
            question.difficulty,
            style: TextStyle(
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 20
                      : 20 - (globalFontSizeChange / 5),
              color: primaryColor,
              fontFamily: globalFontFamily,
            ),
          ),
          const SizedBox(height: 20),

          LinearProgressIndicator(
            value:
                (_quizController.currentQuestionIndex.value + 1) /
                _quizController.questions.length,
            backgroundColor: primaryColor.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                question.questionText,
                style: TextStyle(
                  fontSize:
                      globalFontSizeChange <= 17
                          ? (globalFontSizeChange / 5) + 20
                          : 20 - (globalFontSizeChange / 5),
                  color: primaryColor,
                  fontFamily: globalFontFamily,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                return _buildOptionButton(
                  index,
                  question,
                  primaryColor,
                  secondaryColor,
                );
              },
            ),
          ),

          _buildNavigationButtons(primaryColor, secondaryColor),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(Color primaryColor, Color secondaryColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '${_quizController.currentQuestionIndex.value + 1} from (${_quizController.questions.length})',
          style: TextStyle(
            fontSize:
                globalFontSizeChange <= 17
                    ? (globalFontSizeChange / 5) + 16
                    : 16 - (globalFontSizeChange / 5),
            color: primaryColor,
            fontFamily: globalFontFamily,
          ),
        ),
        const SizedBox(height: 35),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed:
                  (isselect)
                      ? () {
                        _isConfirm = true;
                        setState(() {});

                        _quizController.selectAnswer(_index!);
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: secondaryColor,
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Confirm',
                    style: TextStyle(
                      color: secondaryColor,
                      fontFamily: globalFontFamily,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),

            // next button
            ElevatedButton(
              onPressed:
                  _isConfirm
                      ? () {
                        if (_quizController.currentQuestionIndex.value ==
                            _quizController.questions.length - 1) {
                          _quizController.completeQuiz();
                          Get.to(() => const ResultsScreen());
                        } else {
                          _quizController.nextQuestion();
                          _isConfirm = false;
                          isselect = false;
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: secondaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Next",
                    style: TextStyle(
                      color: secondaryColor,
                      fontFamily: globalFontFamily,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_right_alt, size: 20, color: secondaryColor),
                ],
              ),
            ),
          ],
        ),

        const Padding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildOptionButton(
    int index,
    Question question,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Obx(() {
      final isSelected = _quizController.selectedAnswerIndex.value == index;
      final isCorrect = index == question.correctAnswerIndex;

      BorderSide borderside = BorderSide(
        color: primaryColor.withOpacity(0.3),
        width: isSelected ? 3 : 2,
      );
      if (_quizController.selectedAnswerIndex.value != null) {
        if (isSelected && !isCorrect) {
          borderside = BorderSide(color: Colors.red, width: isSelected ? 3 : 2);
        } else if (isCorrect) {
          borderside = BorderSide(
            color: Colors.green,
            width: isSelected ? 3 : 2,
          );
        } else {}
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            _index = index;
            isselect = true;
            setState(() {});
          },

          style: ElevatedButton.styleFrom(
            foregroundColor: secondaryColor,
            backgroundColor: primaryColor.withOpacity(0.8),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: borderside,
            ),
          ),
          child: Text(
            question.options[index],
            style: TextStyle(
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 18
                      : 18 - (globalFontSizeChange / 5),
              color: secondaryColor,
              fontFamily: globalFontFamily,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLoadingScreen(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 20),
          Text(
            'Loading quiz...',
            style: TextStyle(color: primaryColor, fontFamily: globalFontFamily),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 50, color: primaryColor),
          const SizedBox(height: 20),
          Text(
            _quizController.error.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 16
                      : 16 - (globalFontSizeChange / 5),
              color: primaryColor,
              fontFamily: globalFontFamily,
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed:
                () => {
                  _quizController.error.value = '',
                  _quizController.isLoading.value = true,
                  _quizController.loadQuiz(widget.lessonId),
                  HapticFeedback.lightImpact(),
                },
            icon: Icon(Icons.refresh, color: primaryColor),
            label: Text(
              'Retry',
              style: TextStyle(
                color: primaryColor,
                fontFamily: globalFontFamily,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  // ignore:
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  final QuizController _quizController = Get.find();
  final ThemeController themeController = Get.find<ThemeController>();
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;
    final Color primaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);
    final Color secondaryColor =
        isLightTheme
            ? const Color.fromARGB(255, 210, 209, 224)
            : const Color.fromARGB(255, 40, 41, 61);

    final correctAnswers = _quizController.score.value;
    final totalQuestions = _quizController.questions.length;

    final percentage = (correctAnswers / totalQuestions) * 100;
    final isPassed = percentage >= 50;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Obx(() {
        final Map<String, dynamic> results = Map<String, dynamic>.from(
          _quizController.quizResultsList.value ?? <String, dynamic>{},
        );
        final addedSparks = results['sparks_added'] ?? 0;
        final totalUserSparks = results['total_sparks'] ?? 0;
        final isSparkyAdded = results['sparky_added'] ?? false;
        final totalUserSparkies = results['total_sparkies'] ?? 0;
        return Scaffold(
          body: Container(
            color: primaryColor,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: true,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple,
                    ],
                  ),
                ),

                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 25),
                      height: 100,
                      child: Center(
                        child: Text(
                          "Quiz Results",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            fontFamily: globalFontFamily,
                            color: secondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                globalFontSizeChange <= 17
                                    ? (globalFontSizeChange / 5) + 23
                                    : 23 - (globalFontSizeChange / 5),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60),
                          ),
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Lottie.asset(
                                      isPassed
                                          ? 'assets/lottie/success.json'
                                          : 'assets/lottie/TryAgain.json',
                                      width: 180,
                                      height: 180,
                                    ),
                                  ),

                                  Text(
                                    isPassed
                                        ? 'Done Successfully'
                                        : 'Better Luck',
                                    style: TextStyle(
                                      fontSize:
                                          globalFontSizeChange <= 17
                                              ? (globalFontSizeChange / 5) + 28
                                              : 28 - (globalFontSizeChange / 5),
                                      fontFamily: globalFontFamily,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Container(
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: 180,
                                            height: 180,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  value: percentage / 100,
                                                  strokeWidth: 10,
                                                  strokeAlign: 15,
                                                  backgroundColor: primaryColor
                                                      .withOpacity(0.2),
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(
                                                        isPassed
                                                            ? Colors.green
                                                            : Colors.orange,
                                                      ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${percentage.toStringAsFixed(1)}%',
                                                      style: TextStyle(
                                                        fontSize:
                                                            globalFontSizeChange >=
                                                                    17
                                                                ? (globalFontSizeChange /
                                                                        5) +
                                                                    28
                                                                : 28 -
                                                                    (globalFontSizeChange /
                                                                        5),
                                                        fontFamily:
                                                            globalFontFamily,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 20),

                                          _buildResultDetail(
                                            'The correct Answers',
                                            '$correctAnswers',
                                            Icons.check_circle,
                                            Colors.green,
                                            primaryColor,
                                          ),
                                          _buildResultDetail(
                                            "The Wrong Answers",
                                            '${totalQuestions - correctAnswers}',
                                            Icons.cancel,
                                            Colors.red,
                                            primaryColor,
                                          ),
                                          _buildResultDetail(
                                            "All Questions",
                                            '$totalQuestions',
                                            Icons.help_outline,
                                            Colors.blue,
                                            primaryColor,
                                          ),
                                          _buildResultDetail(
                                            "Sparks earned",
                                            '$addedSparks',
                                            Icons.electric_bolt_rounded,
                                            Colors.orange,
                                            primaryColor,
                                          ),
                                          _buildResultDetail(
                                            "Your total Sparks",
                                            '$totalUserSparks',
                                            Icons.electric_bolt_rounded,
                                            Colors.orange,
                                            primaryColor,
                                          ),
                                          _buildResultDetail(
                                            "Sparkies earned",
                                            (isSparkyAdded == true) ? '1' : '0',
                                            Icons.lightbulb_circle_outlined,
                                            Colors.amber,
                                            primaryColor,
                                          ),
                                          _buildResultDetail(
                                            "Your Sparkies",
                                            '$totalUserSparkies',
                                            Icons.lightbulb,
                                            Colors.amber,
                                            primaryColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (!isPassed)
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            _quizController.resetQuiz();
                                            Get.back();
                                          },
                                          icon: Icon(
                                            Icons.refresh,
                                            color: secondaryColor,
                                          ),
                                          label: Text(
                                            'Try Again',
                                            style: TextStyle(
                                              color: secondaryColor,
                                              fontFamily: globalFontFamily,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 20),

                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Get.until((route) => route.isFirst);
                                          _quizController.nextQuestion();
                                          _quizController.resetQuiz();
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: secondaryColor,
                                        ),
                                        label: Text(
                                          'Back',
                                          style: TextStyle(
                                            color: secondaryColor,
                                            fontFamily: globalFontFamily,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResultDetail(
    String title,
    String value,
    IconData icon,
    Color color,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 16
                      : 16 - (globalFontSizeChange / 5),
              color: textColor,
              fontFamily: globalFontFamily,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 18
                      : 18 - (globalFontSizeChange / 5),
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: globalFontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
