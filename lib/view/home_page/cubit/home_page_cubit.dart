import 'package:audiobook/model/novel.dart';
import 'package:audiobook/src/data/source/business/service_repository.dart';
import 'package:bloc/bloc.dart';

part 'home_page_state.dart';

class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit(this.repo) : super(GetListNovelInProgress());
  final ServiceRepository repo;

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
