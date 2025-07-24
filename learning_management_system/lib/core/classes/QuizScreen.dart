
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controller/QuizController.dart';
import '../classes/Quiz.dart';
import 'package:lottie/lottie.dart';

import 'Calculator.dart';

class QuizScreen extends StatefulWidget {
  final String lessonId;

  const QuizScreen({super.key, required this.lessonId});

  @override
  // ignore: library_private_types_in_public_api
  _QuizScreen createState() => _QuizScreen();
}

class _QuizScreen extends State<QuizScreen> {
  static const Color primaryDark = Color(0xFF2E3601);
  static const Color secondaryDark = Color(0xFF28293D);
  static const Color primaryPurple = Color(0xFF555184);
  static const Color lightBeige = Color(0xFFB2A6BE);
  static const Color cream = Color(0xFFFEE9CE);
  bool _isConfirm = false;
  int? _index;
  bool isselect = false;
  final QuizController _quizController = Get.put(QuizController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quizController.loadQuiz(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiz',
          style: TextStyle(color: Color.fromARGB(255, 252, 242, 228)),
        ),
        backgroundColor: const Color.fromARGB(255, 58, 60, 101),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(context: context, builder: (context) => Calculator());
            },
            icon: Icon(Icons.calculate_outlined, size: 38),
          ),
        ],
      ),
      body: Obx(() {
        if (_quizController.isLoading.value) {
          return _buildLoadingScreen();
        }

        if (_quizController.error.isNotEmpty) {
          return _buildErrorScreen();
        }

        if (_quizController.quizCompleted.value) {
          return const ResultsScreen();
        }

        return _quizController.questions.isNotEmpty
            ? _buildQuizScreen()
            : const Center(child: Text(' No Questions Available'));
      }),
    );
  }

  Widget _buildQuizScreen() {
    final question =
        _quizController.questions[_quizController.currentQuestionIndex.value];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 58, 60, 101),
            Color.fromARGB(255, 127, 124, 168),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value:
                (_quizController.currentQuestionIndex.value + 1) /
                _quizController.questions.length,
            backgroundColor: lightBeige.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(cream),
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color.fromARGB(255, 252, 242, 228),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                question.questionText,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                return _buildOptionButton(index, question);
              },
            ),
          ),

          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,

      children: [
        Text(
          '${_quizController.currentQuestionIndex.value + 1} from (${_quizController.questions.length})',
          style: const TextStyle(fontSize: 16, color: cream),
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
                foregroundColor: const Color.fromARGB(255, 35, 35, 36),
                backgroundColor: const Color.fromARGB(255, 236, 236, 252),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: primaryPurple, width: 1),
                ),
                elevation: 3,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Confirm', style: TextStyle(color: Colors.black)),
                  SizedBox(width: 10),
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
                backgroundColor: Colors.white,
                foregroundColor: primaryDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 53, 49, 100),
                    width: 1,
                  ),
                ),
                elevation: 3,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 10),
                  Text("Next", style: TextStyle(color: Colors.black)),
                  Icon(Icons.arrow_right_alt, size: 20),
                ],
              ),
            ),
          ],
        ),

        // زر التالي أو الإنهاء
        Padding(padding: EdgeInsets.only(bottom: 50)),
      ],
    );
  }

  Widget _buildOptionButton(int index, Question question) {
    return Obx(() {
      final isSelected = _quizController.selectedAnswerIndex.value == index;
      final isCorrect = index == question.correctAnswerIndex;

      BorderSide borderside = BorderSide(
        color: Colors.grey[200]!,
        width: isSelected ? 3 : 2,
      );
      if (_quizController.selectedAnswerIndex.value != null) {
        if (isSelected && !isCorrect) {
          borderside = BorderSide(
            color: Colors.red.withOpacity(0.4),
            width: isSelected ? 3 : 2,
          );
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
            BoxShadow(color: secondaryDark.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            _index = index;
            isselect = true;
            setState(() {});
          },

          style: ElevatedButton.styleFrom(
            foregroundColor: cream,
            // _getButtonColor(index, question),
            backgroundColor: secondaryDark,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: borderside,
            ),
          ),
          child: Text(
            question.options[index],
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );
    });
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Loading quiz...'),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 50, color: Colors.red),
          const SizedBox(height: 20),
          Text(_quizController.error.value),
          Text(
            _quizController.error.value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
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
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  final QuizController _quizController = Get.find();
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
    final correctAnswers = _quizController.score.value;
    final totalQuestions = _quizController.questions.length;
    final percentage = (correctAnswers / totalQuestions) * 100;
    final isPassed = percentage >= 50;

    return Scaffold(
      body: Stack(
        children: [
          // الخلفية المتدرجة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              ),
            ),
          ),

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

          // محتوى النتائج
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // الرسم المتحرك حسب النتيجة
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

                    //  const SizedBox(height: 15),
                    Text(
                      isPassed ? 'Done Successfully' : 'Better Luck',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // بطاقة النتائج
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // شريط التقدم الدائري
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
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isPassed ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // تفاصيل النتائج
                            _buildResultDetail(
                              'The correct Answers',
                              '$correctAnswers',
                              Icons.check_circle,
                              Colors.green,
                            ),
                            _buildResultDetail(
                              "The Wrong Answers",
                              '${totalQuestions - correctAnswers}',
                              Icons.cancel,
                              Colors.red,
                            ),
                            _buildResultDetail(
                              "All Questions",
                              '$totalQuestions',
                              Icons.help_outline,
                              Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // أزرار التحكم
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isPassed)
                          ElevatedButton.icon(
                            onPressed: () {
                              _quizController.resetQuiz();
                              Get.back();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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
                          icon: const Icon(Icons.close),
                          label: const Text('Back'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              73,
                              171,
                              251,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultDetail(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
