import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageMaterialRoute extends GetPageRoute {
  PageMaterialRoute(
      {required RouteSettings super.settings,
      required super.page,
      super.bindings,
      super.maintainState,
      super.fullscreenDialog,
      dynamic popGesture = true,
      super.curve = Curves.ease,
      super.transition = Transition.rightToLeft,
      super.binding,
      super.transitionDuration})
      : super(
            popGesture: popGesture);
  @override
  @protected
  bool get hasScopedWillPopCallback {
    return false;
  }
}
