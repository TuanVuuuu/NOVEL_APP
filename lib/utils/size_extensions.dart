// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

Size getSizeSystem() {
  return WidgetsBinding.instance.window.physicalSize;
}

Size sizeSystem(BuildContext context) {
  return MediaQuery.of(context).size;
}
