enum TtsState {
  playing,
  stopped,
  paused,
  continued,
}

enum LoadState {
  none,
  loading,
  loadSuccess,
  loadSecondsSuccess,
  loadFailure,
  loadSecondsFailure,
  loadBackGround,
  loadingSeconds,
}

enum PageCurrent {
  dashboard,
  libdashboard,
  novel,
  chapterlist,
  chapter,
  search,
  audio,
}

enum NovelHandle {
  read,
  audio,
}

enum AudioStyle {
  player,
  miniplayer,
  none,
}
