import 'package:audiobook/model/novel.dart';
import 'package:audiobook/src/data/source/local/local_service_repository.dart';
import 'package:bloc/bloc.dart';

part 'auto_get_data_state.dart';

class AutoGetDataCubit extends Cubit<AutoGetDataState> {
  AutoGetDataCubit(this.repo) : super(GetListNovelInProgress());
  final LocalServiceRepository repo;

  Future getListNovel() async {
    try {
      emit(GetListNovelInProgress());
      var response = await repo.getListNovel();
      emit(GetListNovelSuccess(response: response));
    } catch (exception) {
      emit(GetListNovelFailure(error: exception));
    }
  }
}
