import 'package:audiobook/audio_books_main_grid_widget.dart';
import 'package:audiobook/audio_books_main_list_widget.dart';
import 'package:flutter/material.dart';

class BooksAudiobookWidget extends StatelessWidget {
  const BooksAudiobookWidget({
    super.key,
    required this.isGrid,
  });

  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    return switch (isGrid) {
      true => const AudioBooksMainGridWidget(),
      false => const AudioBooksMainListWidget(),
    };
  }
}