import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../categories/data/modal/all_hadith_categories_modal.dart';
import '../../data/modal/hadith_details_modal.dart';

part 'hadith_details_state.freezed.dart';

@freezed
class HadithDetailsState with _$HadithDetailsState {
  const factory HadithDetailsState.initial() = HadithDetailsStateInitial;
  const factory HadithDetailsState.loading() = HadithDetailsStateLoading;
  const factory HadithDetailsState.success(
      {HadithDetailsModal? hadithDetailsModal}) = HadithDetailsStateSuccess;
  const factory HadithDetailsState.successDetailsList(
          {List<HadithDetailsModal>? hadithDetailsModal}) =
      HadithDetailsListStateSuccess;
  const factory HadithDetailsState.error({required String failure}) =
      HadithDetailsStateError;

  const factory HadithDetailsState.hadithMoreLoading() =
      MoreHadithDetailsStateLoading;
  const factory HadithDetailsState.hadithMoreSuccess(
          {List<AllHadithCategorieModal>? allHadithCategorieModal}) =
      MoreHadithDetailsStateSuccess;
  const factory HadithDetailsState.hadithMoreError({required String failure}) =
      MoreHadithDetailsStateError;
}
