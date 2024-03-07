import 'package:audiobook/admin/cubit/auto_get_data_cubit.dart';
import 'package:audiobook/model/api_log.dart';
import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/utils/view_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AutoGetData extends StatefulWidget {
  const AutoGetData({super.key});

  @override
  State<AutoGetData> createState() => _AutoGetDataState();
}

class _AutoGetDataState extends State<AutoGetData> {
  LoadState loadState = LoadState.none;
  late List<Novel> novelTrendList = [];
  List<APILog> loadApiStateLog = [];
  int indexNovelList = 0;
  int indexChapterList = 0;
  // APIState apiState = APIState.none;
  List<Chapter> chapterList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get.find<AutoGetDataCubit>().getListNovel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scrollbar(
      child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: loadApiStateLog.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('API: ${loadApiStateLog[index].title}'),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('STATUS: ${loadApiStateLog[index].errorCode}'),
                        Text('${loadApiStateLog[index].updateAt}'),
                      ],
                    ),
                    leading: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: loadApiStateLog[index].errorCode == 200
                              ? Colors.green
                              : Colors.red),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _buildListener(),
            )
          ]),
    ));
  }

  Widget _buildListener() {
    return BlocListener(
      bloc: Get.find<AutoGetDataCubit>(),
      listener: (context, state) {
        // Định dạng thời gian hiện tại thành chuỗi chỉ có giờ và phút
        final formattedTime = DateFormat.Hm().format(DateTime.now());
        if (state is GetLocalListNovelInProgress) {
          setState(() {
            loadState = LoadState.loading;
          });
          return;
        }

        if (state is GetLocalNovelInfoInProgress) {
          setState(() {
            loadState = LoadState.loading;
          });
          return;
        }

        if (state is GetLocalChapterContentInProgress) {
          setState(() {
            loadState = LoadState.loading;
          });
          return;
        }

        if (state is GetLocalListNovelFailure) {
          setState(() {
            loadState = LoadState.loadFailure;
            loadApiStateLog.add(APILog(
              title: 'Get List Novel Recommend',
              description: 'GetListNovelFailure',
              message: 'Failure',
              errorCode: 400,
              updateAt: formattedTime.toString(),
            ));
          });
          return;
        }

        if (state is GetLocalListNovelSuccess) {
          setState(() {
            loadState = LoadState.loadSuccess;
            novelTrendList = state.response;
            loadApiStateLog.add(APILog(
              title: 'Get List Novel Recommend',
              description: 'GetListNovelSuccess',
              message: 'Get ${state.response.length} novel',
              errorCode: 200,
              updateAt: formattedTime.toString(),
            ));
            indexNovelList = novelTrendList.length - 1;
          });

          loadApiStateLog.reversed;

          // Kiểm tra nếu số lượng phần tử vượt quá 50, xoá phần tử cũ nhất
          if (loadApiStateLog.length > 50) {
            loadApiStateLog
                .removeAt(loadApiStateLog.length - 1); // Xoá phần tử cũ nhất
          }

          if (kDebugMode) {
            print("indexNovelList: $indexNovelList");
          }
          if (indexNovelList == 19) {
            Get.find<AutoGetDataCubit>()
                .getNovelInfo(novelTrendList[indexNovelList].href ?? '');
          }
        }

        if (state is GetLocalNovelInfoSuccess) {
          setState(() {
            loadState = LoadState.loadSuccess;
            // apiState = APIState.loadingNovelInfoSuccess;
            indexNovelList--;
            indexChapterList = (state.response.chapterList?.length ?? -1) - 1;
            chapterList.clear();
            chapterList.addAll(state.response.chapterList ?? []);
            loadApiStateLog.add(APILog(
              title: 'Get List Novel Recommend',
              description: 'GetListNovelSuccess',
              message: 'Get ${state.response.title} novel',
              errorCode: 200,
              updateAt: formattedTime.toString(),
            ));
          });

          if (kDebugMode) {
            print("indexChapterList: $indexChapterList");
          }

          Get.find<AutoGetDataCubit>().getChapterContent(
              href: state.response.chapterList?[indexChapterList].chapterLink
                      ?.split('/v1/')[1] ??
                  '');

          if (indexNovelList < 0) {
            Get.find<AutoGetDataCubit>().getListNovel();
          }
        }

        if (state is GetLocalNovelInfoFailure) {
          setState(() {
            loadState = LoadState.loadFailure;
            loadApiStateLog.add(APILog(
              title: 'Get Novel',
              description: 'GetNovelInfoFailure',
              message: 'Failure',
              errorCode: 400,
              updateAt: formattedTime.toString(),
            ));
          });
          return;
        }

        if (state is GetLocalChapterContentSuccess) {
          setState(() {
            indexChapterList--;
          });

          if (kDebugMode) {
            print("indexChapterList: $indexChapterList");
          }

          if (indexNovelList >= 0 && indexChapterList < 0) {
            Get.find<AutoGetDataCubit>()
                .getNovelInfo(novelTrendList[indexNovelList].href ?? '');
          } else {
            Get.find<AutoGetDataCubit>().getChapterContent(
                href: chapterList[indexChapterList]
                        .chapterLink
                        ?.split('/v1/')[1] ??
                    '');
          }
        }
        if (state is GetLocalChapterContentFailure) {
          setState(() {
            indexChapterList = 0;
          });

          if (indexNovelList >= 0) {
            Get.find<AutoGetDataCubit>()
                .getNovelInfo(novelTrendList[indexNovelList].href ?? '');
          }
          setState(() {
            loadState = LoadState.loadFailure;
            loadApiStateLog.add(APILog(
              title: 'Get Chapter Content',
              description: 'GetLocalChapterContentFailure',
              message: 'Failure',
              errorCode: 400,
              updateAt: formattedTime.toString(),
            ));
          });
        }
      },
      child: Container(),
    );
  }
}
