import 'package:audiobook/model/chapter.dart';
import 'package:flutter/material.dart';

class CustomSliverAppBar extends StatelessWidget {
  final List<Chapter> listChapter;
  final int? chapterIndexCurrent;
  final String? chapterContent;
  final void Function(int)? onPreviousChapterPressed;
  final void Function(int)? onNextChapterPressed;

  const CustomSliverAppBar({
    super.key,
    required this.listChapter,
    required this.chapterIndexCurrent,
    this.chapterContent,
    this.onPreviousChapterPressed,
    this.onNextChapterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.blue,
      title: DefaultTextStyle(
        style: const TextStyle(color: Colors.grey, fontSize: 19),
        child: Text(
          listChapter[chapterIndexCurrent ?? 0].chapterTitle?.replaceAll(
                  listChapter[chapterIndexCurrent ?? 0].chapterTime ?? '',
                  '') ??
              '',
          style: const TextStyle(color: Colors.grey, fontSize: 19),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      snap: true,
      forceElevated: true,
      floating: true,
      actions: <Widget>[
        IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
            }),
      ],
      expandedHeight: 80,
      flexibleSpace: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight + 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildChapterButton(
              'Chương trước',
              chapterIndexCurrent != null ? chapterIndexCurrent! > 0 : false,
              onPreviousChapterPressed,
            ),
            _buildChapterButton(
              'Chương sau',
              chapterIndexCurrent != null
                  ? chapterIndexCurrent! < listChapter.length - 1
                  : false,
              onNextChapterPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterButton(
    String text,
    bool isEnabled,
    void Function(int)? onPressed,
  ) {
    return GestureDetector(
      onTap: isEnabled ? () => onPressed?.call(chapterIndexCurrent ?? 0) : null,
      child: Align(
        alignment: isEnabled ? Alignment.bottomLeft : Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isEnabled ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
