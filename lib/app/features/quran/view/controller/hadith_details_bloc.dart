import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/features/quran/view/controller/quran_audio_state.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../data/modal/quran_audio_modal.dart';
import '../../data/modal/quran_details_modal.dart';
import '../../data/repo/hadith_details_repo_immp.dart';

class QuranAudioBloc extends Cubit<QuranAudioState> {
  QuranAudioBloc(this.quranDetailsRepoImmp)
      : super(const QuranAudioState.initial());

  static QuranAudioBloc get(context) =>
      BlocProvider.of<QuranAudioBloc>(context);

  final QuranDetailsRepoImmp quranDetailsRepoImmp;
  QuranDetailsModal? quranDetailsModal;
  QuranAudioModal? quranAudioModal;

  Future<void> getQuranAudio() async {
    try {
      emit(const QuranAudioState.loadingReciters());
      var result =
          await quranDetailsRepoImmp.getQuranAudio();
      result.fold((failure) {
        debugPrint(
            '=================  get Quran   Bloc Failure : $failure');
        emit(QuranAudioState.errorReciters(failure: failure.toString()));
      }, (data) {
        quranAudioModal = data;
        debugPrint(
            '================= get Quran  Bloc Success : $data');
        emit(QuranAudioState.successReciters(quranAudioModal: data));
      });
    } catch (e) {
      debugPrint(
          '================= get Quran  Bloc (Catch): ${e.toString()}');
      emit(QuranAudioState.errorReciters(
          failure: LocalizationManager.call('try_later')));
      rethrow;
    }
  }
  Future<void> getQuranDetails({String? recitersId})  async {
    try {
      emit(const QuranAudioState.quranDetailsLoading());
      var result =
          await quranDetailsRepoImmp.getQuranDetails(recitersId: recitersId);
      result.fold((failure) {
        debugPrint(
            '=================  get Quran Details  Bloc Failure : $failure');
        emit(QuranAudioState.errorDetailsQuran(failure: failure.toString()));
      }, (data) {
        quranDetailsModal = data;
        debugPrint(
            '================= get Quran Details  Bloc Success : $data');
        emit(QuranAudioState.successDetailsQuran(quranDetailsModal: data));
      });
    } catch (e) {
      debugPrint(
          '================= get Quran Details Bloc (Catch): ${e.toString()}');
      emit(QuranAudioState.errorDetailsQuran(
          failure: LocalizationManager.call('try_later')));
      rethrow;
    }
  }



}
