import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:quran_library/quran.dart';

class JozzsListScreen extends StatefulWidget {
  const JozzsListScreen({super.key});

  @override
  State<JozzsListScreen> createState() => _JozzsListScreenState();
}

class _JozzsListScreenState extends State<JozzsListScreen> {
  final List<String> jozzs = QuranLibrary().allJoz;

  final List<BookmarkModel> bookmark = QuranLibrary().usedBookmarks;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
          child: AppBar(
            leading: const CupertinoNavigationBarBackButton(
              color: Colors.black,
            ),
            centerTitle: true,
            title: Text(
              "اجزاء القران الكريم",
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
            ),
          ),
        ),
        body: ListView.builder(
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
                          fontSize: 14.sp,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextWidget(
                            fontFamily: "me",
                            fontSize: 15.sp,
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
