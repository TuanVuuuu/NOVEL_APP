import 'dart:io';
import 'package:audiobook/model/chapter_content.dart';
import 'package:audiobook/model/hive/chapter_item.dart';
import 'package:audiobook/src/data/service/local/hive_service.dart';
import 'package:audiobook/src/shared/hive/setup_locator.dart';
import 'package:audiobook/utils/enum_constants.dart';
import 'package:audiobook/utils/text_extensions.dart';
import 'package:audiobook/view/audio_player/audiobook_player_page.dart';
import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/utils/size_extensions.dart';
import 'package:audiobook/view/chapter_detail/cubit/chapter_detail_cubit.dart';
import 'package:audiobook/view/home_page/home_page.dart';
import 'package:audiobook/view/library_novel/library_novel_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class TabBarManager extends StatefulWidget {
  const TabBarManager({super.key});

  @override
  State<TabBarManager> createState() => _TabBarManagerState();
}

class _TabBarManagerState extends State<TabBarManager> {
  int menuIndex = 0;
  int tabIndex = 0;
  PageCurrent pageCurrent = PageCurrent.dashboard;
  PageCurrent pageLibCurrent = PageCurrent.dashboard;
  AudioStyle audioStyle = AudioStyle.none;
  Novel novelCurrent = Novel();
  List<Chapter>? chapterListCurrent = [];
  int? chapterIndex = 0;
  Chapter? chapterData = Chapter();
  List<String> listIndexTitle = [
    'Khám phá',
    'Tủ sách',
  ];
  bool canPop = false;
  late FlutterTts flutterTts;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  int end = 0;
  int endSession = 0;

  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  String? voiceTextInput = 'Vui lòng đợi...';
  int numberSpeak = 0;
  final HiveService _hiveService = locator<HiveService>();
  int chapterIndexCurrent = 0;
  ChapterContent chapterContent = ChapterContent();
  String? nameNovel = '';

  @override
  void initState() {
    super.initState();
    initTts();
  }

  PreferredSizeWidget? get _appbar {
    if ((pageCurrent) == PageCurrent.novel ||
        pageCurrent == PageCurrent.chapterlist ||
        pageCurrent == PageCurrent.chapter) {
      return null;
    }

    if ((pageLibCurrent) == PageCurrent.novel ||
        pageLibCurrent == PageCurrent.chapterlist ||
        pageLibCurrent == PageCurrent.chapter) {
      return null;
    }
    if (pageCurrent == PageCurrent.search ||
        pageLibCurrent == PageCurrent.search) {
      return AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          onPressed: () {
            setState(() {
              pageCurrent = PageCurrent.dashboard;
              pageLibCurrent = PageCurrent.libdashboard;
            });
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
          ),
        ),
        title: const Text('Tìm kiếm'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      );
    }

    if (pageCurrent == PageCurrent.dashboard ||
        pageLibCurrent == PageCurrent.libdashboard) {
      return AppBar(
        title: Text(listIndexTitle[menuIndex]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                pageCurrent = PageCurrent.search;
                pageLibCurrent = PageCurrent.search;
              });
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune),
          ),
        ],
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        return onBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appbar,
        body: IndexedStack(
          index: menuIndex,
          children: [
            HomePage(
              pageCurrent: (page) {
                setState(() {
                  pageCurrent = page;
                });
              },
              setCurrentPage: pageCurrent,
              audioState: (style, chapter, chapterList, index) {
                setState(() {
                  audioStyle = AudioStyle.player;
                  chapterListCurrent = chapterList;
                  chapterIndex = index;
                  chapterData = chapter;

                  nameNovel = novelCurrent.title;
                  chapterIndexCurrent = chapterIndex ?? 0;
                });

                bool hasLocalChapterData = false;
                checkLocalChapterData()
                    .then((value) => hasLocalChapterData = value)
                    .whenComplete(() {
                  if (!hasLocalChapterData) {
                    Get.find<ChapterDetailCubit>().getChapterContent(
                        href: (chapterData ?? Chapter())
                                .chapterLink
                                ?.split('/v1/')[1] ??
                            '');
                  }
                });
                multiStop();
                initTts();
              },
              onTapNovel: (novel) {
                setState(() {
                  novelCurrent = novel;
                });
              },
            ),
            LibraryNovelPage(
              pageCurrent: (page) {
                setState(() {
                  pageLibCurrent = page;
                });
              },
              onTapNovel: (novel) {
                setState(() {
                  novelCurrent = novel;
                });
              },
              setCurrentPage: pageLibCurrent,
              audioState: (style, chapter, chapterList, index) {
                setState(() {
                  audioStyle = AudioStyle.player;
                  chapterListCurrent = chapterList;
                  chapterIndex = index;
                  chapterData = chapter;

                  nameNovel = novelCurrent.title;
                  chapterIndexCurrent = chapterIndex ?? 0;
                });

                bool hasLocalChapterData = false;
                checkLocalChapterData()
                    .then((value) => hasLocalChapterData = value)
                    .whenComplete(() {
                  if (!hasLocalChapterData) {
                    Get.find<ChapterDetailCubit>().getChapterContent(
                        href: (chapterData ?? Chapter())
                                .chapterLink
                                ?.split('/v1/')[1] ??
                            '');
                  }
                });
                multiStop();
                initTts();
              },
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.transparent,
          height: kBottomNavigationBarHeight +
              (Platform.isAndroid ? 2 : 36) +
              (audioStyle != AudioStyle.none
                  ? (audioStyle == AudioStyle.player
                      ? sizeSystem(context).height
                      : 80)
                  : 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (audioStyle != AudioStyle.none) ...[
                audioStyle == AudioStyle.player
                    ? _buildPlayer(context, AudioStyle.player)
                    : _buildPlayer(context, AudioStyle.miniplayer)
              ] else ...[
                const SizedBox()
              ],
              if (audioStyle != AudioStyle.player) _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer(BuildContext context, AudioStyle player) {
    return Column(
      children: [
        _buildListener(),
        SizedBox(
            height: player == AudioStyle.miniplayer
                ? 80
                : sizeSystem(context).height,
            child: AudiobookPlayerPage(
              novelData: novelCurrent,
              onTapDown: (style) {
                setState(() {
                  audioStyle = AudioStyle.miniplayer;
                });
              },
              listChapterArg: chapterListCurrent ?? [],
              chapterIndex: chapterIndexCurrent,
              chapterArg: chapterData ?? Chapter(),
              onTap: (style) {
                setState(() {
                  audioStyle = style;
                });
              },
              audioStyle: audioStyle,
              onDispose: () {
                setState(() {
                  audioStyle = AudioStyle.none;
                });
              },
              flutterTts: flutterTts,
              onStop: () {
                _stop();
              },
              onSpeak: () {
                _speak();
                setState(() {
                  ttsState = TtsState.playing;
                });
              },
              onPause: () {
                _pause();
              },
              onMultiStop: () {
                multiStop();
              },
              ttsState: ttsState,
              textInput: voiceTextInput,
              end: end,
              endSession: endSession,
              onPreviousChapter: () {
                onPreviousChapter();
              },
              onNextChapter: () {
                onNextChapter();
              },
            )),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      currentIndex: menuIndex,
      onTap: (idx) {
        setState(() {
          menuIndex = idx;
          pageCurrent = PageCurrent.dashboard;
          pageLibCurrent = PageCurrent.libdashboard;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: "Khám phá",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: "Tủ sách",
        ),
      ],
    );
  }

  void onBackPress() {
    if ((pageCurrent) == PageCurrent.novel) {
      setState(() {
        pageCurrent = PageCurrent.dashboard;
        canPop = false;
      });
    }

    if ((pageLibCurrent) == PageCurrent.novel) {
      setState(() {
        pageCurrent = PageCurrent.libdashboard;
      });
      canPop = false;
    }

    if (pageCurrent == PageCurrent.chapterlist) {
      setState(() {
        pageCurrent = PageCurrent.novel;
      });
      canPop = false;
    }

    if (pageCurrent == PageCurrent.audio || audioStyle == AudioStyle.player) {
      setState(() {
        pageCurrent = PageCurrent.chapterlist;
        audioStyle = AudioStyle.miniplayer;
      });
      canPop = false;
    }
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    if (isPlaying) {
      _stop();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Playing");
        }
        ttsState = TtsState.playing;
      });
    });

    if (isAndroid) {
      // flutterTts.setInitHandler(() {
      //   setState(() {
      //     if (kDebugMode) {
      //       print("TTS Initialized");
      //     }
      //   });
      // });
    }

    flutterTts.setCompletionHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Complete");
        }
        endSession = end;
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Cancel");
        }
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Paused");
        }
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        if (kDebugMode) {
          print("Continued");
        }
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        if (kDebugMode) {
          print("error: $msg");
        }
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setProgressHandler(
        (String text, int startOffset, int endOffset, String word) {
      if (word != "" && audioStyle != AudioStyle.miniplayer) {
        setState(() {
          end = endSession + endOffset;
        });
      }
    });
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      if (kDebugMode) {
        print(engine);
      }
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      if (kDebugMode) {
        print(voice);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    setState(() {
      if (isStopped) {
        endSession = 0;
        end = 0;
      }
    });
    if (voiceTextInput != null) {
      if (voiceTextInput!.isNotEmpty) {
        String text = voiceTextInput!;
        // Kiểm tra chiều dài của đoạn văn
        if (text.length > 3500) {
          // Tách đoạn văn thành các phần nhỏ không vượt quá 3500 ký tự
          List<String> chunks = splitTextIntoChunks(text);
          setState(() {
            ttsState = TtsState.playing;
            numberSpeak = chunks.length;
          });
          // Đọc lần lượt các phần nhỏ
          for (String chunk in chunks) {
            if (ttsState != TtsState.stopped && ttsState != TtsState.paused) {
              await flutterTts.awaitSpeakCompletion(true);
              await flutterTts.speak(chunk);
            }
          }
        } else {
          setState(() {
            numberSpeak = 1;
          });
          await flutterTts.speak(text);
        }
      }
    }
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  Future<void> multiStop() async {
    for (int i = 0; i <= numberSpeak; i++) {
      // await Future.delayed(const Duration(milliseconds: 100));
      _stop();
      setState(() {
        ttsState = TtsState.stopped;
      });
    }
  }

  Future<bool> checkLocalChapterData({String? href}) async {
    final listChaptersLocal = await _hiveService.getAllChapters();
    bool foundMatchingChapter = false;
    final String? checkHref = href ??
        (chapterListCurrent ?? [])[chapterIndexCurrent]
            .chapterLink
            ?.split('/v1/')[1];

    for (var chapterLocal in listChaptersLocal) {
      if (chapterLocal.href == checkHref) {
        setState(() {
          chapterContent = ChapterContent(
              title: chapterLocal.chapterTitle,
              text: chapterLocal.chapterText,
              href: chapterLocal.href);

          _stop();
          voiceTextInput = mergeChapterText(chapterContent.text ?? []);
        });
        _speak();
        foundMatchingChapter = true;
      }
    }

    return foundMatchingChapter;
  }

  Widget _buildListener() {
    return BlocListener(
      bloc: Get.find<ChapterDetailCubit>(),
      listener: (context, state) async {
        if (state is GetChapterContentInProgress) {
          return;
        }

        if (state is GetChapterContentFailure) {
          return;
        }

        if (state is GetChapterContentSuccess) {
          setState(() {
            chapterContent = state.response;
            chapterContent.href =
                (chapterListCurrent ?? [])[chapterIndexCurrent]
                        .chapterLink
                        ?.split('/v1/')[1] ??
                    '';

            nameNovel = chapterContent.title;
          });

          final ChapterItem chapterItem = ChapterItem(
              chapterTitle: chapterContent.title,
              href: chapterContent.href,
              chapterText: chapterContent.text);

          await _hiveService.addChapter(chapterItem);
          _stop();
          voiceTextInput = mergeChapterText(chapterContent.text ?? []);
          _speak();
          return;
        }
      },
      child: Container(),
    );
  }

  Future<void> onPreviousChapter() async {
    if (chapterIndexCurrent > 0) {
      setState(() {
        chapterIndexCurrent = chapterIndexCurrent - 1;
      });
      bool hasLocalChapterData = await checkLocalChapterData();
      if (!hasLocalChapterData) {
        Get.find<ChapterDetailCubit>().getChapterContent(
            href: (chapterListCurrent ?? [])[chapterIndexCurrent]
                    .chapterLink
                    ?.split('/v1/')[1] ??
                '');
      }
    }
  }

  Future<void> onNextChapter() async {
    if (chapterIndexCurrent < (chapterListCurrent ?? []).length - 1) {
      setState(() {
        chapterIndexCurrent = chapterIndexCurrent + 1;
      });
      bool hasLocalChapterData = await checkLocalChapterData();
      if (!hasLocalChapterData) {
        Get.find<ChapterDetailCubit>().getChapterContent(
            href: (chapterListCurrent ?? [])[chapterIndexCurrent]
                    .chapterLink
                    ?.split('/v1/')[1] ??
                '');
      }
    }
  }
}
