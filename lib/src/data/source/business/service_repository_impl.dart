import 'package:audiobook/model/chapter_content.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/model/novel_detail.dart';
import 'package:audiobook/src/data/source/business/service_repository.dart';

class ServiceStorageRepository implements ServiceRepository {
  const ServiceStorageRepository({required this.api});
  final ServiceRepository api;

  @override
  Future<ChapterContent> getChapterContent({required String href}) {
    return api
        .getChapterContent(href: href)
        .catchError((object) => throw object.toString());
  }

  @override
  Future<List<Novel>> getListNovel() {
    return api.getListNovel().catchError((object) => throw object.toString());
  }

  @override
  Future<NovelDetail> getNovelInfo({required String href}) {
    return api.getNovelInfo(href: href).catchError((object) => throw object.toString());
  }
}
