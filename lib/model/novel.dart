class Novel {
  final String? title;
  final String? image;
  final List<String>? description;
  final String? author;
  final String? chapters;
  final String? genre;
  final String? href;

  Novel({
    this.title,
    this.image,
    this.description,
    this.author,
    this.chapters,
    this.genre,
    this.href,
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
    );
  }
}
