import 'dart:convert';
import 'package:audiobook/model/chapter_content.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/model/novel_detail.dart';
import 'package:audiobook/src/data/source/local/local_service_repository.dart';
import 'package:audiobook/utils/log_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LocalServiceApi implements LocalServiceRepository {
  LocalServiceApi();

  @override
  Future<List<Novel>> getListNovel() async {
    final url = Uri.parse("http://localhost:8000/v1/de-cu/danh-sach/");

    try {
      apiLogger('getListNovelLocal', url.toString());
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<Novel> novels =
            jsonData.map((json) => Novel.fromJson(json)).toList();
        apiLoggerStateSuccess('getListNovel', url.toString());
        return novels;
      } else {
        throw Exception(
            'Failed to load data: errorCode ${response.statusCode} message ${response.body}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      rethrow;
    }
  }

  @override
  Future<NovelDetail> getNovelInfo({required String href}) async {
    final url = Uri.parse("http://localhost:8000$href/");

    try {
      apiLogger('getNovelInfo', url.toString());
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NovelDetail.fromJson(data.first);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      rethrow;
    }
  }

  @override
  Future<ChapterContent> getChapterContent({required String href}) async {
    try {
      final url = Uri.parse("http://localhost:8000/v1/$href/");
      if (kDebugMode) {
        print("url: $url");
      }
      apiLogger('getChapterContent', url.toString());
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChapterContent.fromJson(data);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      rethrow;
    }
  }
}
