import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/features/quran/view/widget/quran_details_view_item_builder.dart';

import '../../../core/localization/localization_manager.dart';
import '../../../core/shard/exports/all_exports.dart';
import '../data/repo/hadith_details_repo_immp.dart';
import 'controller/hadith_details_bloc.dart';

class QuranDetailsView extends StatelessWidget {
  const QuranDetailsView({super.key, required this.recitersId, required this.index});

  final String recitersId;
  final dynamic index;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuranAudioBloc>(
        create: (BuildContext context) => QuranAudioBloc(QuranDetailsRepoImmp())
          ..getQuranDetails(recitersId: recitersId),
        child: Directionality(
            textDirection: LocalizationManager.isEn
                ? TextDirection.ltr
                : TextDirection.rtl,
            child: Scaffold(
                // backgroundColor: AppStyle.bgColors,
                body: SafeArea(
                    child:
                    QuranDetailsViewItemBuilder(recitersId: recitersId,index: index,)))));
  }
}
