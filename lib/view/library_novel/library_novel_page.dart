import 'dart:convert';

import 'package:audiobook/commponent/flutter_spinkit/src/circle.dart';
import 'package:audiobook/commponent/item_novel_widget.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/model/novel_detail.dart';
import 'package:audiobook/src/shared/app_route.dart';
import 'package:audiobook/src/shared/shared_preference/shared_preferences_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LibraryNovelPage extends StatefulWidget {
  const LibraryNovelPage({super.key});

  @override
  State<LibraryNovelPage> createState() => _LibraryNovelPageState();
}

class _LibraryNovelPageState extends State<LibraryNovelPage> {
  final _refreshController = RefreshController();
  List<Novel> localNovel = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkLocalNovelData().then((value) {
        localNovel.addAll(value);
      });
    });
  }

  Future<List<Novel>> checkLocalNovelData() async {
    final localData = await SharedPrefManager.getLocalNovelData();
    List<Novel> listNovelDetailLocal = [];
    if (localData != null) {
      for (final jsonString in localData) {
        try {
          final jsonData = jsonDecode(jsonString);
          final novelDetailContentData = NovelDetail.fromJson(jsonData);
          final novelData = Novel(
            title: novelDetailContentData.title,
            image: novelDetailContentData.image,
            description: novelDetailContentData.description,
            author: novelDetailContentData.author,
            chapters: novelDetailContentData.chapters,
            genre: novelDetailContentData.genres?[0],
            href: novelDetailContentData.href
          );
          setState(() {
            listNovelDetailLocal.add(novelData);
          });
        } catch (e) {
          if (kDebugMode) {
            print('Error decoding JSON: $e');
          }
        }
      }
    }
    return listNovelDetailLocal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scrollbar(
      child: SmartRefresher(
        controller: _refreshController,
        header: CustomHeader(
          builder: (context, mode) {
            return const SizedBox(
              height: 60,
              child:
                  Center(child: SpinKitCircle(color: Colors.black45, size: 30)),
            );
          },
        ),
        child: _buildContent(),
        onRefresh: () async {
          await checkLocalNovelData().then((value) {
            setState(() {
              localNovel.clear();
              localNovel.addAll(value);
            });
          });
        },
      ),
    ));
  }

  CustomScrollView _buildContent() {
    _refreshController.refreshCompleted();
    return CustomScrollView(
      slivers: [
        SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoute.novelinfo.name,
                        arguments: [localNovel[index]]);
                  },
                  child: ItemNovelWidget(
                      novelTrendList: localNovel, index: index));
            },
            childCount: localNovel.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1 / 1.8,
          ),
        ),
      ],
    );
  }
}
