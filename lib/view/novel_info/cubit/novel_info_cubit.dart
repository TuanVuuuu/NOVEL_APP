import 'package:audiobook/model/novel_detail.dart';
import 'package:audiobook/src/data/source/business/service_repository.dart';
import 'package:bloc/bloc.dart';

part 'novel_info_state.dart';

class NovelInfoCubit extends Cubit<NovelInfoState> {
  NovelInfoCubit(this.repo) : super(GetNovelInfoInProgress());
  final ServiceRepository repo;

  Future getNovelInfo({required String href}) async {
    try {
      emit(GetNovelInfoInProgress());
      var response = await repo.getNovelInfo(href: href);
      emit(GetNovelInfoSuccess(response: response));
    } catch (exception) {
      emit(GetNovelInfoFailure(error: exception));
    }
  }
}
