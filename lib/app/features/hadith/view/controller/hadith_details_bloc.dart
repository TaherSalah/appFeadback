import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_manager.dart';
import '../../../categories/data/modal/all_hadith_categories_modal.dart';
import '../../data/modal/hadith_details_modal.dart';
import '../../data/repo/hadith_details_repo_immp.dart';
import 'hadith_details_state.dart';


class HadithDetailsBloc extends Cubit<HadithDetailsState> {
  HadithDetailsBloc(this.hadithDetailsRepoImmp)
      : super(const HadithDetailsState.initial());

  static HadithDetailsBloc get(context) =>
      BlocProvider.of<HadithDetailsBloc>(context);

  final HadithDetailsRepoImmp hadithDetailsRepoImmp;
  // HadithDetailsModal? hadithDetailsModal;
  List<HadithDetailsModal>? hadithDetailsModalList;
  HadithDetailsModal? hadithDetailsModal;
  List<AllHadithCategorieModal>? allHadithCategorieModalList;
  Future<void> getHadithDetails({dynamic hadithId}) async {
    try {
      emit(const HadithDetailsState.loading());
      var result =
          await hadithDetailsRepoImmp.getHadithDetails(hadithId: hadithId);
      result.fold((failure) {
        debugPrint(
            '=================  get hadith Details  Bloc Failure : $failure');
        emit(HadithDetailsState.error(failure: failure.toString()));
      }, (categoriesList) {
        hadithDetailsModal = categoriesList;
        getMoreHadithDetails(hadithId: hadithDetailsModal!.categories);
        debugPrint(
            '================= get hadith Details Bloc Success : $categoriesList');
        emit(HadithDetailsState.success(hadithDetailsModal: categoriesList));
      });
    } catch (e) {
      debugPrint(
          '================= get hadith Details Bloc (Catch): ${e.toString()}');
      emit(HadithDetailsState.error(
          failure: LocalizationManager.call('try_later')));
      rethrow;
    }
  }

  Future<void> getHadithDetailsList({List? hadithId}) async {
    try {
      emit(const HadithDetailsState.loading());

      // Make all the calls concurrently
      final futures = hadithId!.map((id) {
        return hadithDetailsRepoImmp.getHadithDetailsList(hadithId: id);
      }).toList();

      final results = await Future.wait(futures);

      // Process all results
      for (var result in results) {
        result.fold((failure) {
          debugPrint('Failed to get Hadith details: $failure');
          emit(HadithDetailsState.error(
              failure:
                  'failed to get Hadith details List ${failure.toString()}'));
        }, (hadithDetails) {
          print('results #{${hadithDetails.length}');
          // debugPrint('Successfully fetched Hadith details');
          emit(HadithDetailsState.successDetailsList(
              hadithDetailsModal: hadithDetails));
          // hadithDetails = hadithDetailsModal!;
          hadithDetailsModalList = hadithDetails;
        });
      }
    } catch (e) {
      debugPrint('Error getting Hadith details: ${e.toString()}');
      emit(const HadithDetailsState.error(failure: 'Error fetching data'));
    }
  }

  Future<void> getMoreHadithDetails({List? hadithId}) async {
    try {
      emit(const HadithDetailsState.hadithMoreLoading());

      // Make all the calls concurrently
      final futures = hadithId!.map((id) {
        return hadithDetailsRepoImmp.getMoreHadith(hadithId: id);
      }).toList();

      final results = await Future.wait(futures);

      // Process all results
      for (var result in results) {
        result.fold((failure) {
          debugPrint('Failed to get Hadith more: $failure');
          emit(HadithDetailsState.hadithMoreError(
              failure: 'failed to get Hadith more List ${failure.toString()}'));
        }, (hadithDetails) {
          allHadithCategorieModalList = hadithDetails;
          print('results #{${hadithDetails.length}');
          // debugPrint('Successfully fetched Hadith details');
          emit(HadithDetailsState.hadithMoreSuccess(
              allHadithCategorieModal: hadithDetails));

          // hadithDetails = hadithDetailsModal!;
          // hadithDetailsModalList = hadithDetails;
        });
      }
    } catch (e) {
      debugPrint('Error getting Hadith more : ${e.toString()}');
      emit(const HadithDetailsState.hadithMoreError(failure: 'Error fetching data'));
    }
  }
}
