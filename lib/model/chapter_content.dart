class ChapterContent {
  final String? title;
  final List<String>? text;
  String? href;

  ChapterContent({this.title, this.text, this.href});

  factory ChapterContent.fromJson(Map<String, dynamic> json) {
    return ChapterContent(
      title: json['chapterTitle'],
      text: List<String>.from(json['chapterText']),
      href: json['href'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterTitle': title,
      'chapterText': text,
      'href': href,
    };
  }
}
