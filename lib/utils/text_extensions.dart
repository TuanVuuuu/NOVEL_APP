String mergeChapterText(List<String> chapterText) {
  // Tạo một StringBuilder để gộp các phần tử của chapterText
  StringBuffer mergedText = StringBuffer();

  // Duyệt qua từng phần tử trong danh sách chapterText
  for (String text in chapterText) {
    // Bỏ qua các phần tử rỗng
    if (text.isNotEmpty) {
      // Nếu phần tử không rỗng, thêm nội dung vào StringBuilder với khoảng trắng giữa các đoạn văn
      mergedText.write('$text ');
    }
  }

  // Trả về nội dung đoạn văn đã gộp
  return mergedText.toString();
}

List<String> splitTextIntoChunks(String text) {
  // Tạo danh sách để chứa các phần nhỏ của đoạn văn
  List<String> chunks = [];
  // Tính số lượng chunks cần tạo
  int numChunks = (text.length / 3500).ceil();
  // Tách đoạn văn thành các phần nhỏ và thêm vào danh sách
  for (int i = 0; i < numChunks; i++) {
    int start = i * 3500;
    int end = (i + 1) * 3500;
    if (end > text.length) {
      end = text.length;
    }
    chunks.add(text.substring(start, end));
  }
  return chunks;
}

String getCurrentPhrase(
    String text, String currentWord, int phraseLength, int currentIndex) {
  if (currentIndex >= 0 && currentIndex < text.length) {
    int halfPhraseLength = phraseLength ~/ 2;
    int startIndex = currentIndex - halfPhraseLength;
    int endIndex = currentIndex + halfPhraseLength;

    // Đảm bảo vị trí bắt đầu và kết thúc không vượt quá biên của văn bản
    if (startIndex < 0) {
      endIndex +=
          (0 - startIndex); // Điều chỉnh vị trí kết thúc nếu startIndex âm
      startIndex = 0;
    }
    if (endIndex >= text.length) {
      startIndex -= (endIndex -
          text.length +
          1); // Điều chỉnh vị trí bắt đầu nếu endIndex vượt quá biên
      endIndex = text.length - 1;
    }

    // Lấy phần của văn bản từ vị trí bắt đầu đến vị trí kết thúc
    String phrase = text.length > 15 ? text.substring(startIndex, endIndex + 1) : '';
    return phrase;
  }
  return '';
}
