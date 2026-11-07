import 'lesson.dart';
import 'learning_item.dart';
import 'learning_step.dart';

class LessonPractice {
  LessonPractice(this.lesson);

  final Lesson lesson;
  var _itemIndex = 0;
  var _step = LearningStep.understand;
  var _isComplete = false;

  LearningItem get currentItem {
    if (_isComplete) {
      throw StateError('The lesson is complete.');
    }

    return lesson.items[_itemIndex];
  }

  int get currentItemNumber => _itemIndex + 1;

  LearningStep get step => _step;

  bool get isComplete => _isComplete;

  void advance() {
    if (_isComplete) {
      return;
    }

    switch (_step) {
      case LearningStep.understand:
        _step = LearningStep.recall;
      case LearningStep.recall:
        _step = LearningStep.variation;
      case LearningStep.variation:
        if (_itemIndex == lesson.items.length - 1) {
          _isComplete = true;
        } else {
          _itemIndex++;
          _step = LearningStep.understand;
        }
    }
  }

  void restart() {
    _itemIndex = 0;
    _step = LearningStep.understand;
    _isComplete = false;
  }
}
