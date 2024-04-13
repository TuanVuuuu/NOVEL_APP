import 'dart:io';
import 'package:audiobook/utils/enum_constants.dart';
import 'package:audiobook/view/audio_player/audiobook_player_page.dart';
import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/utils/size_extensions.dart';
import 'package:audiobook/view/home_page/home_page.dart';
import 'package:audiobook/view/library_novel/library_novel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TabBarManager extends StatefulWidget {
  const TabBarManager({super.key});

  @override
  State<TabBarManager> createState() => _TabBarManagerState();
}

class _TabBarManagerState extends State<TabBarManager> {
  int menuIndex = 0;
  int tabIndex = 0;
  PageCurrent pageCurrent = PageCurrent.dashboard;
  PageCurrent pageLibCurrent = PageCurrent.dashboard;
  AudioStyle audioStyle = AudioStyle.none;
  Novel novelCurrent = Novel();
  List<Chapter>? chapterListCurrent = [];
  int? chapterIndex = 0;
  Chapter? chapterData = Chapter();
  List<String> listIndexTitle = [
    'Khám phá',
    'Tủ sách',
  ];
  bool canPop = false;

  @override
  void initState() {
    super.initState();
  }

  PreferredSizeWidget? get _appbar {
    if ((pageCurrent) == PageCurrent.novel ||
        pageCurrent == PageCurrent.chapterlist ||
        pageCurrent == PageCurrent.chapter) {
      return null;
    }

    if ((pageLibCurrent) == PageCurrent.novel ||
        pageLibCurrent == PageCurrent.chapterlist ||
        pageLibCurrent == PageCurrent.chapter) {
      return null;
    }
    if (pageCurrent == PageCurrent.search ||
        pageLibCurrent == PageCurrent.search) {
      return AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          onPressed: () {
            setState(() {
              pageCurrent = PageCurrent.dashboard;
              pageLibCurrent = PageCurrent.libdashboard;
            });
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
          ),
        ),
        title: const Text('Tìm kiếm'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      );
    }

    if (pageCurrent == PageCurrent.dashboard ||
        pageLibCurrent == PageCurrent.libdashboard) {
      return AppBar(
        title: Text(listIndexTitle[menuIndex]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                pageCurrent = PageCurrent.search;
                pageLibCurrent = PageCurrent.search;
              });
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune),
          ),
        ],
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        return onBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appbar,
        body: IndexedStack(
          index: menuIndex,
          children: [
            HomePage(
              pageCurrent: (page) {
                setState(() {
                  pageCurrent = page;
                });
              },
              setCurrentPage: pageCurrent,
              audioState: (style, chapter, chapterList, index) {
                setState(() {
                  audioStyle = style;
                  chapterListCurrent = chapterList;
                  chapterIndex = index;
                  chapterData = chapter;
                });
              },
              onTapNovel: (novel) {
                setState(() {
                  novelCurrent = novel;
                });
              },
            ),
            LibraryNovelPage(
              pageCurrent: (page) {
                setState(() {
                  pageLibCurrent = page;
                });
              },
              setCurrentPage: pageLibCurrent,
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.transparent,
          height: kBottomNavigationBarHeight +
              (Platform.isAndroid ? 2 : 36) +
              (audioStyle != AudioStyle.none
                  ? (audioStyle == AudioStyle.player
                      ? sizeSystem(context).height
                      : 80)
                  : 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (audioStyle != AudioStyle.none) ...[
                audioStyle == AudioStyle.player
                    ? _buildPlayer(context, AudioStyle.player)
                    : _buildPlayer(context, AudioStyle.miniplayer)
              ] else ...[
                const SizedBox()
              ],
              if (audioStyle != AudioStyle.player) _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _buildPlayer(BuildContext context, AudioStyle player) {
    return SizedBox(
        height:
            player == AudioStyle.miniplayer ? 80 : sizeSystem(context).height,
        child: AudiobookPlayerPage(
          novelData: novelCurrent,
          onTapDown: (style) {
            setState(() {
              audioStyle = AudioStyle.miniplayer;
            });
          },
          listChapterArg: chapterListCurrent ?? [],
          chapterIndex: chapterIndex ?? 0,
          chapterArg: chapterData ?? Chapter(),
          onTap: (style) {
            setState(() {
              audioStyle = style;
            });
          },
          audioStyle: audioStyle,
          onDispose: () {
            setState(() {
              audioStyle = AudioStyle.none;
            });
          },
        ));
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      currentIndex: menuIndex,
      onTap: (idx) {
        setState(() {
          menuIndex = idx;
          pageCurrent = PageCurrent.dashboard;
          pageLibCurrent = PageCurrent.libdashboard;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: "Khám phá",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: "Tủ sách",
        ),
      ],
    );
  }

  void onBackPress() {
    if ((pageCurrent) == PageCurrent.novel) {
      setState(() {
        pageCurrent = PageCurrent.dashboard;
        canPop = false;
      });
    }

    if ((pageLibCurrent) == PageCurrent.novel) {
      setState(() {
        pageCurrent = PageCurrent.libdashboard;
      });
      canPop = false;
    }

    if (pageCurrent == PageCurrent.chapterlist) {
      setState(() {
        pageCurrent = PageCurrent.novel;
      });
      canPop = false;
    }

    if (pageCurrent == PageCurrent.audio || audioStyle == AudioStyle.player) {
      setState(() {
        audioStyle = AudioStyle.miniplayer;
      });
      canPop = false;
    }
  }
}
