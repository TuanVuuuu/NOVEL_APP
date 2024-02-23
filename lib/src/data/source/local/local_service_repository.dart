import 'package:audiobook/model/novel.dart';

abstract class LocalServiceRepository {
  Future<List<Novel>> getListNovel();
}
