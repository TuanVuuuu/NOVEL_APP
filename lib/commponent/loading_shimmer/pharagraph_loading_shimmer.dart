import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PharagraphLoadingShimmer extends StatelessWidget {
  const PharagraphLoadingShimmer({
    Key? key,
    this.padding = const EdgeInsets.all(10.0),
    this.itemCount = 20,
    this.color,
  }) : super(key: key);

  final EdgeInsets padding;
  final int itemCount;
  final Color? color;
  Color get _color => color ?? Colors.white.withOpacity(0.8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: itemCount,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: double.infinity, height: 8.0, color: _color),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0)),
                      Container(
                          width: double.infinity, height: 8.0, color: _color),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0)),
                      Container(width: 40.0, height: 8.0, color: _color),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
