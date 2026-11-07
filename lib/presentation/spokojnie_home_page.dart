import 'package:flutter/material.dart';

import '../application/load_lesson.dart';
import '../application/load_lesson_catalog.dart';
import '../application/unlock_lesson.dart';
import 'lesson_menu_page.dart';

class SpokojnieHomePage extends StatelessWidget {
  const SpokojnieHomePage({
    required this.loadLesson,
    required this.loadCatalog,
    required this.unlockLesson,
    super.key,
  });

  final LoadLesson loadLesson;
  final LoadLessonCatalog loadCatalog;
  final UnlockLesson unlockLesson;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 600 ? 24.0 : 48.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Spokojnie',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          style: textTheme.displaySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'یادگیری زبان لهستانی، یک جمله در هر نوبت',
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 36),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) => LessonMenuPage(
                                    loadCatalog: loadCatalog,
                                    loadLesson: loadLesson,
                                    unlockLesson: unlockLesson,
                                  ),
                                ),
                              );
                            },
                            child: const Text('شروع یادگیری'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
