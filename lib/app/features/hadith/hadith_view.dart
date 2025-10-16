
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/features/hadith/view/widget/details_view_item_builder.dart';

import '../../../main.dart';
import '../../core/cubit/centralized_cubit.dart';
import '../../core/shard/constanc/app_style.dart';


class HadithView extends StatefulWidget {
  const HadithView({super.key});

  @override
  State<HadithView> createState() => _HadithViewState();
}

class _HadithViewState extends State<HadithView> {
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
        return state is ConnectivityState &&
            state.status == ConnectivityStatus.disconnected
            ? const NoConnectionScreen():  PopScope(
          child: Directionality(
            textDirection:  TextDirection.rtl,
            child: Scaffold(
              // backgroundColor: AppStyle.bgColors,

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
              body: const SafeArea(child: HadithViewItemBuilder()),
            ),
          ),
        );
      },
    );
  }
}

