part of 'search_page_cubit.dart';

abstract class SearchPageState {
  SearchPageState();
}

class SearchNovelInProgress extends SearchPageState {}

class SearchNovelSuccess extends SearchPageState {
  SearchNovelSuccess({required this.response});
  final List<Novel> response;
}

class SearchNovelFailure extends SearchPageState {
  SearchNovelFailure({this.error});
  final dynamic error;
}
