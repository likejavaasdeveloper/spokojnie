import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/lesson_access.dart';

import 'lesson_error_view.dart';
import 'lesson_loading_view.dart';
import 'lesson_menu_controller.dart';
import 'lesson_menu_page.dart';
import 'lesson_menu_status.dart';
import 'learning_practice_page.dart';
import 'lesson_unlock_page.dart';

class LessonMenuPageState extends State<LessonMenuPage> {
  late final LessonMenuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LessonMenuController(loadCatalog: widget.loadCatalog)
      ..addListener(_handleControllerChanged);
    unawaited(_controller.loadCatalog());
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('انتخاب درس')),
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
      case LessonMenuStatus.initial:
      case LessonMenuStatus.loading:
        return const Center(child: LessonLoadingView());
      case LessonMenuStatus.error:
        return Center(
          child: LessonErrorView(
            message: _controller.errorMessage ?? 'خطایی رخ داد.',
            onRetry: () => unawaited(_controller.loadCatalog()),
          ),
        );
      case LessonMenuStatus.ready:
        return _buildLessonList();
    }
  }

  Widget _buildLessonList() {
    final lessons = _controller.catalog!.lessons;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'یک درس را انتخاب کنید',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          for (final lesson in lessons)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: Text(lesson.title),
                subtitle: lesson.description == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(lesson.description!),
                      ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (lesson.access == LessonAccess.protected)
                      const Icon(Icons.lock_outline),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_back_ios_new),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => lesson.access == LessonAccess.free
                          ? LearningPracticePage(
                              loadLesson: widget.loadLesson,
                              lesson: lesson,
                            )
                          : LessonUnlockPage(
                              lesson: lesson,
                              unlockLesson: widget.unlockLesson,
                              loadLesson: widget.loadLesson,
                            ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
