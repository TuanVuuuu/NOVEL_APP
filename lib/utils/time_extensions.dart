// Hàm định dạng thời gian
String formatTime(double timeInSeconds) {
  int minutes = ((timeInSeconds / 60) % 60).floor();
  int seconds = (timeInSeconds % 60).floor();
  return '${minutes < 10 ? '0$minutes' : minutes}:${seconds < 10 ? '0$seconds' : seconds}';
}
