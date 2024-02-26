import 'package:audiobook/model/chapter_content.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/model/novel_detail.dart';

abstract class LocalServiceRepository {
  Future<List<Novel>> getListNovel();

  Future<NovelDetail> getNovelInfo({required String href});

  Future<ChapterContent> getChapterContent({required String href});
}
