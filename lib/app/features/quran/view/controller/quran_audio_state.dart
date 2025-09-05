import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/modal/quran_audio_modal.dart';
import '../../data/modal/quran_details_modal.dart';

part 'quran_audio_state.freezed.dart';

@freezed
class QuranAudioState with _$QuranAudioState {
  const factory QuranAudioState.initial() = QuranDetailsStateInitial;

  const factory QuranAudioState.loadingReciters() = QuranRecitersStateLoading;

  const factory QuranAudioState.errorReciters({required String failure}) =
      QuranRecitersStateError;
  const factory QuranAudioState.successReciters({QuranAudioModal? quranAudioModal}) =
      QuranRecitersStateSuccess;

  const factory QuranAudioState.quranDetailsLoading() =
      QuranDetailsStateLoading;
  const factory QuranAudioState.successDetailsQuran(
      {QuranDetailsModal? quranDetailsModal}) = QuranDetailsStateSuccess;

  const factory QuranAudioState.errorDetailsQuran({required String failure}) =
      QuranDetailsStateError;
}
