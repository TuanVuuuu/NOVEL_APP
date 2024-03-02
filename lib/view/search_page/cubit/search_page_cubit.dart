import 'package:audiobook/model/novel.dart';
import 'package:audiobook/src/data/source/business/service_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_page_state.dart';

class SearchPageCubit extends Cubit<SearchPageState> {
  SearchPageCubit(this.repo) : super(SearchNovelInProgress());
  final ServiceRepository repo;

  Future searchNovelByTitle({String? title}) async {
    try {
      emit(SearchNovelInProgress());
      var response = await repo.searchNovelByTitle(title: title);
      emit(SearchNovelSuccess(response: response));
    } catch (exception) {
      emit(SearchNovelFailure(error: exception));
    }
  }
}
