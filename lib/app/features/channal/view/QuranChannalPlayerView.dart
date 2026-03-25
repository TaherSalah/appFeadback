import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/core/cubit/centralized_cubit.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/widgets/QuranRadioPlayer.dart';

import '../../../core/widgets/NoConnectionScreen.dart';

class QuranChannalPlayerView extends StatefulWidget {
  const QuranChannalPlayerView({super.key});

  @override
  State<QuranChannalPlayerView> createState() => _QuranChannalPlayerViewState();
}

class _QuranChannalPlayerViewState extends State<QuranChannalPlayerView> {
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
    final isDark = context.isDark;

    return BlocBuilder<CentralizedCubit, CentralizedState>(
      builder: (context, state) {

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
                          MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
                      child: AppBar(
                        leading:  CupertinoNavigationBarBackButton(
                          color:isDark?Colors.white : Colors.black,
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
                          style: TextStyle(
                  fontFamily: "cairo",
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
                    body: const SafeArea(
                        child: QuranRadioPlayer(
                      title: "widget.title",
                      streamUrl:
                          "https://win.holol.com/live/quran/playlist.m3u8",
                    )),
                  ),
                ),
              );
      },
    );
  }
}
