/*
 * File: linear_progress.dart
 * File Created: Thursday, 1st July 2021 6:30:12 pm
 * Author: Hieu Tran
 * -----
 * Last Modified: Thursday, 1st July 2021 6:39:04 pm
 * Modified By: Hieu Tran
 */

import 'package:flutter/material.dart';

import 'tweens/delay_tween.dart';

class SpinKitLinearProgress extends StatefulWidget {
  const SpinKitLinearProgress({
    super.key,
    required this.color,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  });

  final Color? color;
  final Duration duration;
  final AnimationController? controller;

  @override
  State<SpinKitLinearProgress> createState() => _SpinKitLinearProgressState();
}

class _SpinKitLinearProgressState extends State<SpinKitLinearProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ??
        AnimationController(vsync: this, duration: widget.duration))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(10, (index) {
        return ScaleTransition(
          scale:
              DelayTween(begin: 0.0, end: 1.0, delay: 0).animate(_controller),
          child: const Divider(
            height: 1,
            thickness: 1,
            color: Colors.blue,
          ),
        );
      }),
    );
  }
}
