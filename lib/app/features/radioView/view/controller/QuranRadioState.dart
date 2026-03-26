import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:muslimdaily/app/core/errors/failuers.dart';
import 'package:muslimdaily/app/features/radioView/data/modal/QuranRadioModel.dart';
part 'QuranRadioState.freezed.dart';

@freezed
class QuranRadioState with _$QuranRadioState {
  const factory QuranRadioState.initial() = QuranRadioStateInitial;
  const factory QuranRadioState.loading() = QuranRadioStateLoading;
  const factory QuranRadioState.error({required KFailure failure}) =
      QuranRadioStateError;
  const factory QuranRadioState.success({QuranRadioModel? quranRadioModel}) =
      QuranRadioStateSuccess;
}
