// ignore_for_file: slash_for_doc_comments

import 'package:audiobook/src/shared/contants.dart';
import 'package:audiobook/src/shared/shared_preference/shared_preferences_utils.dart';
import 'package:audiobook/utils/log_extensions.dart';

class SharedPrefManager {
  SharedPrefManager._();

  /** 
    * Get local chapter
    * Params: 
    * Response: List<String>
  */
  static Future<List<String>?> getLocalChapterData() async {
    localGetLogger('getLocalChapterData', 'CHAPTER_DATA');
    final result = await SharedPrefUtils.getStringList(key: CHAPTER_DATA);
    localLoggerStateSuccess('getLocalChapterData', '$result');
    return result;
  }

  /** 
    * Set local chapter
    * Params: value
    * Response: bool
  */
  static Future<void> setLocalChapterData({required List<String> value}) async {
    await SharedPrefUtils.saveStringList(key: CHAPTER_DATA, value: value);
  }

  /** 
    * Get local novel
    * Params: 
    * Response: List<String>
  */
  static Future<List<String>?> getLocalNovelData() async {
    localGetLogger('getLocalNovelData', 'NOVEL_DATA');
    final result = await SharedPrefUtils.getStringList(key: NOVEL_DATA);
    localLoggerStateSuccess('getLocalNovelData', '$result');
    return result;
  }

  /** 
    * Set local chapter
    * Params: value
    * Response: bool
  */
  static Future<void> setLocalNovelData({required List<String> value}) async {
    await SharedPrefUtils.saveStringList(key: NOVEL_DATA, value: value);
  }
}
