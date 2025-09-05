import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_text_widget.dart';
import 'image_widget.dart';

class CardItemBuilderWidget extends StatelessWidget {
  const CardItemBuilderWidget(
      {super.key,
      required this.cardImgUrl,
      required this.cardTitle,
      this.textAlign});

  final String cardImgUrl;
  final String cardTitle;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
      child: Card(
        elevation: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            KImageWidget(
                // height: MediaQuery.of(context).size.height * 0.160.h,
                imageUrl:
                    // '${bloc.subjectsModel?.data?.data?[index].image}',
                    cardImgUrl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 5),
              child: TextWidget(
                title: cardTitle,
                textAlign: textAlign,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
