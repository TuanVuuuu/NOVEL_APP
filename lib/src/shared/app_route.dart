import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/model/novel.dart';
import 'package:audiobook/view/search_page/cubit/search_page_cubit.dart';
import 'package:audiobook/view/search_page/search_novel_screen.dart';
import 'package:audiobook/view/tabbar/tab_bar_manager.dart';
import 'package:audiobook/src/shared/page_material_route.dart';
import 'package:audiobook/view/chapter_detail/chapter_detail_screen.dart';
import 'package:audiobook/view/chapter_detail/cubit/chapter_detail_cubit.dart';
import 'package:audiobook/view/home_page/cubit/home_page_cubit.dart';
import 'package:audiobook/view/home_page/home_page.dart';
import 'package:audiobook/view/novel_info/cubit/novel_info_cubit.dart';
import 'package:audiobook/view/novel_info/novel_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppRoute { tabbarmanager, chapterdetail, homepage, novelinfo, searchnovel }

extension AppRouteExt on AppRoute {
  String get name {
    switch (this) {
      case AppRoute.tabbarmanager:
        return '/tabbarmanager';
      case AppRoute.chapterdetail:
        return '/chapterdetail';
      case AppRoute.homepage:
        return '/homepage';
      case AppRoute.novelinfo:
        return '/novelinfo';
      case AppRoute.searchnovel:
        return '/searchnovel';
    }
  }

  static AppRoute? from(String? name) {
    for (final item in AppRoute.values) {
      if (item.name == name) {
        return item;
      }
    }
    return null;
  }

  static Route generateRoute(RouteSettings settings) {
    switch (AppRouteExt.from(settings.name)) {
      case AppRoute.tabbarmanager:
        return PageMaterialRoute(
            settings: settings,
            page: () => const TabBarManager(),
            bindings: [BindingsBuilder.put(() => HomePageCubit(Get.find()))],
            transition: Transition.fade);

      case AppRoute.chapterdetail:
        final dynamic argument = settings.arguments;
        final Chapter chapter = argument[0];
        final List<Chapter> listChapterArg = argument[1];
        final int chapterIndex = argument[2];
        return PageMaterialRoute(
            settings: settings,
            page: () => ChapterScreen(
                chapterArg: chapter,
                listChapterArg: listChapterArg,
                chapterIndex: chapterIndex),
            bindings: [
              BindingsBuilder.put(() => ChapterDetailCubit(Get.find())),
            ],
            transition: Transition.rightToLeft);

      case AppRoute.homepage:
        return PageMaterialRoute(
            settings: settings,
            page: () => const HomePage(),
            bindings: [
              BindingsBuilder.put(() => HomePageCubit(Get.find())),
            ],
            transition: Transition.rightToLeft);

      case AppRoute.novelinfo:
        final dynamic argument = settings.arguments;
        final Novel novelData = argument[0];
        return PageMaterialRoute(
            settings: settings,
            page: () => NovelInfoScreen(novelData: novelData),
            bindings: [
              BindingsBuilder.put(() => NovelInfoCubit(Get.find())),
            ],
            transition: Transition.rightToLeft);

      case AppRoute.searchnovel:
        return PageMaterialRoute(
            settings: settings,
            page: () => const SearchNovelScreen(),
            bindings: [
              BindingsBuilder.put(() => SearchPageCubit(Get.find())),
            ],
            transition: Transition.rightToLeft);

      default:
        return GetPageRoute(
            settings: settings,
            curve: Curves.ease,
            transition: Transition.rightToLeft
            // page: () => EmptyScreen(desc: 'No route defined for ${settings.name}'),
            );
    }
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static Route<dynamic> bindingRoute(RouteSettings settings) {
    return AppRouteExt.generateRoute(settings);
  }
}
