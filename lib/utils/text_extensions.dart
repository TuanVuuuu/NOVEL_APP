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
