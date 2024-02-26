part of 'auto_get_data_cubit.dart';

abstract class AutoGetDataState {
  AutoGetDataState();
}

class GetLocalListNovelInProgress extends AutoGetDataState {}

class GetLocalListNovelSuccess extends AutoGetDataState {
  GetLocalListNovelSuccess({required this.response});
  final List<Novel> response;
}

class GetLocalListNovelFailure extends AutoGetDataState {
  GetLocalListNovelFailure({this.error});
  final dynamic error;
}

class GetLocalNovelInfoInProgress extends AutoGetDataState {}

class GetLocalNovelInfoSuccess extends AutoGetDataState {
  GetLocalNovelInfoSuccess({required this.response});
  final NovelDetail response;
}

class GetLocalNovelInfoFailure extends AutoGetDataState {
  GetLocalNovelInfoFailure({this.error});
  final dynamic error;
}

class GetLocalChapterContentInProgress extends AutoGetDataState {}

class GetLocalChapterContentSuccess extends AutoGetDataState {
  GetLocalChapterContentSuccess({required this.response});
  final ChapterContent response;
}

class GetLocalChapterContentFailure extends AutoGetDataState {
  GetLocalChapterContentFailure({this.error});
  final dynamic error;
}
