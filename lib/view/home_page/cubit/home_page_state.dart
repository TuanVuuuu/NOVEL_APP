part of 'home_page_cubit.dart';

abstract class HomePageState {
  HomePageState();
}

class GetListNovelInProgress extends HomePageState {}

class GetListNovelSuccess extends HomePageState {
  GetListNovelSuccess({required this.response});
  final List<Novel> response;
}

class GetListNovelFailure extends HomePageState {
  GetListNovelFailure({this.error});
  final dynamic error;
}
