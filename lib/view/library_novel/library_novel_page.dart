import 'dart:convert';

import 'package:audiobook/commponent/flutter_spinkit/src/circle.dart';
import 'package:audiobook/view/widget/item_novel_widget.dart';
import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/model/novel_detail.dart';
import 'package:audiobook/src/shared/shared_preference/shared_preferences_manager.dart';
import 'package:audiobook/utils/enum_constants.dart';
import 'package:audiobook/view/chapter_list/chapter_list_screen.dart';
import 'package:audiobook/view/novel_info/novel_info_screen.dart';
import 'package:audiobook/view/search_page/search_novel_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LibraryNovelPage extends StatefulWidget {
  const LibraryNovelPage({
    super.key,
    this.pageCurrent,
    this.setCurrentPage,
    this.audioState,
    this.onTapNovel,
  });

  final Function(PageCurrent page)? pageCurrent;
  final PageCurrent? setCurrentPage;
  final Function(
    AudioStyle audioStyle,
    Chapter chapter,
    List<Chapter>? chapterList,
    int? index,
  )? audioState;
  final Function(Novel novel)? onTapNovel;

  @override
  State<LibraryNovelPage> createState() => _LibraryNovelPageState();
}

class _LibraryNovelPageState extends State<LibraryNovelPage> {
  final _refreshController = RefreshController();
  List<Novel> localNovel = [];
  PageCurrent pageCurrent = PageCurrent.libdashboard;
  Novel novelCurrent = Novel();
  List<Chapter>? chapterList = [];
  NovelDetail? novelDataResponse = NovelDetail();
  AudioStyle audioStyle = AudioStyle.none;
  NovelHandle? novelHandle = NovelHandle.read;

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
              href: novelDetailContentData.href);
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildBody(),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  Widget _buildBody() {
    if (widget.setCurrentPage == PageCurrent.search) {
      return SearchNovelScreen(
        onTapNovel: (novel) {
          setState(() {
            novelCurrent = novel;
            pageCurrent = PageCurrent.novel;
            widget.pageCurrent?.call(pageCurrent);
          });
        },
      );
    }

    if (widget.setCurrentPage == PageCurrent.libdashboard) {
      return _buildDashboard(context);
    }

    if (pageCurrent == PageCurrent.dashboard) {
      return _buildDashboard(context);
    }

    if (pageCurrent == PageCurrent.novel) {
      return NovelInfoScreen(
        novelData: novelCurrent,
        onTapBack: () {
          setState(() {
            pageCurrent = PageCurrent.libdashboard;
            widget.pageCurrent?.call(pageCurrent);
          });
        },
        onTapListChapter: (value) {
          setState(() {
            pageCurrent = PageCurrent.chapterlist;
            widget.pageCurrent?.call(pageCurrent);
            chapterList = value;
          });
        },
        novelDataResponse: (novelData) {
          setState(() {
            novelDataResponse = novelData;
          });
        },
        oldNovelData: novelDataResponse,
        onHandle: (handle) {
          setState(() {
            novelHandle = handle;
          });
        },
      );
    }

    if (pageCurrent == PageCurrent.chapterlist) {
      return ChapterListScreen(
        novelData: novelCurrent,
        chapterList: chapterList,
        handle: novelHandle,
        onTapBack: () {
          setState(() {
            pageCurrent = PageCurrent.novel;
            widget.pageCurrent?.call(pageCurrent);
          });
        },
        onTapHandle: (chapter, chapterList, index) {
          setState(() {
            audioStyle = AudioStyle.player;
            widget.audioState?.call(audioStyle, chapter, chapterList, index);
          });
        },
      );
    }

    return _buildDashboard(context);
  }

  Scaffold _buildDashboard(BuildContext context) {
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
                    setState(() {
                      novelCurrent = localNovel[index];
                      pageCurrent = PageCurrent.novel;
                      widget.pageCurrent?.call(pageCurrent);
                    });
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
