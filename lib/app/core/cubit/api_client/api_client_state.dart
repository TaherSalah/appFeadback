// ignore: depend_on_referenced_packages
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../errors/failuers.dart';

part 'api_client_state.freezed.dart';

@freezed
class ApiClientState with _$ApiClientState {
  const factory ApiClientState.initial() = ApiClientStateInitial;
  const factory ApiClientState.error({required KFailure failure}) =
      ApiClientStateError;
}
// flutter pub run build_runner watch --delete-conflicting-outputs
