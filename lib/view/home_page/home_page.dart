import 'package:audiobook/commponent/flutter_spinkit/src/circle.dart';
import 'package:audiobook/view/widget/item_novel_widget.dart';
import 'package:audiobook/commponent/loading_shimmer/loading_horizional_item_novel.dart';
import 'package:audiobook/commponent/loading_shimmer/vertical_item_novel_loading_shimmer.dart';
import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/model/novel_detail.dart';
import 'package:audiobook/utils/enum_constants.dart';
import 'package:audiobook/utils/size_extensions.dart';
import 'package:audiobook/view/chapter_list/chapter_list_screen.dart';
import 'package:audiobook/view/home_page/cubit/home_page_cubit.dart';
import 'package:audiobook/view/novel_info/novel_info_screen.dart';
import 'package:audiobook/view/search_page/search_novel_screen.dart';
import 'package:audiobook/view/widget/home_slider_image_widget.dart';
import 'package:audiobook/view/widget/label_widget.dart';
import 'package:audiobook/view/widget/novel_item_horizional_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.pageCurrent,
    this.setCurrentPage,
    this.audioState,
    this.onTapNovel,
  });

  final Function(PageCurrent page)? pageCurrent;
  final PageCurrent? setCurrentPage;
  final Function(
    AudioStyle audioStyle,
    Chapter chapter,
    List<Chapter>? chapterList,
    int? index,
  )? audioState;
  final Function(Novel novel)? onTapNovel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Novel> novelTopList = [];
  late List<Novel> novelTrendList = [];
  LoadState loadState = LoadState.none;
  final _refreshController = RefreshController();
  PageCurrent pageCurrent = PageCurrent.dashboard;
  Novel novelCurrent = Novel();
  List<Chapter>? chapterList = [];
  NovelDetail? novelDataResponse = NovelDetail();
  NovelHandle? novelHandle = NovelHandle.read;
  AudioStyle audioStyle = AudioStyle.none;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.pageCurrent?.call(PageCurrent.dashboard);
      Get.find<HomePageCubit>().getListNovel();
      Get.find<HomePageCubit>().getListTopNovel();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildBody(),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  Widget _buildBody() {
    switch (widget.setCurrentPage) {
      case PageCurrent.search:
        return SearchNovelScreen(
          onTapNovel: (novel) {
            setState(() {
              novelCurrent = novel;
              pageCurrent = PageCurrent.novel;
              widget.pageCurrent?.call(pageCurrent);
            });
          },
        );
      case PageCurrent.dashboard:
        return _buildDashBoard(context);
      case PageCurrent.novel:
        return NovelInfoScreen(
          novelData: novelCurrent,
          onTapBack: () {
            setState(() {
              pageCurrent = PageCurrent.dashboard;
              widget.pageCurrent?.call(pageCurrent);
            });
          },
          onTapListChapter: (value) {
            setState(() {
              pageCurrent = PageCurrent.chapterlist;
              widget.pageCurrent?.call(pageCurrent);
              chapterList = value;
            });
          },
          novelDataResponse: (novelData) {
            setState(() {
              novelDataResponse = novelData;
            });
          },
          oldNovelData: novelDataResponse,
          onHandle: (handle) {
            setState(() {
              novelHandle = handle;
            });
          },
        );
      case PageCurrent.chapterlist:
        return ChapterListScreen(
          novelData: novelCurrent,
          chapterList: chapterList,
          handle: novelHandle,
          onTapBack: () {
            setState(() {
              pageCurrent = PageCurrent.novel;
              widget.pageCurrent?.call(pageCurrent);
            });
          },
          onTapHandle: (chapter, chapterList, index) {
            setState(() {
              audioStyle = AudioStyle.player;
              widget.audioState?.call(audioStyle, chapter, chapterList, index);
            });
          },
        );
      default:
        return _buildDashBoard(context);
    }
  }

  Scaffold _buildDashBoard(BuildContext context) {
    return Scaffold(
        body: Scrollbar(
      child: SmartRefresher(
        controller: _refreshController,
        header: _buildHeader(),
        onRefresh: () async {
          Get.find<HomePageCubit>().getListNovel();
          Get.find<HomePageCubit>().getListTopNovel();
        },
        child: _buildContent(context),
      ),
    ));
  }

  CustomHeader _buildHeader() {
    return CustomHeader(
      builder: (context, mode) {
        return const SizedBox(
          height: 60,
          child: Center(child: SpinKitCircle(color: Colors.black45, size: 30)),
        );
      },
    );
  }

  CustomScrollView _buildContent(BuildContext context) {
    _refreshController.refreshCompleted();
    return CustomScrollView(
        controller: ScrollController(),
        primary: false,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          _buildRecommendNovel(context),
          _buildTopNovelList(context),
          _buildListener()
        ]);
  }

  SliverToBoxAdapter _buildRecommendNovel(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const HomeSliderImage(),
          const SizedBox(height: 8),
          const LabelWidget(label: 'Đề cử'),
          SizedBox(
            height: sizeSystem(context).height * 0.25,
            child: novelTrendList.isEmpty
                ? const VerticalItemNovelLoadingShimmer(itemCount: 5)
                : ListView.builder(
                    controller: ScrollController(),
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    itemCount: novelTrendList.length,
                    itemBuilder: (context, index) {
                      return ItemNovelWidget(
                        novelTrendList: novelTrendList,
                        index: index,
                        onTap: () {
                          setState(() {
                            novelCurrent = novelTrendList[index];
                            pageCurrent = PageCurrent.novel;
                            widget.pageCurrent?.call(pageCurrent);
                            widget.onTapNovel?.call(novelCurrent);
                          });
                        },
                      );
                    },
                  ),
          ),
          const LabelWidget(label: 'Top truyện'),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildTopNovelList(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: ListView.builder(
          primary: false,
          controller: ScrollController(),
          scrollDirection: Axis.horizontal,
          itemCount: 4, // Số cột
          itemBuilder: (context, indexColumn) {
            // Tính toán chỉ số của cuốn sách trong danh sách
            int startIndex = indexColumn * 3;
            int endIndex = startIndex + 3;
            if (endIndex > 9) {
              endIndex = 10;
            }

            // Trả về một hàng ngang chứa ba cuốn sách
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                primary: false,
                controller: ScrollController(),
                scrollDirection: Axis.vertical,
                itemCount: endIndex - startIndex,
                itemBuilder: (context, index) {
                  int novelIndex = startIndex + index;
                  // Kiểm tra xem danh sách có phần tử không trước khi truy cập
                  if (novelIndex >= 0 && novelIndex < novelTopList.length) {
                    return InkWell(
                        onTap: () {
                          setState(() {
                            novelCurrent = novelTopList[index];
                            pageCurrent = PageCurrent.novel;
                            widget.pageCurrent?.call(pageCurrent);
                            widget.onTapNovel?.call(novelCurrent);
                          });
                        },
                        child: _buildItemTopNovel(context, novelIndex));
                  } else {
                    return const ItemHorizionalNovelLoadingShimmer();
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItemTopNovel(BuildContext context, int novelIndex) {
    return NovelItemHorizionalWidget(
      novelTopList: novelTopList,
      novelIndex: novelIndex,
    );
  }

  Widget _buildListener() {
    return SliverToBoxAdapter(
      child: BlocListener(
        bloc: Get.find<HomePageCubit>(),
        listener: (context, state) {
          if (state is GetListNovelInProgress) {
            setState(() {
              loadState = LoadState.loading;
            });
            return;
          }

          if (state is GetListTopNovelInProgress) {
            setState(() {
              loadState = LoadState.loadingSeconds;
            });
            return;
          }

          if (state is GetListNovelFailure) {
            setState(() {
              loadState = LoadState.loadFailure;
            });
            return;
          }

          if (state is GetListTopNovelFailure) {
            setState(() {
              loadState = LoadState.loadSecondsFailure;
            });
          }

          if (state is GetListNovelSuccess) {
            setState(() {
              loadState = LoadState.loadSuccess;
              novelTrendList = state.response;
            });
          }

          if (state is GetListTopNovelSuccess) {
            setState(() {
              loadState = LoadState.loadSecondsSuccess;
              novelTopList = state.response;
            });
          }
        },
        child: Container(),
      ),
    );
  }
}
