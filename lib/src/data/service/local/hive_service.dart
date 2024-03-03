import 'package:audiobook/model/hive/chapter_item.dart';
import 'package:hive/hive.dart';

class HiveService {
  final String _boxName = "chapterBox";

  Future<Box<ChapterItem>> get _box async => await Hive.openBox<ChapterItem>(_boxName);

  Future<void> addChapter(ChapterItem item) async {
    var box = await _box;
    await box.add(item);
  }

  Future<List<ChapterItem>> getAllChapters() async {
    var box = await _box;
    return box.values.toList();
  }

  Future<void> deleteTodo(int index) async {
    var box = await _box;
    await box.deleteAt(index);
  }
}