import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';


import '../../errors/error_422_model.dart';
import '../../errors/failuers.dart';
import '../../localization/localization_manager.dart';
import '../../utils/style/k_helper.dart';

abstract class ApiClientHelper {
  static Future<Either<KFailure, dynamic>> responseToModel(
      {Future<Response<dynamic>>? func, Response<dynamic>? res}) async {
    assert(func != null || res != null);
    if (await ConnectivityCheck.call()) {
      try {
        final response = ((await func) ?? res)!;
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.data['status'] == 'error') {
            KHelper.showError(message: response.data['message']);
          }
          return right(response.data);
        } else if (response.statusCode == 500) {
          return left(KFailure.error(response.data));
        } else if (response.statusCode == 522) {
          return KHelper.showError(message: 'Host Error');
        } else if (response.statusCode == 400) {
          KHelper.showError(message: response.data['msg'].toString());

          return left(
              KFailure.error401(error: response.data['message'].toString()));
        } else if (response.statusCode == 402) {
          KHelper.showError(message: response.data['message'].toString());
          return left(KFailure.error422(
              error422model: Error422Model.fromJson(response.data)));
        } else if (response.statusCode == 422) {
          KHelper.showError(message: response.data['message'].toString());
          return left(KFailure.error422(
              error422model: Error422Model.fromJson(response.data)));
        } else if (response.statusCode == 401) {
          KHelper.showError(message: response.data['message'].toString());
          return left(
              KFailure.error401(error: response.data['message'].toString()));
        } else if (response.statusCode == 403) {
          KHelper.showError(message: response.data['message'].toString());
          return left(
              KFailure.error401(error: response.data['message'].toString()));
        } else if (response.statusCode == 404) {
          KHelper.showError(message: response.data['message'].toString());

          return left(
              KFailure.error401(error: response.data['message'].toString()));
        } else {
          return left(KFailure.error(response.data.toString()));
        }
      } on DioException catch (e) {
        debugPrint(
            '=================>> DioError : ${e.message} , ${e.type} ${e.error}');
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            return left(const KFailure.error("Request Time out"));
          case DioExceptionType.receiveTimeout:
            return left(const KFailure.error("Receive Time out"));
          case DioExceptionType.badResponse:
            return left(KFailure.error(e.message ?? ''));
          case DioExceptionType.unknown:
            if (e.error != null && e.error is SocketException) {
              KHelper.showError(
                  message: LocalizationManager.call('checkNetwork'));

              return left(KFailure.offline(option: e.requestOptions));
            } else {
              KHelper.showError(
                  message: LocalizationManager.call('checkNetwork'));

              debugPrint('=================> 1');
              return left(const KFailure.someThingWrongPleaseTryAgain());
            }
          default:
            debugPrint('=================> 2');
            KHelper.showError(
                message: LocalizationManager.call('checkNetwork'));

            return left(const KFailure.someThingWrongPleaseTryAgain());
        }
      } catch (e) {
        KHelper.showError(message: LocalizationManager.call('checkNetwork'));

        debugPrint('=================> 3');
        return left(KFailure.error(e.toString()));
      }
    } else {
      KHelper.showError(message: LocalizationManager.call('checkNetwork'));

      return left(const KFailure.offline());
    }
  }
}

abstract class ConnectivityCheck {
  static final Connectivity _connectivity = Connectivity();

  static Future<bool> call() async {
    var connectivityResult = await (_connectivity.checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }

  static Stream<List<ConnectivityResult>> get connectionStream {
    return _connectivity.onConnectivityChanged;
  }
}
