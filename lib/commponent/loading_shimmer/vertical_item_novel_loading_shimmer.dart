import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VerticalItemNovelLoadingShimmer extends StatelessWidget {
  const VerticalItemNovelLoadingShimmer({
    super.key,
    this.padding = const EdgeInsets.all(10.0),
    this.itemCount = 20,
    this.color,
  });

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
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: itemCount,
          itemBuilder: (_, __) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.175,
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8), color: _color),
                ),
                const SizedBox(height: 8),
                Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 8.0,
                    color: _color),
                const SizedBox(height: 8),
                Container(width: 40, height: 8.0, color: _color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
