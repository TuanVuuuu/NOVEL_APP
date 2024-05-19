import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/utils/size_extensions.dart';
import 'package:audiobook/utils/text_extensions.dart';
import 'package:audiobook/utils/time_extensions.dart';
import 'package:audiobook/utils/enum_constants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:marquee/marquee.dart';

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
    required this.flutterTts,
    this.onStop,
    this.onSpeak,
    this.onPause,
    this.onMultiStop,
    this.ttsState,
    this.textInput,
    this.end,
    this.onPreviousChapter,
    this.onNextChapter,
    this.setEndListener,
    this.endSession,
  });

  final Function()? onDispose;
  final Function()? onTapBack;
  final Function()? onStop;
  final Novel? novelData;
  final Function(AudioStyle audioStyle)? onTapDown;
  final Function(AudioStyle audioStyle)? onTap;
  final List<Chapter> listChapterArg;
  final int chapterIndex;
  final Chapter chapterArg;
  final AudioStyle audioStyle;
  final FlutterTts flutterTts;
  final Function()? onSpeak;
  final Function()? onPause;
  final Function()? onMultiStop;
  final TtsState? ttsState;
  final String? textInput;
  final int? end;
  final Function()? onPreviousChapter;
  final Function()? onNextChapter;
  final Function(dynamic endData)? setEndListener;
  final int? endSession;

  @override
  State<AudiobookPlayerPage> createState() => _AudiobookPlayerPageState();
}

class _AudiobookPlayerPageState extends State<AudiobookPlayerPage> {
  AudioStyle audioStyle = AudioStyle.player;

  String? language;
  String? engine;

  bool isCurrentLanguageInstalled = false;

  String wordCurrent = '';

  List<String> listChapterContent = [];

  String? chapterNameNovel = '';
  String currentWord = '';

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  get isPlaying => widget.ttsState == TtsState.playing;
  get isStopped => widget.ttsState == TtsState.stopped;
  get isPaused => widget.ttsState == TtsState.paused;
  get isContinued => widget.ttsState == TtsState.continued;

  int end = 0;

  @override
  initState() {
    super.initState();
  }

  Future<dynamic> _getLanguages() async => await widget.flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await widget.flutterTts.getEngines;

  @override
  void dispose() {
    super.dispose();
    widget.onStop?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMiniPlayerMode = audioStyle == AudioStyle.miniplayer;

    if (end != widget.end && widget.end != null) {
      setState(() {
        end = widget.end!;
      });
    }

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          audioStyle = AudioStyle.miniplayer;
          widget.onTapDown?.call(audioStyle);
        },
        child: widget.audioStyle == AudioStyle.player
            ? Scaffold(body: _buildPlayer(context))
            : isMiniPlayerMode
                ? _buildMiniplayer(context)
                : Scaffold(body: _buildPlayer(context)));
  }

  Stack _buildPlayer(BuildContext context) {
    // Tính thời gian tổng cần để đọc hết đoạn văn
    double totalReadingTime = widget.textInput!.length / 10;

    // Tính thời gian hiện tại của tiến trình đọc
    double currentReadingTime = (end ~/ 10).toDouble();

    return Stack(
      children: [
        _engineSection(),
        _futureBuilder(),
        _buildBackgroundImage(),
        _buildBackgroundBlur(context),
        Column(
          children: [
            _buildButtonDown(),
            _buildCircleImage(),
            const SizedBox(height: 32),
            _buildNameNovel(),
            const SizedBox(height: 16),
            _buildChapterTitle(),
            const SizedBox(height: 16),
            widget.textInput != null && widget.textInput != ""
                ? Text(
                    getCurrentPhrase(
                        widget.textInput ?? "", currentWord, 50, end),
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
          onPressed: () {
            widget.onPreviousChapter?.call();
          },
          icon: Icon(
            Icons.skip_previous,
            color: widget.chapterIndex > 0 ? Colors.white : Colors.grey,
          ),
        ),
        InkWell(
          onTap: () {
            if (isPlaying) {
              widget.onPause?.call();
            } else {
              widget.onSpeak?.call();
            }
          },
          child: CircleAvatar(
            radius: 32,
            // backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            widget.onStop?.call();
            widget.onNextChapter?.call();
          },
          icon: Icon(
            Icons.skip_next,
            color: widget.chapterIndex < widget.listChapterArg.length - 1
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
        value: end / widget.textInput!.length,
        // backgroundColor: Colors.grey,
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
    await widget.flutterTts.setEngine(selectedEngine!);
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
      widget.flutterTts.setLanguage(language!);
      if (isAndroid) {
        widget.flutterTts
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
      widget.novelData?.title ?? '',
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
                          widget.onPause?.call();
                        } else {
                          widget.onSpeak?.call();
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
                        widget.onMultiStop?.call();
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
              child:
                  // Marquee(
                  //   text:
                  Text(
                title ?? widget.novelData?.title ?? 'Loading...',
                style: textStyle ??
                    const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
              )

              //   blankSpace: 30,
              //   startAfter: const Duration(seconds: 2),
              //   pauseAfterRound: const Duration(seconds: 2),
              // ),
              ),
        ));
  }
}
