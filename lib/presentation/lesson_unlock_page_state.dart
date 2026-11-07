import 'dart:async';

import 'package:flutter/material.dart';

import '../application/lesson_unlock_failure.dart';
import '../application/lesson_unlock_failure_kind.dart';
import 'learning_practice_page.dart';
import 'lesson_unlock_page.dart';

class LessonUnlockPageState extends State<LessonUnlockPage> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isUnlocking = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_isUnlocking) {
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'لطفاً رمز عبور را وارد کنید.';
      });
      return;
    }

    setState(() {
      _isUnlocking = true;
      _errorMessage = null;
    });

    try {
      final lesson = await widget.unlockLesson(
        widget.lesson,
        _passwordController.text,
      );
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => LearningPracticePage(
            loadLesson: widget.loadLesson,
            lesson: widget.lesson,
            initialLesson: lesson,
          ),
        ),
      );
    } on LessonUnlockFailure catch (error) {
      if (mounted) {
        setState(() {
          _isUnlocking = false;
          _errorMessage = switch (error.kind) {
            LessonUnlockFailureKind.incorrectPassword =>
              'رمز عبور نادرست است. لطفاً دوباره تلاش کنید.',
            LessonUnlockFailureKind.missingAsset =>
              'این درس در حال حاضر در دسترس نیست.',
            LessonUnlockFailureKind.invalidContent =>
              'محتوای این درس قابل بارگذاری نیست.',
            LessonUnlockFailureKind.unknown =>
              'باز کردن درس ممکن نیست. لطفاً دوباره تلاش کنید.',
          };
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _isUnlocking = false;
          _errorMessage = 'باز کردن درس ممکن نیست. لطفاً دوباره تلاش کنید.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('باز کردن درس')),
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
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: _buildForm(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.lesson.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'برای ادامه این درس، رمز عبور را وارد کنید.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            enabled: !_isUnlocking,
            autofocus: true,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: 'رمز عبور',
              errorText: _errorMessage,
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? 'نمایش رمز عبور'
                    : 'پنهان کردن رمز عبور',
                onPressed: _isUnlocking
                    ? null
                    : () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
            onSubmitted: (_) => unawaited(_unlock()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isUnlocking ? null : () => unawaited(_unlock()),
              child: _isUnlocking
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('باز کردن درس'),
            ),
          ),
        ],
      ),
    );
  }
}
