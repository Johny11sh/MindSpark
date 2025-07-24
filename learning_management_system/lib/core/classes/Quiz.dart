// models/quiz_model.dart
import 'dart:convert';

import 'package:flutter/material.dart';

// class QuizResponse {
//   final bool success;
//   final List<Question> quiz;

//   QuizResponse({
//     required this.success,
//     required this.quiz,
//   });

//   factory QuizResponse.fromJson(Map<String, dynamic> json) {
//     return QuizResponse(
//       success: json['success'],
//       quiz: List<Question>.from(
//         json['quiz'].map((x) => Question.fromJson(x))),
//     );
//   }
// }
// class Question {
//   final int id;
//   final String questionText;
//   final List<String> options;
//   final int correctAnswerIndex;
//   final int quizId;
//   final int points;
  
//   // الحقول الجديدة
//   final String difficulty;
//   final String? createdAt;
//   final String? updatedAt;

//   Question({
//     required this.id,
//     required this.questionText,
//     required this.options,
//     required this.correctAnswerIndex,
//     required this.quizId,
//     required this.points,
//     this.difficulty = 'MEDIUM',
//     this.createdAt,
//     this.updatedAt,
//   });

// factory Question.fromJson(Map<String, dynamic> json) {
//   // معالجة حقل options بشكل أكثر أماناً
//   List<String> parseOptions(dynamic optionsData) {
//     try {
//       if (optionsData is List) {
//         return List<String>.from(optionsData);
//       } else if (optionsData is String) {
//         final decoded = jsonDecode(optionsData) as List<dynamic>;
//         return decoded.map((e) => e.toString()).toList();
//       }
//       return ['Option 1', 'Option 2']; 
//     } catch (e) {
//       debugPrint("Error parsing options: $e");
//       return ['Error loading options'];
//     }
//   }

//   return Question(
//     id: json['id'] as int,
//     questionText: json['questionText'] as String,
//     options: parseOptions(json['options']),
//     correctAnswerIndex: json['correctAnswerIndex'] as int,
//     quizId: json['quiz_id'] as int,
//     points: (json['points'] ?? 1) as int,
//     difficulty: json['difficulty'] as String? ?? 'MEDIUM',
//     createdAt: json['created_at'] as String?,
//     updatedAt: json['updated_at'] as String?,
//   );
// }


// }
class QuizResponse {
  final bool success;
  final Quiz? quiz;

  QuizResponse({
    required this.success,
    this.quiz,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    return QuizResponse(
      success: json['success'] as bool? ?? false,
      quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz']) : null,
    );
  }
}

class Quiz {
  final int id;
  final int lectureId;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.lectureId,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int? ?? 0,
      lectureId: json['lecture_id'] as int? ?? 0,
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class Question {
  final int id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final int quizId;
  final int points;
  final String difficulty;
  final String? createdAt;
  final String? updatedAt;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.quizId,
    this.points = 1,
    this.difficulty = 'MEDIUM',
    this.createdAt,
    this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int? ?? 0,
      questionText: json['questionText'] as String? ?? '',
      options: _parseOptions(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'] as int? ?? 0,
      quizId: json['quiz_id'] as int? ?? 0,
      points: json['points'] as int? ?? 1,
      difficulty: json['difficulty'] as String? ?? 'MEDIUM',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  static List<String> _parseOptions(dynamic optionsData) {
    try {
      if (optionsData is List) {
        return List<String>.from(optionsData);
      } else if (optionsData is String) {
        final decoded = jsonDecode(optionsData) as List<dynamic>;
        return decoded.map((e) => e.toString()).toList();
      }
      return ['True', 'False']; // Default for safety
    } catch (e) {
      debugPrint("Error parsing options: $e");
      return ['Error loading options'];
    }
  }
}
// class Question {
//   final int id;
//   final String questionText;
//   final List<String> options;
//   final int correctAnswerIndex;
//   final int quizId;
//   final int points;

//   Question({
//     required this.id,
//     required this.questionText,
//     required this.options,
//     required this.correctAnswerIndex,
//    required this.quizId,
//     this.points=1,
 
//   });

//   factory Question.fromJson(Map<String, dynamic> json) {
//     return Question(
//       id: json['id'],
//       questionText: json['questionText'],
//       options: List<String>.from(jsonDecode(json['options'])), // تحويل JSON string إلى List
//       correctAnswerIndex: json['correctAnswerIndex'],
//       quizId: json['quiz_id'] as int,
//             points: json['points'] as int? ?? 1,
   
//     );
//   }
// }









