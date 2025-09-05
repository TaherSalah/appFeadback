import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../localization/localization_manager.dart';
import 'error_422_model.dart';

part 'failuers.freezed.dart';

@freezed
class KFailure with _$KFailure {
  const factory KFailure.error(String error) = KFailureError;

  const factory KFailure.server() = KFailureServer;

  const factory KFailure.offline({RequestOptions? option}) = KFailureOffline;

  const factory KFailure.userNotFound() = KFailureUserNotFound;

  const factory KFailure.locationDenied() = KFailureLocationDenied;

  const factory KFailure.locationDisabled() = KFailureLocationDisabled;

  const factory KFailure.locationDeniedPermanently() =
      KFailureLocationDeniedPermanently;

  const factory KFailure.someThingWrongPleaseTryAgain() =
      KFailureSomeThingWrongPleaseTryAgain;
  const factory KFailure.error401({required String error}) = KFailureError401;

  const factory KFailure.error422({required Error422Model error422model}) =
      KFailureError422;

  // static String toError(KFailure failure) {
  //   return failure.when(
  //     server: () => LocalizationManager.call('try_later'),
  //     offline: (option) => LocalizationManager.call('no_connection'),
  //     userNotFound: () => "User Not Found",
  //     locationDisabled: () => LocalizationManager.call('location_disabled'),
  //     error: (error) => error,
  //     locationDenied: () => LocalizationManager.call('location_denied'),
  //     locationDeniedPermanently: () =>
  //         LocalizationManager.call('location_denied_permanently'),
  //     someThingWrongPleaseTryAgain: () => LocalizationManager.call('try_later'),
  //     error401: (error) => error,
  //     error422: (errorModel) {
  //       if (errorModel.hasSingleError) {
  //         return errorModel.error;
  //       } else {
  //         List<dynamic> errorMessages = [];
  //
  //         errorModel.errors.forEach((key, value) {
  //           errorMessages.addAll(value);
  //         });
  //         return errorMessages.join('\n');
  //         // return List<List>.from(errorModel.errors.values).map((e) => e.first).toString();
  //       }
  //     },
  //   );
  // }
  static String toError(KFailure failure) {
    return failure.when(
      server: () => LocalizationManager.call('try_later'),
      offline: (option) => LocalizationManager.call('no_connection'),
      userNotFound: () => "User Not Found",
      locationDisabled: () => LocalizationManager.call('location_disabled'),
      error: (error) {
        // Use regex to extract the message value within curly braces
        final messageRegex =
            RegExp(r'message\s*:\s*([^,}]+)'); // Adjusted to handle end braces
        final match = messageRegex.firstMatch(error);

        if (match != null) {
          // Return the captured message part, removing any potential extra spaces or braces
          return match.group(1)?.trim() ?? error;
        }

        // Fallback to the original error string if extraction fails
        return error;
      },
      locationDenied: () => LocalizationManager.call('location_denied'),
      locationDeniedPermanently: () =>
          LocalizationManager.call('location_denied_permanently'),
      someThingWrongPleaseTryAgain: () => LocalizationManager.call('try_later'),
      error401: (error) => error,
      error422: (errorModel) {
        if (errorModel.hasSingleError) {
          return errorModel.error;
        } else {
          List<dynamic> errorMessages = [];
          errorModel.errors.forEach((key, value) {
            errorMessages.addAll(value);
          });
          return errorMessages.join('\n');
        }
      },
    );
  }
}
// flutter pub run build_runner watch --delete-conflicting-outputs
