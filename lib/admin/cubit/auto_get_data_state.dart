part of 'auto_get_data_cubit.dart';

abstract class AutoGetDataState {
  AutoGetDataState();
}

class GetListNovelInProgress extends AutoGetDataState {}

class GetListNovelSuccess extends AutoGetDataState {
  GetListNovelSuccess({required this.response});
  final List<Novel> response;
}

class GetListNovelFailure extends AutoGetDataState {
  GetListNovelFailure({this.error});
  final dynamic error;
}
