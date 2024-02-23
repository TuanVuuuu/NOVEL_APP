class Chapter {
  String? chapterTitle;
  String? chapterLink;
  String? chapterTime;
  int? index;

  Chapter({this.chapterTitle, this.chapterLink, this.chapterTime});

  Chapter.fromJson(Map<String, dynamic> json) {
    chapterTitle = json['chapterTitle'];
    chapterLink = json['chapterLink'];
    chapterTime = json['chapterTime'];
    index = json['index'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chapterTitle'] = chapterTitle;
    data['chapterLink'] = chapterLink;
    data['chapterTime'] = chapterTime;
    data['index'] = index;
    return data;
  }
}
