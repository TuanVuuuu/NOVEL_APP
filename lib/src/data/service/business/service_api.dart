import 'dart:convert';

import 'package:audiobook/model/chapter_content.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/model/novel_detail.dart';
import 'package:audiobook/src/data/source/business/service_repository.dart';
import 'package:audiobook/utils/log_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ServiceApi implements ServiceRepository {
  ServiceApi();

  @override
  Future<ChapterContent> getChapterContent({required String href}) async {
    final url =
        Uri.parse("https://novel-api-mo19.onrender.com/v1/novel/$href/");

    try {
      apiGetLogger('getChapterContent', url.toString());
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        apiLoggerStateSuccess('getChapterContent', url.toString());
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

  @override
  Future<List<Novel>> getListNovel() async {
    final url = Uri.parse(
        "https://novel-api-mo19.onrender.com/v1/novel/de-cu/danh-sach/page-1");

    try {
      apiGetLogger('getListNovel', url.toString());
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<Novel> novels =
            jsonData.map((json) => Novel.fromJson(json)).toList();
        apiLoggerStateSuccess('getListNovel', url.toString());
        return novels;
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
  Future<List<Novel>> getListTopNovel() async {
    final url = Uri.parse(
        "https://novel-api-mo19.onrender.com/v1/novel/de-cu/danh-sach/top/page-1");

    try {
      apiGetLogger('getListTopNovel', url.toString());
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<Novel> novels =
            jsonData.map((json) => Novel.fromJson(json)).toList();
        apiLoggerStateSuccess('getListTopNovel', url.toString());
        return novels;
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
  Future<NovelDetail> getNovelInfo({required String href}) async {
    final url = Uri.parse("https://novel-api-mo19.onrender.com$href/");

    try {
      apiGetLogger('getNovelInfo', url.toString());
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        apiLoggerStateSuccess('getNovelInfo', url.toString());
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
  Future<List<Novel>> searchNovelByTitle({String? title}) async {
    final url = Uri.parse(
        "https://novel-api-mo19.onrender.com/v1/novel/search/$title/page-1");

    try {
      apiGetLogger('searchNovelByTitle', url.toString());
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<Novel> novels =
            jsonData.map((json) => Novel.fromJson(json)).toList();
        apiLoggerStateSuccess('searchNovelByTitle', url.toString());
        return novels;
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
