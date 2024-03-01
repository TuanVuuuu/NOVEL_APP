import 'dart:convert';

import 'package:audiobook/commponent/pharagraph_loading_shimmer.dart';
import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/chapter_content.dart';
import 'package:audiobook/src/shared/shared_preference/shared_preferences_manager.dart';
import 'package:audiobook/utils/view_extensions.dart';
import 'package:audiobook/view/chapter_detail/cubit/chapter_detail_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChapterScreen extends StatefulWidget {
  final Chapter chapterArg;
  final List<Chapter> listChapterArg;
  final int chapterIndex;

  const ChapterScreen(
      {Key? key,
      required this.chapterArg,
      required this.listChapterArg,
      required this.chapterIndex})
      : super(key: key);

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  LoadState loadState = LoadState.none;
  late ChapterContent chapterContent = ChapterContent();
  int? chapterIndexCurrent;
  List<String> listChapterContent = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      chapterIndexCurrent = widget.chapterIndex;
      bool hasLocalChapterData = await checkLocalChapterData();
      if (!hasLocalChapterData) {
        Get.find<ChapterDetailCubit>().getChapterContent(
            href: widget.chapterArg.chapterLink?.split('/v1/')[1] ?? '');
      }
    });
  }

  Future<bool> checkLocalChapterData() async {
    final localData = await SharedPrefManager.getLocalChapterData();
    if (localData != null) {
      for (final jsonString in localData) {
        try {
          final jsonData = jsonDecode(jsonString);
          final chapterContentData = ChapterContent.fromJson(jsonData);
          if (chapterContentData.href ==
              widget.listChapterArg[chapterIndexCurrent ?? widget.chapterIndex]
                  .chapterLink
                  ?.split('/v1/')[1]) {
            setState(() {
              loadState = LoadState.loadSuccess;
              chapterContent = chapterContentData;
            });
            return true;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error decoding JSON: $e');
          }
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Scrollbar(
          child: CustomScrollView(
            slivers: [
              _buildHeader(),
              _buildTitle(),
              loadState == LoadState.loadSuccess
                  ? _buildContent()
                  : const SliverToBoxAdapter(
                      child: PharagraphLoadingShimmer(
                      itemCount: 10,
                    )),
              SliverToBoxAdapter(child: _buildListener()),
              const SliverToBoxAdapter(
                  child: SizedBox(
                height: 100,
              )),
            ],
          ),
        ));
  }

  SliverToBoxAdapter _buildTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          widget.listChapterArg[chapterIndexCurrent ?? widget.chapterIndex]
                  .chapterTitle
                  ?.replaceAll(widget.chapterArg.chapterTime ?? '', '') ??
              '',
          style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300),
        ),
      ),
    );
  }

  SliverAppBar _buildHeader() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.blue,
      snap: true,
      forceElevated: true,
      floating: true,
      actions: <Widget>[
        IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
      ],
      expandedHeight: 80,
      flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  if (chapterIndexCurrent != null && chapterIndexCurrent! > 0) {
                    setState(() {
                      if (chapterIndexCurrent != null) {
                        chapterIndexCurrent = chapterIndexCurrent! - 1;
                      }
                    });
                    bool hasLocalChapterData = await checkLocalChapterData();
                    if (!hasLocalChapterData) {
                      Get.find<ChapterDetailCubit>().getChapterContent(
                          href: widget
                                  .listChapterArg[chapterIndexCurrent ??
                                      widget.chapterIndex]
                                  .chapterLink
                                  ?.split('/v1/')[1] ??
                              '');
                    }
                  }
                },
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                        color: (chapterIndexCurrent != null &&
                                chapterIndexCurrent! > 0)
                            ? Colors.blue
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      'Chương trước',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (chapterIndexCurrent != null &&
                      chapterIndexCurrent! < widget.listChapterArg.length - 1) {
                    setState(() {
                      if (chapterIndexCurrent != null) {
                        chapterIndexCurrent = chapterIndexCurrent! + 1;
                      }
                    });
                    bool hasLocalChapterData = await checkLocalChapterData();
                    if (!hasLocalChapterData) {
                      Get.find<ChapterDetailCubit>().getChapterContent(
                          href: widget
                                  .listChapterArg[chapterIndexCurrent ??
                                      widget.chapterIndex]
                                  .chapterLink
                                  ?.split('/v1/')[1] ??
                              '');
                    }
                  }
                },
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                        color: (chapterIndexCurrent != null &&
                                chapterIndexCurrent! !=
                                    widget.listChapterArg.length - 1)
                            ? Colors.blue
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      'Chương sau',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  SliverList _buildContent() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          String paragraph =
              chapterContent.text != null ? chapterContent.text![index] : '';
          if (paragraph.isEmpty) {
            return Container();
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              paragraph,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            ),
          );
        },
        childCount: chapterContent.text?.length,
      ),
    );
  }

  Widget _buildListener() {
    return BlocListener(
      bloc: Get.find<ChapterDetailCubit>(),
      listener: (context, state) async {
        if (state is GetChapterContentInProgress) {
          setState(() {
            loadState = LoadState.loading;
          });
          return;
        }

        if (state is GetChapterContentFailure) {
          setState(() {
            loadState = LoadState.loadFailure;
          });
          return;
        }

        if (state is GetChapterContentSuccess) {
          setState(() {
            loadState = LoadState.loadSuccess;
            chapterContent = state.response;
            chapterContent.href = widget
                    .listChapterArg[chapterIndexCurrent ?? widget.chapterIndex]
                    .chapterLink
                    ?.split('/v1/')[1] ??
                '';
            final jsonChapterContent = jsonEncode(chapterContent.toJson());
            listChapterContent.add(jsonChapterContent);
          });

          List<String>? getLocalChapterData = [];
          await SharedPrefManager.getLocalChapterData()?.then((value) {
            getLocalChapterData = value;
          });

          listChapterContent.addAll(getLocalChapterData ?? []);

          await SharedPrefManager.setLocalChapterData(
              value: listChapterContent);
          return;
        }
      },
      child: Container(),
    );
  }
}
