import 'package:audiobook/model/novel.dart';
import 'package:audiobook/src/data/source/local/local_service_repository.dart';

class LocalServiceStorageRepository implements LocalServiceRepository {
  const LocalServiceStorageRepository({required this.api});
  final LocalServiceRepository api;

  @override
  Future<List<Novel>> getListNovel() {
    return api.getListNovel().catchError((object) => throw object.toString());
  }
}
