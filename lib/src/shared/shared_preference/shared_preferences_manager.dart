// ignore_for_file: slash_for_doc_comments

import 'package:audiobook/src/shared/contants.dart';
import 'package:audiobook/src/shared/shared_preference/shared_preferences_utils.dart';

class SharedPrefManager {
  SharedPrefManager._();

  /** 
    * Get local chapter
    * Params: 
    * Response: List<String>
  */
  static Future<List<String>?> getLocalChapterData() async {
    final result = await SharedPrefUtils.getStringList(key: CHAPTER_DATA);
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
    final result = await SharedPrefUtils.getStringList(key: NOVEL_DATA);
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
