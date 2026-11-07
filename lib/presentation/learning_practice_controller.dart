import 'package:flutter/foundation.dart';

import '../application/load_lesson.dart';
import '../application/validate_answer.dart';
import '../domain/answer_validation_result.dart';
import '../domain/lesson.dart';
import '../domain/lesson_practice.dart';
import '../domain/lesson_summary.dart';
import '../domain/learning_step.dart';
import 'lesson_practice_status.dart';

class LearningPracticeController extends ChangeNotifier {
  LearningPracticeController({
    required LoadLesson loadLesson,
    required this.lesson,
    this.initialLesson,
    ValidateAnswer? validateAnswer,
  }) : _loadLesson = loadLesson,
       _validateAnswer = validateAnswer ?? const ValidateAnswer();

  final LoadLesson _loadLesson;
  final ValidateAnswer _validateAnswer;
  final LessonSummary lesson;
  final Lesson? initialLesson;
  LessonPractice? _practice;
  LessonPracticeStatus _status = LessonPracticeStatus.initial;
  String? _errorMessage;
  bool _answerRevealed = false;
  AnswerValidationResult? _validationResult;

  LessonPracticeStatus get status => _status;

  LessonPractice? get practice => _practice;

  String? get errorMessage => _errorMessage;

  bool get answerRevealed => _answerRevealed;

  AnswerValidationResult? get validationResult => _validationResult;

  Future<void> loadLesson() async {
    _status = LessonPracticeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loadedLesson = initialLesson ?? await _loadLesson(lesson);
      _practice = LessonPractice(loadedLesson);
      _answerRevealed = false;
      _validationResult = null;
      _status = LessonPracticeStatus.ready;
    } on Object {
      _status = LessonPracticeStatus.error;
      _errorMessage = 'بارگذاری درس ممکن نیست. لطفاً دوباره تلاش کنید.';
    }

    notifyListeners();
  }

  void revealAnswer() {
    if (_status != LessonPracticeStatus.ready ||
        _practice?.isComplete == true) {
      return;
    }

    _answerRevealed = true;
    notifyListeners();
  }

  void checkAnswer(String expectedAnswer, String learnerAnswer) {
    if (_status != LessonPracticeStatus.ready ||
        _practice?.isComplete == true) {
      return;
    }

    _validationResult = _validateAnswer(expectedAnswer, learnerAnswer);
    notifyListeners();
  }

  void clearValidation() {
    if (_validationResult == null) {
      return;
    }

    _validationResult = null;
    notifyListeners();
  }

  void continueToNextStep() {
    if (_status != LessonPracticeStatus.ready ||
        _practice?.isComplete == true) {
      return;
    }

    _practice!.advance();
    _answerRevealed = false;
    _validationResult = null;
    notifyListeners();
  }

  void restartLesson() {
    if (_status != LessonPracticeStatus.ready) {
      return;
    }

    _practice!.restart();
    _answerRevealed = false;
    _validationResult = null;
    notifyListeners();
  }

  LearningStep get step => _practice!.step;
}
