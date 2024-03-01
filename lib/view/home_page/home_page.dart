import 'dart:convert';

import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:audiobook/commponent/item_novel_widget.dart';
import 'package:audiobook/commponent/vertical_item_novel_loading_shimmer.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/src/shared/app_route.dart';
import 'package:audiobook/utils/view_extensions.dart';
import 'package:audiobook/view/home_page/cubit/home_page_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Novel> novelDataList = [];
  late List<Novel> novelTrendList = [];
  LoadState loadState = LoadState.none;

  @override
  void initState() {
    super.initState();
    loadNovelData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<HomePageCubit>().getListNovel();
    });
  }

  Future<void> loadNovelData() async {
    String jsonString = await rootBundle.loadString('assets/novel_hot.json');
    setState(() {
      final jsonData = json.decode(jsonString)['data'];
      novelDataList =
          jsonData.map<Novel>((item) => Novel.fromJson(item)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scrollbar(
      child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _buildRecommendNovel(context),
            _buildTopNovelList(context),
            SliverToBoxAdapter(
              child: _buildListener(),
            )
          ]),
    ));
  }

  SliverToBoxAdapter _buildRecommendNovel(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          novelDataList.length >= 4
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  height: 250,
                  width: double.infinity,
                  child: AnotherCarousel(
                    dotBgColor: Colors.transparent,
                    dotIncreasedColor: Colors.blue,
                    overlayShadowColors: Colors.transparent,
                    boxFit: BoxFit.fitHeight,
                    borderRadius: true,
                    animationDuration: const Duration(milliseconds: 1000),
                    autoplayDuration: const Duration(milliseconds: 5000),
                    images: const [
                      NetworkImage(
                          'https://cdn.sforum.vn/sforum/wp-content/uploads/2024/02/truyen-dam-my-co-trang-1.jpg'),
                      NetworkImage(
                          'https://cdn.sforum.vn/sforum/wp-content/uploads/2024/02/truyen-dam-my-co-trang-10-1.jpg'),
                      NetworkImage(
                          'https://cdn.sforum.vn/sforum/wp-content/uploads/2024/02/truyen-dam-my-co-trang-11-1.jpg'),
                      NetworkImage(
                          'https://cdn.popsww.com/blog/sites/2/2021/03/vuong-gia-3-tuoi-ruoi.jpg'),
                    ],
                    dotSize: 6,
                    indicatorBgPadding: 5.0,
                  ),
                )
              : const SizedBox(),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Đề cử',
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: novelTrendList.isEmpty
                ? const VerticalItemNovelLoadingShimmer(
                    itemCount: 5,
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: novelTrendList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoute.novelinfo.name,
                              arguments: [novelTrendList[index]]);
                        },
                        child: ItemNovelWidget(
                            novelTrendList: novelTrendList, index: index),
                      );
                    },
                  ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Top truyện',
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildTopNovelList(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, indexColumn) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: 3,
                itemBuilder: (context, index) {
                  int novelIndex = indexColumn * 3 + index;
                  return novelDataList.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          width: MediaQuery.of(context).size.width * 0.75,
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height:
                                    MediaQuery.of(context).size.height * 0.175,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                        alignment: Alignment.centerLeft,
                                        image: NetworkImage(
                                            novelDataList[novelIndex].image ??
                                                ''),
                                        fit: BoxFit.cover)),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: novelIndex > 5
                                              ? Colors.blue
                                              : novelIndex > 2
                                                  ? Colors.purple
                                                  : Colors.red,
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          (novelIndex + 1).toString(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      )),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      novelDataList[novelIndex].title ?? '',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      novelDataList[novelIndex].author ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w300),
                                    ),
                                    Expanded(child: Container()),
                                    Chip(
                                        label: Text(
                                            novelDataList[novelIndex].genre ??
                                                ''))
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      : const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildListener() {
    return BlocListener(
      bloc: Get.find<HomePageCubit>(),
      listener: (context, state) {
        if (state is GetListNovelInProgress) {
          setState(() {
            loadState = LoadState.loading;
          });
          return;
        }

        if (state is GetListNovelFailure) {
          setState(() {
            loadState = LoadState.loadFailure;
          });
          return;
        }

        if (state is GetListNovelSuccess) {
          setState(() {
            loadState = LoadState.loadSuccess;
            novelTrendList = state.response;
          });
        }
      },
      child: Container(),
    );
  }
}
