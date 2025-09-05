import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/style/k_color.dart';

class MainSliderBuilder extends StatefulWidget {
  final List<Widget> imgList;

  MainSliderBuilder(
      {super.key,
      required this.imgList,
      this.isReverse,
      this.height,
      this.isAutoPlay,
      this.isIndecator,
      this.enlargeCenterPage});

  final bool? isReverse;
  final bool? enlargeCenterPage;
  final double? height;

  bool? isAutoPlay;
  final bool? isIndecator;

  @override
  _MainSliderBuilderState createState() => _MainSliderBuilderState();
}

class _MainSliderBuilderState extends State<MainSliderBuilder> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          items: widget.imgList,
          options: CarouselOptions(
            height:
                widget.height ?? MediaQuery.of(context).size.height * 0.30.h,
            autoPlay: widget.isAutoPlay ?? false,
            enlargeCenterPage: widget.enlargeCenterPage ?? true,
            animateToClosest: true,
            aspectRatio: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        widget.isIndecator == true
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.imgList.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => CarouselSlider.builder(
                        itemCount: widget.imgList.length,
                        itemBuilder: (context, itemIndex, pageViewIndex) =>
                            widget.imgList[itemIndex],
                        options: CarouselOptions(
                            reverse: widget.isReverse ?? false,
                            autoPlay: widget.isAutoPlay ?? false,
                            enlargeCenterPage: true,
                            aspectRatio: 1.0,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _current = index;
                              });
                            })),
                    child: Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == entry.key
                            ? KColors.primaryColor
                            : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              )
            : const SizedBox(),
      ],
    );
  }
}
