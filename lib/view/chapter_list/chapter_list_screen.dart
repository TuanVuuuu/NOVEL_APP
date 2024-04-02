import 'dart:math';
import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/src/data/service/local/hive_service.dart';
import 'package:audiobook/src/shared/app_route.dart';
import 'package:audiobook/src/shared/hive/setup_locator.dart';
import 'package:audiobook/utils/enum_constants.dart';
import 'package:audiobook/utils/size_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../main.dart';

class ChapterListScreen extends StatefulWidget {
  const ChapterListScreen({
    Key? key,
    this.chapterList,
    this.onTapBack,
    this.onTapHandle,
    this.handle,
    required this.novelData,
  }) : super(key: key);

  final List<Chapter>? chapterList;
  final Function()? onTapBack;
  final Function(
    Chapter chapter,
    List<Chapter>? chapterList,
    int? index,
  )? onTapHandle;
  final NovelHandle? handle;
  final Novel? novelData;

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen>
    with SingleTickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late Size size;
  late TabController _tabController;
  final HiveService _hiveService = locator<HiveService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    size = getSizeSystem();
    _tabController = TabController(
      length: (widget.chapterList!.length / 100).ceil(),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        title: const Text('Danh sách chương'),
        leading: InkWell(
          onTap: () {
            widget.onTapBack?.call();
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
          ),
        ),
        bottom: TabBar(
          tabAlignment: TabAlignment.start,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          controller: _tabController,
          isScrollable: true,
          tabs: List.generate(
            _tabController.length,
            (index) => Tab(
              text:
                  '${(index + 1) * 100 - 100 + 1} - ${widget.chapterList != null ? min(widget.chapterList!.length, (index + 1) * 100) : (index + 1) * 100}',
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: List.generate(
              _tabController.length,
              (index) {
                final start = index * 100;
                final end = (index + 1) * 100;
                final sublist = widget.chapterList!
                    .sublist(start, end.clamp(0, widget.chapterList!.length));
                return _buildChapterListView(sublist);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterListView(List<Chapter> sublist) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      children: sublist.map((chapter) {
        return FutureBuilder<bool>(
          future: checkLocalChapterData(chapter.index ?? 0),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // return a loading indicator while waiting for the future to complete
              return const SizedBox();
            } else {
              if (snapshot.hasError) {
                // return an error message if the future throws an error
                return Text('Error: ${snapshot.error}');
              } else {
                // return the chapter item based on the future result
                return _buildItemChapter(
                    chapter, snapshot.data! ? Colors.blue : Colors.black);
              }
            }
          },
        );
      }).toList(),
    );
  }

  GestureDetector _buildItemChapter(Chapter chapter, Color color) {
    return GestureDetector(
      onTap: () {
        if (widget.handle == NovelHandle.read) {
          Get.toNamed(
            AppRoute.chapterdetail.name,
            arguments: [chapter, widget.chapterList, chapter.index],
          );
        } else {
          widget.onTapHandle?.call(chapter, widget.chapterList, chapter.index);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    (chapter.chapterTitle ?? '').replaceAll(
                      chapter.chapterTime ?? '',
                      '',
                    ),
                    maxLines: 3,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                chapter.chapterTime ?? '',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> checkLocalChapterData(int chapterIndex) async {
    final listChaptersLocal = await _hiveService.getAllChapters();
    bool foundMatchingChapter = false;

    for (var chapterLocal in listChaptersLocal) {
      if (chapterLocal.href ==
          widget.chapterList?[chapterIndex].chapterLink?.split('/v1/')[1]) {
        foundMatchingChapter = true;
      }
    }

    return foundMatchingChapter;
  }
}
