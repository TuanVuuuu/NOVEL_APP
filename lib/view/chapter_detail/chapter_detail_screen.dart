import 'package:audiobook/commponent/appbar/app_bar_overflow.dart';
import 'package:audiobook/commponent/loading_shimmer/pharagraph_loading_shimmer.dart';
import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/chapter_content.dart';
import 'package:audiobook/model/hive/chapter_item.dart';
import 'package:audiobook/src/data/service/local/hive_service.dart';
import 'package:audiobook/src/shared/hive/setup_locator.dart';
import 'package:audiobook/utils/text_extensions.dart';
import 'package:audiobook/utils/view_extensions.dart';
import 'package:audiobook/view/chapter_detail/cubit/chapter_detail_cubit.dart';
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
  final HiveService _hiveService = locator<HiveService>();

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

  Future<bool> checkLocalChapterData({String? href}) async {
    final listChaptersLocal = await _hiveService.getAllChapters();
    bool foundMatchingChapter = false;
    final String? checkHref = href ??
        widget.listChapterArg[chapterIndexCurrent ?? widget.chapterIndex]
            .chapterLink
            ?.split('/v1/')[1];

    for (var chapterLocal in listChaptersLocal) {
      if (chapterLocal.href == checkHref) {
        setState(() {
          loadState = LoadState.loadSuccess;
          chapterContent = ChapterContent(
              title: chapterLocal.chapterTitle,
              text: chapterLocal.chapterText,
              href: chapterLocal.href);
        });
        foundMatchingChapter = true;
      }
    }

    return foundMatchingChapter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Scrollbar(
          child: CustomScrollView(
            slivers: [
              CustomSliverAppBar(
                chapterIndexCurrent: chapterIndexCurrent ?? 0,
                listChapter: widget.listChapterArg,
                chapterContent: mergeChapterText(chapterContent.text ?? []),
                onPreviousChapterPressed: (value) async {
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
                onNextChapterPressed: (value) async {
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
              ),
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
          });

          final ChapterItem chapterItem = ChapterItem(
              chapterTitle: chapterContent.title,
              href: chapterContent.href,
              chapterText: chapterContent.text);

          await _hiveService.addChapter(chapterItem);
          return;
        }
      },
      child: Container(),
    );
  }
}
