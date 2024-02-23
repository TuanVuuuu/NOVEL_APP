// ignore_for_file: slash_for_doc_comments

import 'package:audiobook/src/shared/contants.dart';
import 'package:audiobook/src/shared/shared_preference/shared_preferences_utils.dart';

class SharedPrefManager {
  SharedPrefManager._();

  /** 
    * Get key local device token
    * Params: serialNumber
    * Response: String
  */
  static Future<List<String>?>? getLocalChapterData() async {
    final result = await SharedPrefUtils.getStringList(key: CHAPTER_DATA);
    return result;
  }

  /** 
    * Set local devices
    * Params: value
    * Response: bool
  */
  static Future<bool?>? setLocalChapterData(
      {required List<String> value}) async {
    final result =
        await SharedPrefUtils.saveStringList(key: CHAPTER_DATA, value: value);
    return result;
  }
}
