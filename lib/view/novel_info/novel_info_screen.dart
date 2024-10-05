import 'dart:ui';
import 'package:audiobook/commponent/loading_shimmer/pharagraph_loading_shimmer.dart';
import 'package:audiobook/commponent/rating/star_rating.dart';
import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/model/novel_detail.dart';
import 'package:audiobook/utils/enum_constants.dart';
import 'package:audiobook/utils/size_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'cubit/novel_info_cubit.dart';

class NovelInfoScreen extends StatefulWidget {
  const NovelInfoScreen({
    super.key,
    required this.novelData,
    this.onTapBack,
    this.onTapListChapter,
    this.novelDataResponse,
    this.oldNovelData,
    this.onHandle,
  });

  final Novel novelData;
  final Function()? onTapBack;
  final Function(List<Chapter>? chapterList)? onTapListChapter;
  final Function(NovelDetail? novelData)? novelDataResponse;
  final NovelDetail? oldNovelData;
  final Function(NovelHandle? novelHandle)? onHandle;

  @override
  State<NovelInfoScreen> createState() => _NovelInfoScreenState();
}

class _NovelInfoScreenState extends State<NovelInfoScreen> {
  late List<NovelDetail> novelDataList = [];
  late NovelDetail novelData = NovelDetail();
  bool showDescription = false;
  bool showChapterList = false;
  LoadState loadState = LoadState.none;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.novelData.title == widget.oldNovelData?.title) {
        setState(() {
          loadState = LoadState.loadSuccess;
        });
        novelData = widget.oldNovelData ?? NovelDetail();
      } else {
        setState(() {
          loadState = LoadState.none;
        });
        Get.find<NovelInfoCubit>().getNovelInfo(
            href: widget.novelData.href
                    ?.replaceAll('/v1/truyen/', '/v1/novel/') ??
                '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Scaffold _buildBody(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildImageBackgound(),
          _buildBlurBackgound(),
          _buildImageBlur(),
          _buildContents(context),
        ],
      ),
    );
  }

  Scrollbar _buildContents(BuildContext context) {
    return Scrollbar(
        child: CustomScrollView(
      primary: true,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        _buildHeader(),
        _buildImageBanner(context),
        _buildHandleButton(),
        _buildViewAndRatingStar(),
        _buildDescription(),
        _buildChapterList(chapterList: novelData.chapterLatest),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
        SliverToBoxAdapter(child: _buildListener())
      ],
    ));
  }

  SliverToBoxAdapter _buildHandleButton() {
    return SliverToBoxAdapter(
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (loadState != LoadState.loading) {
                widget.onTapListChapter?.call(novelData.chapterList);
                widget.onHandle?.call(NovelHandle.audio);
              }
            },
            child: Container(
              width: sizeSystem(context).width * 0.25,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.black,
                  border: Border.all(width: 3, color: Colors.blue)),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.headphones,
                      color: Colors.white,
                    ),
                    Text(
                      'Audio',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: sizeSystem(context).width * 0.25,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: Colors.black,
                border: Border.all(width: 3, color: Colors.blue)),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Đọc từ đầu',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: sizeSystem(context).width * 0.25,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: Colors.black,
                border: Border.all(width: 3, color: Colors.blue)),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Đọc tiếp',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Center _buildImageBlur() {
    return Center(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            width: sizeSystem(context).width,
            height: sizeSystem(context).height,
            decoration:
                BoxDecoration(color: Colors.grey.shade200.withOpacity(0.4)),
          ),
        ),
      ),
    );
  }

  ConstrainedBox _buildBlurBackgound() {
    return ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Container(
          height: sizeSystem(context).height,
          width: sizeSystem(context).width,
          color: Colors.black.withOpacity(0.6),
        ));
  }

  ConstrainedBox _buildImageBackgound() {
    return ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Image.network(
          widget.novelData.image ?? '',
          fit: BoxFit.cover,
        ));
  }

  SliverAppBar _buildHeader() {
    return SliverAppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.blue,
      leading: InkWell(
        onTap: () {
          widget.onTapBack?.call();
        },
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.blue,
        ),
      ),

      elevation: 0,
      floating: true,
      pinned: false,
      snap: true,
      toolbarHeight: 50, // Đặt độ cao mong muốn cho thanh AppBar
    );
  }

  SliverToBoxAdapter _buildChapterList(
      {String? title, List<Chapter>? chapterList}) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (title != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showChapterList = false;
                      });
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                Text(
                  title ?? 'Chương mới',
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            if (loadState == LoadState.loading)
              const PharagraphLoadingShimmer(itemCount: 1),
            if (chapterList != null)
              ...chapterList
                  .map((e) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (e.chapterTitle ?? '')
                                      .replaceAll(e.chapterTime ?? '', ''),
                                  maxLines: 3,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              e.chapterTime ?? '',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic),
                            ),
                          )
                        ],
                      ))
                  .toList()
                  .reversed,
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            AnimatedCrossFade(
              duration:
                  const Duration(milliseconds: 300), // Thời gian animation
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  loadState == LoadState.loading
                      ? Text(
                          widget.novelData.description != null
                              ? widget.novelData.description![0]
                              : '',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.justify,
                        )
                      : Text(
                          novelData.description != null
                              ? novelData.description![0]
                              : '',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.justify,
                        ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          showDescription = !showDescription;
                        });
                      },
                      child: const Text(
                        'Xem thêm',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (novelData.description != null)
                      ...novelData.description!.map((e) {
                        return Text(
                          e,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.justify,
                        );
                      }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            showDescription = !showDescription;
                          });
                        },
                        child: const Text(
                          'Ẩn bớt',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                  ]),
              crossFadeState: showDescription
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
            Wrap(
              children: [
                ...(novelData.genres ?? []).map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        e,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  );
                }),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Danh sách chương',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (loadState != LoadState.loading) {
                        widget.onTapListChapter?.call(novelData.chapterList);
                        widget.onHandle?.call(NovelHandle.read);
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                          loadState == LoadState.loading
                              ? 'Loading...'
                              : '${novelData.chapterList?.length} chương',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 16),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Colors.blue,
                          size: 20,
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildViewAndRatingStar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.black87, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                loadState == LoadState.loading
                    ? const Text(
                        'Loading...',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                    : Text(
                        novelData.views ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                const SizedBox(height: 8),
                const Text(
                  'Lượt xem',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    loadState == LoadState.loading
                        ? const Text(
                            'Loading.../5',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )
                        : Text(
                            '${novelData.rating ?? ''}/5',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                    const SizedBox(width: 8),
                    if (loadState != LoadState.loading)
                      Text(
                        '(${novelData.ratingCount})',
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      )
                  ],
                ),
                const SizedBox(height: 8),
                StarRating(
                  color: const Color.fromRGBO(255, 193, 7, 1),
                  rating: double.parse(novelData.rating ?? '0.0'),
                  onRatingChanged: (double rating) {},
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildImageBanner(BuildContext context) {
    return SliverToBoxAdapter(
        child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.novelData.image != ''
                  ? Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: MediaQuery.of(context).size.height * 0.175,
                      decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black,
                                offset: Offset(1, 1),
                                blurRadius: 5,
                                spreadRadius: 1)
                          ],
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              alignment: Alignment.centerLeft,
                              image: NetworkImage(widget.novelData.image ?? ''),
                              fit: BoxFit.cover)),
                    )
                  : const SizedBox(),
              const SizedBox(
                width: 16,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.novelData.title ?? '',
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.novelData.author ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(child: Container()),
                    Wrap(
                      children: [
                        Chip(label: Text(widget.novelData.genre ?? '')),
                        const SizedBox(width: 8),
                        if (loadState != LoadState.loading)
                          Chip(label: Text(novelData.status ?? '')),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    ));
  }

  Widget _buildListener() {
    return BlocListener(
      bloc: Get.find<NovelInfoCubit>(),
      listener: (context, state) async {
        if (state is GetNovelInfoInProgress &&
            loadState != LoadState.loadBackGround) {
          setState(() {
            loadState = LoadState.loading;
          });
          return;
        }

        if (state is GetNovelInfoFailure) {
          setState(() {
            loadState = LoadState.loadFailure;
          });
          return;
        }

        if (state is GetNovelInfoSuccess) {
          setState(() {
            loadState = LoadState.loadSuccess;
            novelData = state.response;
            novelData.image = widget.novelData.image;
            novelData.href =
                widget.novelData.href?.replaceAll('truyen', 'novel') ?? '';

            widget.novelDataResponse?.call(novelData);
          });
          if (novelData.chapterList?.length.toString() !=
              widget.novelData.chapters?.replaceAll(' chương', '')) {
            setState(() {
              loadState = LoadState.loadBackGround;
            });
          }

          Get.find<NovelInfoCubit>().saveNovelToLocalData(novelData: novelData);
        }
      },
      child: Container(),
    );
  }
}
