import 'package:flutter/foundation.dart';

import '../application/load_lesson_catalog.dart';
import '../domain/lesson_catalog.dart';
import 'lesson_menu_status.dart';

class LessonMenuController extends ChangeNotifier {
  LessonMenuController({required LoadLessonCatalog loadCatalog})
    : _loadCatalog = loadCatalog;

  final LoadLessonCatalog _loadCatalog;
  LessonCatalog? _catalog;
  LessonMenuStatus _status = LessonMenuStatus.initial;
  String? _errorMessage;

  LessonMenuStatus get status => _status;

  LessonCatalog? get catalog => _catalog;

  String? get errorMessage => _errorMessage;

  Future<void> loadCatalog() async {
    _status = LessonMenuStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _catalog = await _loadCatalog();
      _status = LessonMenuStatus.ready;
    } on Object {
      _status = LessonMenuStatus.error;
      _errorMessage =
          'بارگذاری فهرست درس‌ها ممکن نیست. لطفاً دوباره تلاش کنید.';
    }

    notifyListeners();
  }
}
