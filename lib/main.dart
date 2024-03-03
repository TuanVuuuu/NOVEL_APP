import 'dart:io';
import 'package:audiobook/model/hive/chapter_item.dart';
import 'package:audiobook/view/tabbar/tab_bar_manager.dart';
import 'package:audiobook/src/shared/app_route.dart';
import 'package:audiobook/src/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/route_manager.dart';
import 'src/data/core/api_helper.dart';
import 'src/data/service/setup_service_locator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'src/shared/hive/setup_locator.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  /// Setup Hive
  await Hive.initFlutter((await getApplicationDocumentsDirectory()).path);
  Hive.registerAdapter(ChapterItemAdapter());

  /// Setup DI
  setupLocator();
  runApp(const AudioBooksApp());
}



class AudioBooksApp extends StatelessWidget {
  const AudioBooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    setupServiceLocator();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aza Novel',
      navigatorKey: AppRouteExt.navigatorKey,
      key: key,
      theme: CustomTheme.fromContext(context).appTheme,
      navigatorObservers: <NavigatorObserver>[routeObserver],
      routes: {
        '/': (context) => const TabBarManager(),
      },
      onGenerateRoute: AppRouteExt.bindingRoute,
      initialBinding: AppBinding(),
    );
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    injectService();
  }

  void injectService() {}
}
