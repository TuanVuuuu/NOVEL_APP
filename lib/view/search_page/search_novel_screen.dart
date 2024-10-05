import 'package:audiobook/view/widget/item_novel_widget.dart';
import 'package:audiobook/commponent/loading_shimmer/vertical_item_novel_loading_shimmer.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/utils/enum_constants.dart';
import 'package:audiobook/view/search_page/cubit/search_page_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../commponent/flutter_spinkit/src/circle.dart';

class SearchNovelScreen extends StatefulWidget {
  const SearchNovelScreen({
    super.key,
    required this.onTapNovel,
  });

  final Function(Novel novel)? onTapNovel;

  @override
  State<SearchNovelScreen> createState() => _SearchNovelScreenState();
}

class _SearchNovelScreenState extends State<SearchNovelScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _refreshController = RefreshController();
  bool _showClearButton = false;
  LoadState loadState = LoadState.none;
  List<Novel> searchResult = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _showClearButton = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchHeader(),
            _buildSearchResult(),
            _buildListener(),
          ],
        ),
      ),
    );
  }

  Expanded _buildSearchResult() {
    return Expanded(
      child: Scrollbar(
        child: SmartRefresher(
          controller: _refreshController,
          header: CustomHeader(
            builder: (context, mode) {
              return const SizedBox(
                height: 60,
                child: Center(
                    child: SpinKitCircle(color: Colors.black45, size: 30)),
              );
            },
          ),
          child: _buildContent(),
          onRefresh: () async {
            Get.find<SearchPageCubit>()
                .searchNovelByTitle(title: _searchController.text);
          },
        ),
      ),
    );
  }

  Padding _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black),
              ),
              child: Center(
                child: TextField(
                  controller: _searchController,
                  cursorColor: Colors.black,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Nhập tên truyện...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    suffixIcon: _showClearButton
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            icon: const Icon(Icons.clear, color: Colors.black),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Get.find<SearchPageCubit>().searchNovelByTitle(
                  title: _searchController.text.replaceAll(' ', '-'));
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.search, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListener() {
    return BlocListener(
      bloc: Get.find<SearchPageCubit>(),
      listener: (context, state) {
        if (state is SearchNovelInProgress) {
          setState(() {
            loadState = LoadState.loading;
          });
          return;
        }

        if (state is SearchNovelFailure) {
          setState(() {
            loadState = LoadState.loadFailure;
          });
          return;
        }

        if (state is SearchNovelSuccess) {
          setState(() {
            loadState = LoadState.loadSuccess;
            searchResult = state.response;
          });
        }
      },
      child: Container(),
    );
  }

  Widget _buildContent() {
    _refreshController.refreshCompleted();
    return CustomScrollView(
      slivers: [
        SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return GestureDetector(
                  onTap: () {
                    widget.onTapNovel?.call(searchResult[index]);
                  },
                  child: loadState == LoadState.loading
                      ? const VerticalItemNovelLoadingShimmer()
                      : ItemNovelWidget(
                          novelTrendList: searchResult, index: index));
            },
            childCount:
                loadState == LoadState.loading ? 5 : searchResult.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1 / 1.9,
          ),
        ),
      ],
    );
  }
}
