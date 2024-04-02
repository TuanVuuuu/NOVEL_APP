import 'package:audiobook/model/chapter.dart';
import 'package:audiobook/view/search_page/cubit/search_page_cubit.dart';
import 'package:audiobook/view/tabbar/tab_bar_manager.dart';
import 'package:audiobook/src/shared/page_material_route.dart';
import 'package:audiobook/view/chapter_detail/chapter_detail_screen.dart';
import 'package:audiobook/view/chapter_detail/cubit/chapter_detail_cubit.dart';
import 'package:audiobook/view/home_page/cubit/home_page_cubit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppRoute {
  tabbarmanager,
  chapterdetail,
}

extension AppRouteExt on AppRoute {
  String get name {
    switch (this) {
      case AppRoute.tabbarmanager:
        return '/tabbarmanager';
      case AppRoute.chapterdetail:
        return '/chapterdetail';
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
            bindings: [
              BindingsBuilder.put(() => HomePageCubit(Get.find())),
              BindingsBuilder.put(() => SearchPageCubit(Get.find())),
            ],
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

      default:
        return GetPageRoute(
          settings: settings,
          curve: Curves.ease,
          transition: Transition.rightToLeft,
          page: () => const TabBarManager(),
        );
    }
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static Route<dynamic> bindingRoute(RouteSettings settings) {
    return AppRouteExt.generateRoute(settings);
  }
}
