import 'package:audiobook/model/novel.dart';
import 'package:flutter/material.dart';

class ItemNovelWidget extends StatelessWidget {
  const ItemNovelWidget({
    super.key,
    required this.novelTrendList,
    required this.index,
    this.onTap,
  });

  final List<Novel> novelTrendList;
  final int index;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 0.3,
        child: Column(children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.175,
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(novelTrendList[index].image ?? ''),
                  fit: BoxFit.cover,
                )),
          ),
          const SizedBox(height: 8),
          Text(
            novelTrendList[index].title ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ]),
      ),
    );
  }
}
