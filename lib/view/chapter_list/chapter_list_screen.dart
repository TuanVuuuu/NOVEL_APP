import 'dart:convert';
import 'dart:math';
import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/chapter_content.dart';
import 'package:audiobook/src/shared/app_route.dart';
import 'package:audiobook/utils/size_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ChapterListScreen extends StatefulWidget {
  final List<Chapter>? chapterList;
  final String? chapterImage;

  const ChapterListScreen({
    Key? key,
    this.chapterList,
    this.chapterImage,
  }) : super(key: key);

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen>
    with SingleTickerProviderStateMixin {
  late Size size;
  late TabController _tabController;
  late ChapterContent chapterContent = ChapterContent();

  @override
  void initState() {
    super.initState();
    size = getSizeSystem();
    _tabController = TabController(
      length: (widget.chapterList!.length / 100).ceil(),
      vsync: this,
    );
    loadNovelData();
  }

  Future<void> loadNovelData() async {
    String jsonString = await rootBundle
        .loadString('assets/novel_van_giao_to_su_chapter_1.json');
    setState(() {
      final jsonData = json.decode(jsonString);
      chapterContent = ChapterContent.fromJson(jsonData);
    });
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
        bottom: TabBar(
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
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 100),
                  itemCount: sublist.length,
                  itemBuilder: (context, idx) {
                    final chapter = sublist[idx];
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          AppRoute.chapterdetail.name,
                          arguments: [
                            chapter,
                            widget.chapterList,
                            chapter.index
                          ],
                        );
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
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
