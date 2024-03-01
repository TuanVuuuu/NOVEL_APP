import 'dart:convert';
import 'dart:math';
import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/chapter_content.dart';
import 'package:audiobook/src/shared/app_route.dart';
import 'package:audiobook/src/shared/shared_preference/shared_preferences_manager.dart';
import 'package:audiobook/utils/size_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../main.dart';

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
    with SingleTickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late Size size;
  late TabController _tabController;

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
    setState(() {
      
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
              return const CircularProgressIndicator();
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
        Get.toNamed(
          AppRoute.chapterdetail.name,
          arguments: [chapter, widget.chapterList, chapter.index],
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
    final localData = await SharedPrefManager.getLocalChapterData();
    if (localData != null) {
      for (final jsonString in localData) {
        try {
          final jsonData = jsonDecode(jsonString);
          final chapterContentData = ChapterContent.fromJson(jsonData);
          if (chapterContentData.href ==
              widget.chapterList?[chapterIndex].chapterLink?.split('/v1/')[1]) {
            return true;
          }
        } catch (e) {
          printInfo(info: 'Error decoding JSON: $e');
        }
      }
    }
    return false;
  }
}
