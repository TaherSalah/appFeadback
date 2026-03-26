import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/core/errors/failuers.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../../radioView/data/modal/QuranRadioModel.dart';
import '../../data/repo/QuranRadioRepoImmp.dart';
import 'QuranRadioState.dart';


class QuranRadioBloc extends Cubit<QuranRadioState> {
  QuranRadioBloc(this.quranRadioRepoImmp)
      : super(const QuranRadioState.initial());

  static QuranRadioBloc get(context) =>
      BlocProvider.of<QuranRadioBloc>(context);

  final QuranRadioRepoImmp quranRadioRepoImmp;
  // HadithDetailsModal? hadithDetailsModal;
  // List<HadithDetailsModal>? hadithDetailsModalList;
  QuranRadioModel? quranRadioModel;
  Future<void> getQuranRadioData() async {
    try {
      emit(const QuranRadioState.loading());
      var result =
          await quranRadioRepoImmp.getQuranRadioData();
      result.fold((failure) {
        debugPrint(
            '=================  get hadith Details  Bloc Failure : $failure');
        emit(QuranRadioState.error(failure:KFailureError(failure)));
      }, (data) {
        quranRadioModel = data;
        debugPrint(
            '================= get hadith Details Bloc Success : $data');
        emit(QuranRadioState.success(quranRadioModel: data));
      });
    } catch (e) {
      debugPrint(
          '================= get hadith Details Bloc (Catch): ${e.toString()}');
      emit(QuranRadioState.error(
          failure: KFailure.error(LocalizationManager.call('try_later'))));
      rethrow;
    }
  }

}
