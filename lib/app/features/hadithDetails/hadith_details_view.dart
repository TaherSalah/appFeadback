import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import Clipboard functionality
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:muslimdaily/app/features/hadithDetails/view/controller/hadith_details_bloc.dart';
import 'package:muslimdaily/app/features/hadithDetails/view/controller/hadith_details_state.dart';
import 'package:muslimdaily/app/features/hadithDetails/view/widget/details_view_item_builder.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/utils/style/k_color.dart';
import '../../core/utils/style/k_helper.dart';
import 'data/repo/hadith_details_repo_immp.dart';

import 'package:muslimdaily/app/core/services/wakelock_service.dart';

class HadithDetailsView extends StatefulWidget {
  const HadithDetailsView({super.key, this.hadithId});

  final dynamic hadithId;

  @override
  State<HadithDetailsView> createState() => _HadithDetailsViewState();
}

class _HadithDetailsViewState extends State<HadithDetailsView> {
  @override
  void initState() {
    super.initState();
    WakelockService.enableIfActive();
  }

  @override
  void dispose() {
    WakelockService.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
    final key = GlobalKey<ExpandableFabState>();
    return BlocProvider<HadithDetailsBloc>(
        create: (BuildContext context) =>
            HadithDetailsBloc(HadithDetailsRepoImmp())
              ..getHadithDetails(hadithId: widget.hadithId!),
        child: Directionality(
            textDirection: LocalizationManager.isEn
                ? TextDirection.ltr
                : TextDirection.rtl,
            child: Scaffold(
                floatingActionButtonLocation: ExpandableFab.location,
                floatingActionButton:
                    BlocBuilder<HadithDetailsBloc, HadithDetailsState>(
                  builder: (BuildContext context, state) {
                    if (state is HadithDetailsStateSuccess ||
                        state is MoreHadithDetailsStateSuccess) {
                      HadithDetailsBloc bloc =
                          BlocProvider.of<HadithDetailsBloc>(context);
                      void copyToClipboard(BuildContext context) {
                        Clipboard.setData(ClipboardData(
                                text: bloc.hadithDetailsModal?.hadeeth))
                            .then((_) {
                          KHelper.showSuccess(
                              message: 'تم نسخ الحديث إلى الحافظة!');
                        });
                      }

                      return ExpandableFab(
                          key: key,
                          openButtonBuilder: RotateFloatingActionButtonBuilder(
                            child:  const Icon(Icons.menu),
                            fabSize: ExpandableFabSize.regular,
                            foregroundColor:
                                    Colors.white,
                            backgroundColor:
                                context.isDark
                                    ? Colors.black
                                    : KColors.primaryColor,
                            shape: const CircleBorder(),
                          ),
                          closeButtonBuilder: RotateFloatingActionButtonBuilder(
                            child: const Icon(Icons.close),
                            fabSize: ExpandableFabSize.regular,
                            foregroundColor:
                                context.isDark
                                    ? Colors.white
                                    : KColors.primaryColor,
                            backgroundColor:
                                context.isDark
                                    ? Colors.black
                                    : KColors.primaryColor,
                            shape: const CircleBorder(),
                          ),
                          overlayStyle: ExpandableFabOverlayStyle(
                              color: Colors.black.withOpacity(0.5), blur: 5),
                          pos: ExpandableFabPos.left,
                          children: [
                            FloatingActionButton.small(
                              backgroundColor: Colors.black,
                              heroTag: null,
                              child: const Icon(
                                Icons.copy,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                copyToClipboard(context);
                              },
                            ),
                            FloatingActionButton.small(
                                backgroundColor: Colors.black,
                                heroTag: null,
                                child: const Icon(
                                  Icons.share,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  final state = key.currentState;
                                  if (state != null) {
                                    onShareHadith(
                                        context: context,
                                        hadithText:
                                            bloc.hadithDetailsModal?.hadeeth,
                                        hadithTitle:
                                            bloc.hadithDetailsModal?.title);
                                    state.toggle();
                                  }
                                }),
                          ]);
                    }
                    return  KLoading.progressIOSIndicator(context: context);
                  },
                ),
                key: scaffoldState,
                body: const DetailsViewItemBuilder())));
  }
}

class HadithContentShare {
  final String hadithContent;
  final String hadithTitle;
  final dynamic hadithId;
  HadithContentShare(
    this.hadithId, {
    required this.hadithContent,
    required this.hadithTitle,
  });
}

// void onShare(
//     {required BuildContext context,
//     required String hadithContent,
//     String? hadithTitle}) async {
//   final box = context.findRenderObject() as RenderBox?;
//   String shareApp =
//       ' $hadithContent  \n \n \n 📦 قم بتحميل تطبيق  رَفِيقُ المُسْلِمِ اليَوْمِي حتي يمكنك من قراءة المزيد من الأحاديث النبوية الشريفة الصحيحة ';
//   String? subject = hadithTitle;
//
// // Android specific code
//   await Share.share(shareApp,
//       subject: subject,
//       sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
// }
void onShareHadith({
  required BuildContext context,
  required String hadithText,
  String? hadithTitle,
}) async {
  final box = context.findRenderObject() as RenderBox?;

  final shareText = """
🌺✨🌿✨🌺✨🌿✨🌺✨🌿

📿 **${hadithTitle ?? "حديث شريف"}** 
$hadithText

🌿✨🌸✨🌿✨🌸✨🌿✨

💫 من تطبيق *رفيق المسلم اليومي* 💫  
حمل التطبيق الآن واستفد من كل الأحاديث اليومية:

📱 **Play Google للاندرويد:**  
➡️ https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily

📱 **App Gallery هواوي:**  
➡️ https://appgallery.huawei.com/app/C114956477

📱 **App Store للايفون:**  
➡️ https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338

🌟 شارك هذا الحديث مع أصدقائك لتعمّ الفائدة 🌟

🌺✨🌿✨🌺✨🌿✨🌺✨🌿
""";

  await Share.share(
    shareText,
    subject: hadithTitle,
    sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  );
}

void copyHadithToClipboard(BuildContext context,
    {required String hadithText, String? hadithTitle}) {
  final copyText = """
🌺✨🌿✨🌺✨🌿✨🌺✨🌿

📿 **${hadithTitle ?? "حديث شريف"}** 
$hadithText

🌿✨🌸✨🌿✨🌸✨🌿✨

💫 من تطبيق *رفيق المسلم اليومي* 💫  
حمل التطبيق الآن واستفد من كل الأحاديث اليومية:

📱 **Android:**  
➡️ https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily

📱 **Huawei AppGallery:**  
➡️ https://appgallery.huawei.com/app/C114956477

📱 **iOS App Store:**  
➡️ https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338

🌟 شارك هذا الحديث مع أصدقائك لتعمّ الفائدة 🌟

🌺✨🌿✨🌺✨🌿✨🌺✨🌿
""";

  Clipboard.setData(ClipboardData(text: copyText));
  KHelper.showSuccess(message: 'تم نسخ الحديث مع رابط التطبيق!');

}
