import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/style/responsive_util.dart';

class AboutBook extends StatelessWidget {
  final String bookDetails;
  const AboutBook({super.key, required this.bookDetails});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: Theme.of(context).primaryColor,
              size: ResponsiveUtil.isTablet(context) ? 22 : 26,
            ),
            const SizedBox(width: 12),
            Text(
              'aboutBook'.tr,
              style: TextStyle(
                    fontFamily: 'kufi',
                    fontSize: ResponsiveUtil.isTablet(context) ? 18 : 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              bookDetails,
              style: TextStyle(
                fontFamily: 'naskh',
                fontSize: ResponsiveUtil.isTablet(context) ? 18 : 22,
                height: 1.8,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
