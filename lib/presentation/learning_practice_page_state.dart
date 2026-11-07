import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/learning_step.dart';
import 'lesson_completion_view.dart';
import 'lesson_error_view.dart';
import 'lesson_loading_view.dart';
import 'lesson_practice_status.dart';
import 'lesson_step_indicator.dart';
import 'learning_practice_controller.dart';
import 'recall_step_view.dart';
import 'understand_step_view.dart';
import 'variation_step_view.dart';
import 'learning_practice_page.dart';

class LearningPracticePageState extends State<LearningPracticePage> {
  late final LearningPracticeController _controller;
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = LearningPracticeController(
      loadLesson: widget.loadLesson,
      lesson: widget.lesson,
      initialLesson: widget.initialLesson,
    )..addListener(_handleControllerChanged);
    unawaited(_controller.loadLesson());
  }

  @override
  void dispose() {
    _answerController.dispose();
    _controller
      ..removeListener(_handleControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _continue() {
    _answerController.clear();
    _controller.continueToNextStep();
  }

  void _checkAnswer(String expectedAnswer) {
    _controller.checkAnswer(expectedAnswer, _answerController.text);
  }

  void _retryAnswer() {
    _answerController.clear();
    _controller.clearValidation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spokojnie')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 600 ? 24.0 : 48.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _buildContent(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_controller.status) {
      case LessonPracticeStatus.initial:
      case LessonPracticeStatus.loading:
        return const Center(child: LessonLoadingView());
      case LessonPracticeStatus.error:
        return Center(
          child: LessonErrorView(
            message: _controller.errorMessage ?? 'خطایی رخ داد.',
            onRetry: () => unawaited(_controller.loadLesson()),
          ),
        );
      case LessonPracticeStatus.ready:
        return _buildReadyContent();
    }
  }

  Widget _buildReadyContent() {
    final practice = _controller.practice!;

    if (practice.isComplete) {
      return LessonCompletionView(
        onRestart: _restartLesson,
        onReturnToMenu: () => Navigator.of(context).pop(),
      );
    }

    final lesson = practice.lesson;
    final item = practice.currentItem;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'درس ${practice.currentItemNumber} از ${lesson.items.length}',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 14),
        LessonStepIndicator(currentStep: practice.step),
        const SizedBox(height: 32),
        switch (practice.step) {
          LearningStep.understand => UnderstandStepView(
            step: item.understand,
            onContinue: _continue,
          ),
          LearningStep.recall => RecallStepView(
            step: item.recall,
            answerController: _answerController,
            answerRevealed: _controller.answerRevealed,
            validationResult: _controller.validationResult,
            onRevealAnswer: _controller.revealAnswer,
            onCheckAnswer: () => _checkAnswer(item.recall.answer),
            onRetry: _retryAnswer,
            onContinue: _continue,
          ),
          LearningStep.variation => VariationStepView(
            step: item.variation,
            answerController: _answerController,
            answerRevealed: _controller.answerRevealed,
            validationResult: _controller.validationResult,
            onRevealAnswer: _controller.revealAnswer,
            onCheckAnswer: () => _checkAnswer(item.variation.answer),
            onRetry: _retryAnswer,
            onContinue: _continue,
          ),
        },
      ],
    );
  }

  void _restartLesson() {
    _answerController.clear();
    _controller.restartLesson();
  }
}
