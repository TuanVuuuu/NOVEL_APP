import 'package:audiobook/model/chapter_content.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/model/novel_detail.dart';
import 'package:audiobook/src/data/source/local/local_service_repository.dart';
import 'package:bloc/bloc.dart';

part 'auto_get_data_state.dart';

class AutoGetDataCubit extends Cubit<AutoGetDataState> {
  AutoGetDataCubit(this.repo) : super(GetLocalListNovelInProgress());
  final LocalServiceRepository repo;

  Future getListNovel() async {
    try {
      emit(GetLocalListNovelInProgress());
      var response = await repo.getListNovel();
      emit(GetLocalListNovelSuccess(response: response));
    } catch (exception) {
      emit(GetLocalListNovelFailure(error: exception));
    }
  }

  Future getNovelInfo(String href) async {
    try {
      emit(GetLocalNovelInfoInProgress());
      var response = await repo.getNovelInfo(href: href);
      emit(GetLocalNovelInfoSuccess(response: response));
    } catch (exception) {
      emit(GetLocalNovelInfoFailure(error: exception));
    }
  }

  Future getChapterContent({required String href}) async {
    try {
      emit(GetLocalChapterContentInProgress());
      var response = await repo.getChapterContent(href: href);
      emit(GetLocalChapterContentSuccess(response: response));
    } catch (exception) {
      emit(GetLocalChapterContentFailure(error: exception));
    }
  }
}
