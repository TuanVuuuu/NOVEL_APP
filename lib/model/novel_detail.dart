import 'package:audiobook/model/chapter.dart';

class NovelDetail {
  String? title;
  String? author;
  String? status;
  List<String>? genres;
  String? chapters;
  String? chaptersPerWeek;
  String? views;
  String? bookmarked;
  String? rating;
  String? ratingCount;
  List<String>? description;
  List<Chapter>? chapterLatest;
  List<Chapter>? chapterList;

  NovelDetail(
      {this.title,
      this.author,
      this.status,
      this.genres,
      this.chapters,
      this.chaptersPerWeek,
      this.views,
      this.bookmarked,
      this.rating,
      this.ratingCount,
      this.description,
      this.chapterLatest,
      this.chapterList});

  NovelDetail.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    author = json['author'];
    status = json['status'];
    genres = json['genres'].cast<String>();
    chapters = json['chapters'];
    chaptersPerWeek = json['chaptersPerWeek'];
    views = json['views'];
    bookmarked = json['bookmarked'];
    rating = json['rating'];
    ratingCount = json['ratingCount'];
    description = json['description'].cast<String>();
    if (json['chapterLatest'] != null) {
      chapterLatest = <Chapter>[];
      json['chapterLatest'].forEach((v) {
        chapterLatest!.add(Chapter.fromJson(v));
      });
    }
    if (json['chapterList'] != null) {
      chapterList = <Chapter>[];
      json['chapterList'].forEach((v) {
        chapterList!.add(Chapter.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['author'] = author;
    data['status'] = status;
    data['genres'] = genres;
    data['chapters'] = chapters;
    data['chaptersPerWeek'] = chaptersPerWeek;
    data['views'] = views;
    data['bookmarked'] = bookmarked;
    data['rating'] = rating;
    data['ratingCount'] = ratingCount;
    data['description'] = description;
    if (chapterLatest != null) {
      data['chapterLatest'] = chapterLatest!.map((v) => v.toJson()).toList();
    }
    if (chapterList != null) {
      data['chapterList'] = chapterList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
