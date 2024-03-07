import 'dart:convert';

import 'package:audiobook/model/novel.dart';
import 'package:audiobook/model/novel_detail.dart';
import 'package:audiobook/src/data/source/business/service_repository.dart';
import 'package:audiobook/src/shared/shared_preference/shared_preferences_manager.dart';
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

  Future<void> saveNovelToLocalData({NovelDetail? novelData}) async {
    final jsonNovelContent = jsonEncode(novelData?.toJson());
    final localData = await SharedPrefManager.getLocalNovelData();
    List<String> listNovel = [];

    if (localData != null) {
      // Xóa dữ liệu cũ nếu truyện hiện tại đã có trong danh sách
      listNovel = localData.where((element) {
        final Novel novel = Novel.fromJson(jsonDecode(element));
        return novel.href != novelData?.href;
      }).toList();
    }

    // Thêm truyện hiện tại vào đầu danh sách
    listNovel.insert(0, jsonNovelContent);

    await SharedPrefManager.setLocalNovelData(value: listNovel);
  }
}
