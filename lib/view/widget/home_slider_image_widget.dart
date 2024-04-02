import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/material.dart';

class HomeSliderImage extends StatelessWidget {
  const HomeSliderImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 250,
      width: double.infinity,
      child: AnotherCarousel(
        dotBgColor: Colors.transparent,
        dotIncreasedColor: Colors.blue,
        overlayShadowColors: Colors.transparent,
        boxFit: BoxFit.fitHeight,
        borderRadius: true,
        animationDuration: const Duration(milliseconds: 1000),
        autoplayDuration: const Duration(milliseconds: 5000),
        images: const [
          NetworkImage(
              'https://cdn.sforum.vn/sforum/wp-content/uploads/2024/02/truyen-dam-my-co-trang-1.jpg'),
          NetworkImage(
              'https://cdn.sforum.vn/sforum/wp-content/uploads/2024/02/truyen-dam-my-co-trang-10-1.jpg'),
          NetworkImage(
              'https://cdn.sforum.vn/sforum/wp-content/uploads/2024/02/truyen-dam-my-co-trang-11-1.jpg'),
          NetworkImage(
              'https://cdn.popsww.com/blog/sites/2/2021/03/vuong-gia-3-tuoi-ruoi.jpg'),
        ],
        dotSize: 6,
        indicatorBgPadding: 5.0,
      ),
    );
  }
}
