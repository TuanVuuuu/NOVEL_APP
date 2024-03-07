class Novel {
  final String? title;
  final String? image;
  final List<String>? description;
  final String? author;
  final String? chapters;
  final String? genre;
  final String? href;
  final int? rank;

  Novel({
    this.title,
    this.image,
    this.description,
    this.author,
    this.chapters,
    this.genre,
    this.href,
    this.rank,
  });

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
        title: json['title'] ?? '',
        image: json['image'] ?? '',
        description: (json['description'] != null)
            ? List<String>.from(json['description'])
            : [],
        author: json['author'] ?? '',
        chapters: json['chapters'] ?? '',
        genre: json['genre'] ?? '',
        href: json['href'] ?? '',
        rank: json['rank'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['image'] = image;
    data['description'] = description;
    data['author'] = author;
    data['chapters'] = chapters;
    data['genre'] = genre;
    data['href'] = href;
    data['rank'] = rank;
    return data;
  }
}
