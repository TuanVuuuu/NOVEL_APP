part of 'novel_info_cubit.dart';

abstract class NovelInfoState {
  NovelInfoState();
}

class GetNovelInfoInProgress extends NovelInfoState {}

class GetNovelInfoSuccess extends NovelInfoState {
  GetNovelInfoSuccess({required this.response});
  final NovelDetail response;
}

class GetNovelInfoFailure extends NovelInfoState {
  GetNovelInfoFailure({this.error});
  final dynamic error;
}
