import 'package:audiobook/utils/size_extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ItemHorizionalNovelLoadingShimmer extends StatelessWidget {
  const ItemHorizionalNovelLoadingShimmer({
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
          child: Container(
            padding: const EdgeInsets.all(8),
            width: sizeSystem(context).width * 0.75,
            height: sizeSystem(context).height * 0.2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: sizeSystem(context).width * 0.25,
                  height: sizeSystem(context).height * 0.175,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8), color: _color),
                ),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: sizeSystem(context).width * 0.25,
                  height: sizeSystem(context).height * 0.175,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                          width: sizeSystem(context).width * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _color,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 10,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _color,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 10,
                          width: sizeSystem(context).width * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _color,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        Container(
                          height: 30,
                          width: sizeSystem(context).width * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _color,
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          )),
    );
  }
}
