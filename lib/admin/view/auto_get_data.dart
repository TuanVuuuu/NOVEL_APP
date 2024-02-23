import 'dart:async';

import 'package:audiobook/admin/cubit/auto_get_data_cubit.dart';
import 'package:audiobook/model/api_log.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/utils/view_extensions.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AutoGetDataCubit>().getListNovel();
    });
  }

  @override
  Widget build(BuildContext context) {
    novelTrendList.map((e) {
      print(e.title);
    },).toList();
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
        if (state is GetListNovelInProgress) {
          setState(() {
            loadState = LoadState.loading;
          });
          return;
        }

        if (state is GetListNovelFailure) {
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

        if (state is GetListNovelSuccess) {
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
          });

          loadApiStateLog.reversed;

          // Kiểm tra nếu số lượng phần tử vượt quá 50, xoá phần tử cũ nhất
          if (loadApiStateLog.length > 50) {
            loadApiStateLog.removeAt(loadApiStateLog.length -1); // Xoá phần tử cũ nhất
          }

          Get.find<AutoGetDataCubit>().getListNovel();

        }
      },
      child: Container(),
    );
  }
}
