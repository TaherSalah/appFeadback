import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/features/radioView/view/widget/QuranRadioItemBuilder.dart';

import '../../core/cubit/centralized_cubit.dart';
import '../../core/widgets/no_internet_dialog.dart';

class QuranRadioView extends StatefulWidget {
  const QuranRadioView({super.key});

  @override
  State<QuranRadioView> createState() => _QuranRadioViewState();
}

class _QuranRadioViewState extends State<QuranRadioView> {
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

    return BlocListener<CentralizedCubit, CentralizedState>(
      listener: (context, state) {
        if (state is ConnectivityState &&
            state.status == ConnectivityStatus.disconnected) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => NoInternetDialog(
              onRetrySuccess: () {
                Navigator.pop(context);
              },
            ),
          );
        }
      },
      child: PopScope(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            key: scaffoldState,
            body: const SafeArea(child: QuranRadioItemBuilder()),
          ),
        ),
      ),
    );
  }
}
