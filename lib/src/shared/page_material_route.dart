import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageMaterialRoute extends GetPageRoute {
  PageMaterialRoute(
      {required RouteSettings settings,
      required Widget Function()? page,
      List<Bindings>? bindings,
      bool maintainState = true,
      bool fullscreenDialog = false,
      dynamic popGesture = true,
      Curve? curve = Curves.ease,
      Transition? transition = Transition.rightToLeft,
      Bindings? binding,
      Duration transitionDuration = const Duration(milliseconds: 300)})
      : super(
            settings: settings,
            maintainState: maintainState,
            fullscreenDialog: fullscreenDialog,
            page: page,
            popGesture: popGesture,
            bindings: bindings,
            curve: curve,
            transition: transition,
            binding: binding,
            transitionDuration: transitionDuration);
  @override
  @protected
  bool get hasScopedWillPopCallback {
    return false;
  }
}
