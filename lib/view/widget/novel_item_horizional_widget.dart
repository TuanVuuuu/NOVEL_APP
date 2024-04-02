import 'package:audiobook/model/novel.dart';
import 'package:flutter/material.dart';

class NovelItemHorizionalWidget extends StatelessWidget {
  const NovelItemHorizionalWidget({
    super.key,
    required this.novelTopList,
    required this.novelIndex,
  });

  final List<Novel> novelTopList;
  final int novelIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            height: MediaQuery.of(context).size.height * 0.175,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                alignment: Alignment.centerLeft,
                image: NetworkImage(
                  novelTopList[novelIndex].image ?? '',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: novelIndex > 5
                      ? novelIndex > 8
                          ? Colors.green
                          : Colors.blue
                      : novelIndex > 2
                          ? Colors.purple
                          : Colors.red,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    (novelIndex + 1).toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  novelTopList[novelIndex].title ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  novelTopList[novelIndex].author ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Expanded(child: Container()),
                Chip(
                  label: Text(
                    novelTopList[novelIndex].genre ?? '',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
