import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/utils/style/responsive_util.dart';

class HadithTranslate extends StatelessWidget {
  final String otherLangHadithText;
  HadithTranslate({super.key, required this.otherLangHadithText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Gap(8),
        Container(
           padding: const EdgeInsets.symmetric(horizontal: 8),
           child: Text(
              'hadithTranslate'.tr, // Ensure key exists or use fallback
              style: TextStyle(
                 fontFamily: 'naskh',
                 fontSize: ResponsiveUtil.isTablet(context) ? 18 : 24,
                 color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
           ),
        ),
        const Gap(16),
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Text(
                otherLangHadithText, // Simple Text, replaced ReadMoreLess
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.justify,
               // textDirection? Depends on lang. 
          ),
        ),
      ],
    );
  }
}
