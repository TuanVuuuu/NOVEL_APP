part of 'chapter_detail_cubit.dart';

abstract class ChapterDetailState {
  ChapterDetailState();
}

class GetChapterContentInProgress extends ChapterDetailState {}

class GetChapterContentSuccess extends ChapterDetailState {
  GetChapterContentSuccess({required this.response});
  final ChapterContent response;
}

class GetChapterContentFailure extends ChapterDetailState {
  GetChapterContentFailure({this.error});
  final dynamic error;
}
