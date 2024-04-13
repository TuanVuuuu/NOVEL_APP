import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/chapter_content.dart';
import 'package:audiobook/model/hive/chapter_item.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/src/data/service/local/hive_service.dart';
import 'package:audiobook/src/shared/hive/setup_locator.dart';
import 'package:audiobook/utils/size_extensions.dart';
import 'package:audiobook/utils/text_extensions.dart';
import 'package:audiobook/utils/time_extensions.dart';
import 'package:audiobook/utils/enum_constants.dart';
import 'package:audiobook/view/chapter_detail/cubit/chapter_detail_cubit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

class AudiobookPlayerPage extends StatefulWidget {
  const AudiobookPlayerPage({
    super.key,
    this.onTapBack,
    this.onTap,
    this.onDispose,
    required this.novelData,
    this.onTapDown,
    required this.listChapterArg,
    required this.chapterIndex,
    required this.chapterArg,
    required this.audioStyle,
  });

  final Function()? onDispose;
  final Function()? onTapBack;
  final Novel? novelData;
  final Function(AudioStyle audioStyle)? onTapDown;
  final Function(AudioStyle audioStyle)? onTap;
  final List<Chapter> listChapterArg;
  final int chapterIndex;
  final Chapter chapterArg;
  final AudioStyle audioStyle;

  @override
  State<AudiobookPlayerPage> createState() => _AudiobookPlayerPageState();
}

class _AudiobookPlayerPageState extends State<AudiobookPlayerPage> {
  AudioStyle audioStyle = AudioStyle.player;
  String? voiceTextInput = 'Vui lòng đợi...';

  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  int end = 0;
  int endSession = 0;
  String wordCurrent = '';
  int numberSpeak = 0;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  late ChapterContent chapterContent = ChapterContent();
  int chapterIndexCurrent = 0;
  LoadState loadState = LoadState.none;
  List<String> listChapterContent = [];
  final HiveService _hiveService = locator<HiveService>();
  String? nameNovel = '';
  String? chapterNameNovel = '';
  String currentWord = '';

  @override
  initState() {
    super.initState();
    initTts();
    nameNovel = widget.novelData?.title;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      chapterIndexCurrent = widget.chapterIndex;
      bool hasLocalChapterData = await checkLocalChapterData();
      if (!hasLocalChapterData) {
        Get.find<ChapterDetailCubit>().getChapterContent(
            href: widget.chapterArg.chapterLink?.split('/v1/')[1] ?? '');
      }
    });
  }

  Future<bool> checkLocalChapterData({String? href}) async {
    final listChaptersLocal = await _hiveService.getAllChapters();
    bool foundMatchingChapter = false;
    final String? checkHref = href ??
        widget.listChapterArg[chapterIndexCurrent].chapterLink
            ?.split('/v1/')[1];

    for (var chapterLocal in listChaptersLocal) {
      if (chapterLocal.href == checkHref) {
        setState(() {
          loadState = LoadState.loadSuccess;
          chapterContent = ChapterContent(
              title: chapterLocal.chapterTitle,
              text: chapterLocal.chapterText,
              href: chapterLocal.href);

          _stop();
          voiceTextInput = mergeChapterText(chapterContent.text ?? []);
          _speak();
        });
        foundMatchingChapter = true;
      }
    }

    return foundMatchingChapter;
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
      flutterTts.setInitHandler(() {
        setState(() {
          if (kDebugMode) {
            print("TTS Initialized");
          }
        });
      });
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
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

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

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMiniPlayerMode = audioStyle == AudioStyle.miniplayer;

    flutterTts.setProgressHandler(
        (String text, int startOffset, int endOffset, String word) {
      if (word != "") {
        setState(() {
          currentWord = word;
          end = endSession + endOffset;
        });
      }
    });

    return widget.audioStyle == AudioStyle.player
        ? Scaffold(body: _buildPlayer(context))
        : isMiniPlayerMode
            ? _buildMiniplayer(context)
            : Scaffold(body: _buildPlayer(context));
  }

  Stack _buildPlayer(BuildContext context) {
    // Tính thời gian tổng cần để đọc hết đoạn văn
    double totalReadingTime = voiceTextInput!.length / 10;

    // Tính thời gian hiện tại của tiến trình đọc
    double currentReadingTime = (end ~/ 10).toDouble();

    return Stack(
      children: [
        _engineSection(),
        _futureBuilder(),
        _buildBackgroundImage(),
        _buildBackgroundBlur(context),
        _buildListener(),
        Column(
          children: [
            _buildButtonDown(),
            _buildCircleImage(),
            const SizedBox(height: 32),
            _buildNameNovel(),
            const SizedBox(height: 16),
            _buildChapterTitle(),
            const SizedBox(height: 16),
            voiceTextInput != null && voiceTextInput != ""
                ? Text(
                    getCurrentPhrase(
                        voiceTextInput ?? "", currentWord, 50, end),
                    style: const TextStyle(color: Colors.grey),
                  )
                : const SizedBox(),
            const SizedBox(height: 16),
            _buildProgressBar(),
            _buildTimerProgressBar(currentReadingTime, totalReadingTime),
            _buildControllerPlayer(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.file_upload_outlined,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.podcasts,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Row _buildControllerPlayer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.bookmark_border,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () async {
            if (chapterIndexCurrent > 0) {
              setState(() {
                chapterIndexCurrent = chapterIndexCurrent - 1;
              });
              bool hasLocalChapterData = await checkLocalChapterData();
              if (!hasLocalChapterData) {
                Get.find<ChapterDetailCubit>().getChapterContent(
                    href: widget.listChapterArg[chapterIndexCurrent].chapterLink
                            ?.split('/v1/')[1] ??
                        '');
              }
            }
          },
          icon: Icon(
            Icons.skip_previous,
            color: chapterIndexCurrent > 0 ? Colors.white : Colors.grey,
          ),
        ),
        InkWell(
          onTap: () {
            if (isPlaying) {
              _pause();
            } else {
              _speak();
            }
          },
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            if (chapterIndexCurrent < widget.listChapterArg.length - 1) {
              setState(() {
                chapterIndexCurrent = chapterIndexCurrent + 1;
              });
              bool hasLocalChapterData = await checkLocalChapterData();
              if (!hasLocalChapterData) {
                Get.find<ChapterDetailCubit>().getChapterContent(
                    href: widget.listChapterArg[chapterIndexCurrent].chapterLink
                            ?.split('/v1/')[1] ??
                        '');
              }
            }
          },
          icon: Icon(
            Icons.skip_next,
            color: chapterIndexCurrent < widget.listChapterArg.length - 1
                ? Colors.white
                : Colors.grey,
          ),
        ),
        const SizedBox(
          height: 48,
          width: 48,
        ),
      ],
    );
  }

  Padding _buildTimerProgressBar(
      double currentReadingTime, double totalReadingTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formatTime(currentReadingTime),
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            formatTime(totalReadingTime),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Padding _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
      child: LinearProgressIndicator(
        value: end / voiceTextInput!.length,
        backgroundColor: Colors.grey,
      ),
    );
  }

  Widget _engineSection() {
    if (isAndroid) {
      return FutureBuilder<dynamic>(
          future: _getEngines(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return _enginesDropDownSection(snapshot.data);
            } else if (snapshot.hasError) {
              return const Text('Error loading engines...');
            } else {
              return const Text('Loading engines...');
            }
          });
    } else {
      return const SizedBox(width: 0, height: 0);
    }
  }

  Widget _enginesDropDownSection(dynamic engines) => Container(
        padding: const EdgeInsets.only(top: 50.0),
        child: DropdownButton(
          value: engine,
          items: getEnginesDropDownMenuItems(engines),
          onChanged: changedEnginesDropDownItem,
        ),
      );

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedEnginesDropDownItem(String? selectedEngine) async {
    await flutterTts.setEngine(selectedEngine!);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  Widget _futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data);
        } else if (snapshot.hasError) {
          return const Text('Error loading languages...');
        } else {
          return const Text('Loading Languages...');
        }
      });

  Widget _languageDropDownSection(dynamic languages) => Container(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(languages),
          onChanged: changedLanguageDropDownItem,
        ),
        Visibility(
          visible: isAndroid,
          child: Text("Is installed: $isCurrentLanguageInstalled"),
        ),
      ]));

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language!)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  Text _buildChapterTitle() {
    return Text(
      "${widget.listChapterArg[widget.chapterIndex].chapterTitle?.replaceAll(widget.listChapterArg[widget.chapterIndex].chapterTime.toString(), '')}",
      style: const TextStyle(color: Colors.white),
    );
  }

  Text _buildNameNovel() {
    return Text(
      nameNovel ?? '',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
    );
  }

  Padding _buildCircleImage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: CircleAvatar(
        radius: 100,
        backgroundImage: NetworkImage(widget.novelData?.image ?? ''),
      ),
    );
  }

  Container _buildButtonDown() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: kToolbarHeight),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                audioStyle = AudioStyle.miniplayer;
                widget.onTapDown?.call(audioStyle);
              });
            },
          ),
        ],
      ),
    );
  }

  ConstrainedBox _buildBackgroundBlur(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Container(
          height: sizeSystem(context).height,
          width: sizeSystem(context).width,
          color: Colors.black.withOpacity(0.6),
        ));
  }

  ConstrainedBox _buildBackgroundImage() {
    return ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.novelData?.image ?? ''),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
            ),
          ),
        ));
  }

  Container _buildMiniplayer(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      width: double.infinity,
      child: Stack(
        children: [
          _buildListener(),
          const Divider(
            height: 2,
            color: Colors.grey,
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  widget.onTap?.call(AudioStyle.player);
                  setState(() {
                    audioStyle = AudioStyle.player;
                  });
                },
                child: SizedBox(
                  width: sizeSystem(context).width - 80,
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            image: DecorationImage(
                                image:
                                    NetworkImage(widget.novelData?.image ?? ''),
                                fit: BoxFit.cover)),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: widget.novelData != null
                                  ? _autoTextSizeAnimation()
                                  : const Text(
                                      'Loading...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _autoTextSizeAnimation(
                                    title: widget
                                        .listChapterArg[
                                            // chapterIndexCurrent ??
                                            widget.chapterIndex]
                                        .chapterTitle
                                        ?.replaceAll(
                                            widget.chapterArg.chapterTime ?? '',
                                            ''),
                                    textStyle: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.normal),
                                    height: 18))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (isPlaying) {
                          _pause();
                        } else {
                          _speak();
                        }
                      },
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () async {
                        multiStop();
                        widget.onDispose?.call();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  DefaultTextStyle _autoTextSizeAnimation(
      {String? title, TextStyle? textStyle, double? height}) {
    return DefaultTextStyle(
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        child: AutoSizeText(
          title ?? widget.novelData?.title ?? 'Loading...',
          style: textStyle ??
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          maxLines: 1,
          minFontSize: 16,
          overflowReplacement: SizedBox(
            height: height ?? 28,
            child: Marquee(
              text: title ?? widget.novelData?.title ?? 'Loading...',
              style: textStyle ??
                  const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
              blankSpace: 30,
              startAfter: const Duration(seconds: 2),
              pauseAfterRound: const Duration(seconds: 2),
            ),
          ),
        ));
  }

  Widget _buildListener() {
    return BlocListener(
      bloc: Get.find<ChapterDetailCubit>(),
      listener: (context, state) async {
        if (state is GetChapterContentInProgress) {
          setState(() {
            loadState = LoadState.loading;
          });
          return;
        }

        if (state is GetChapterContentFailure) {
          setState(() {
            loadState = LoadState.loadFailure;
          });
          return;
        }

        if (state is GetChapterContentSuccess) {
          setState(() {
            loadState = LoadState.loadSuccess;
            chapterContent = state.response;
            chapterContent.href = widget
                    .listChapterArg[chapterIndexCurrent].chapterLink
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

  Future<void> multiStop() async {
    for (int i = 0; i <= numberSpeak; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _stop();
    }
  }
}
