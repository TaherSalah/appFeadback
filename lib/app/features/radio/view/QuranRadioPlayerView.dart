import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/core/cubit/centralized_cubit.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/features/radio/view/widget/QuranRadioItemBuilder.dart';
import 'package:muslimdaily/main.dart';
import 'package:muslimdaily/app/core/widgets/QuranRadioPlayer.dart';

import '../../../core/widgets/NoConnectionScreen.dart';

class QuranRadioPlayerView extends StatefulWidget {
  const QuranRadioPlayerView(
      {super.key,
      required this.title,
      required this.streamUrl,
      this.accentColor,
      required this.compact});
  final String title;
  final String streamUrl;
  final Color? accentColor;
  final bool compact; // لو عايز نسخة صغيرة
  @override
  State<QuranRadioPlayerView> createState() => _QuranRadioPlayerViewState();
}

class _QuranRadioPlayerViewState extends State<QuranRadioPlayerView> {
  late CentralizedCubit centralizedCubit;

  @override
  void initState() {
    centralizedCubit = context.read<CentralizedCubit>();
    centralizedCubit.checkConnectivity();
    centralizedCubit.trackConnectivityChange();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // centralizedCubit.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

    return BlocBuilder<CentralizedCubit, CentralizedState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return state is ConnectivityState &&
                state.status == ConnectivityStatus.disconnected
            ? const NoConnectionScreen()
            : PopScope(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Scaffold(
                    // backgroundColor: AppStyle.bgColors,
                    appBar: PreferredSize(
                      preferredSize: Size.fromHeight(
                          MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
                      child: AppBar(
                        leading: CupertinoNavigationBarBackButton(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        // actions: [
                        //   IconButton(
                        //     onPressed: () => Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => CreateKhatmahScreen(),
                        //       ),
                        //     ),
                        //     icon: const Icon(Icons.add),
                        //   )
                        // ],
                        centerTitle: true,
                        title: Text(
                          "اذاعة القران الكريم ",
                          style: GoogleFonts.cairo(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.sizeOf(context).width > 600
                                ? 12.sp
                                : 18.sp,
                          ),
                        ),
                      ),
                    ),

                    key: scaffoldState,
                    // appBar: AppBar(
                    //     centerTitle: true,
                    //     title: Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    //       child: Image.asset(
                    //         AssetsManager.logo,
                    //         height: 70.h,
                    //         width: 70.w,
                    //       ),
                    //     ),
                    //     leading: const SizedBox()),
                    body: SafeArea(
                        child: QuranRadioPlayer(
                      title: widget.title,
                      accentColor: widget.accentColor,
                      compact: widget.compact,
                      streamUrl: widget.streamUrl,
                    )),
                  ),
                ),
              );
      },
    );
  }
}
