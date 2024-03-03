import 'package:hive/hive.dart';

part 'chapter_item.g.dart';

@HiveType(typeId: 1)
class ChapterItem {
  @HiveField(0)
  final String? chapterTitle;

  @HiveField(1)
  final List<String>? chapterText;

  @HiveField(2)
  String? href;

  ChapterItem({this.chapterTitle, this.chapterText, this.href});

  factory ChapterItem.fromJson(Map<String, dynamic> json) {
    return ChapterItem(
      chapterTitle: json['chapterTitle'],
      chapterText: List<String>.from(json['chapterText']),
      href: json['href'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterTitle': chapterTitle,
      'chapterText': chapterText,
      'href': href,
    };
  }
}
