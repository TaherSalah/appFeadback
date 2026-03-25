import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:quran_library/quran.dart';

class JozzsListScreen extends StatefulWidget {
  const JozzsListScreen({super.key});

  @override
  State<JozzsListScreen> createState() => _JozzsListScreenState();
}

class _JozzsListScreenState extends State<JozzsListScreen> {
  final List<String> jozzs = QuranLibrary.allJoz;

  final List<BookmarkModel> bookmark = QuranLibrary().usedBookmarks;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // backgroundColor: AppStyle.bgColors,
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              "اجزاء القران الكريم",
              style: TextStyle(
                  fontFamily: "cairo",
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
            ),
          ),
        ),
        body: ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          physics: const BouncingScrollPhysics(),
          itemCount: jozzs.length,
          itemBuilder: (ctx, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  QuranLibrary().jumpToJoz(index + 1);
                  Navigator.pop(context);
                },
                child: Row(
                  spacing: 25,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/suraNum.svg",
                        ),
                        TextWidget(
                          title: "${index + 1}",
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 9.sp : 14.sp,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWidget(
                            fontFamily: "me",
                            fontSize:
                                ResponsiveUtil.isTablet(context) ? 9.sp : 14.sp,
                            fontWeight: FontWeight.bold,
                            title: jozzs[index]),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
