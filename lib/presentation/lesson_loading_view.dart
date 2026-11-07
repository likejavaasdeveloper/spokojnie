import 'package:flutter/material.dart';

class LessonLoadingView extends StatelessWidget {
  const LessonLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('در حال آماده‌سازی درس...'),
        ],
      ),
    );
  }
}
