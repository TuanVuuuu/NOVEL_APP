class APILog {
  final String? title;
  final String? description;
  final int? errorCode;
  final String? message;
  final String? updateAt;

  APILog({
    this.title,
    this.description,
    this.errorCode,
    this.message,
    this.updateAt,
  });

  factory APILog.fromJson(Map<String, dynamic> json) {
    return APILog(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        errorCode: json['errorCode'] ?? '',
        message: json['message'] ?? '',
        updateAt: json['updateAt'] ?? '');
  }
}
