
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:quran_library/quran.dart';


class HizbeListScreen extends StatefulWidget {
  const HizbeListScreen({super.key});

  @override
  State<HizbeListScreen> createState() => _HizbeListScreenState();
}

class _HizbeListScreenState extends State<HizbeListScreen> {

  final List<String> hizb = QuranLibrary().allHizb;

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
              "احزاب القران الكريم",
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                  MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
            ),
          ),
        ),
        body: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: hizb.length,
          itemBuilder: (ctx, index) {
            final surah = hizb[index];

            return  Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13,vertical: 8),
              child: GestureDetector(
                onTap: () {
                  QuranLibrary().jumpToHizb(index + 1);
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
                        SvgPicture.asset("assets/icons/suraNum.svg"),
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
                            title: hizb[index]),

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
