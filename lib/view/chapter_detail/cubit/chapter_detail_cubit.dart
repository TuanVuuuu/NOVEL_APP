import 'package:audiobook/model/chapter_content.dart';
import 'package:audiobook/src/data/source/business/service_repository.dart';
import 'package:bloc/bloc.dart';

part 'chapter_detail_state.dart';

class ChapterDetailCubit extends Cubit<ChapterDetailState> {
  ChapterDetailCubit(this.repo) : super(GetChapterContentInProgress());
  final ServiceRepository repo;

  Future getChapterContent({required String href}) async {
    try {
      emit(GetChapterContentInProgress());
      var response = await repo.getChapterContent(href: href);
      emit(GetChapterContentSuccess(response: response));
    } catch (exception) {
      emit(GetChapterContentFailure(error: exception));
    }
  }
  
}
