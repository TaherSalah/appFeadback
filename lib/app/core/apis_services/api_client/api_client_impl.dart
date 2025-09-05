import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;


import '../../cubit/api_client/api_client_bloc.dart';
import '../../utils/style/k_helper.dart';
import '../api_services.dart';
import 'endpoints.dart';
import 'interceptor.dart';

class DioClientImpl {
  final List<Interceptor> otherInterceptors;
  final BaseOptions? baseOptions;
  ApiClientBloc apiClientBloc;

  DioClientImpl(
      {this.otherInterceptors = const [],
      this.baseOptions,
      required this.apiClientBloc}) {
    _dio.interceptors
      ..add(UserInterceptor(
        onRequestCallback: apiClientBloc.onRequestCallBack,
        onResponseCallback: apiClientBloc.onResponseCallBack,
        onErrorCallback: apiClientBloc.onErrorCallBack,
        onRetry: apiClientBloc.scheduleRetry,
      ))
      ..addAll(otherInterceptors)
      ..add(PrettyDioLogger());
    if (baseOptions != null) {
      options = baseOptions!;
    }
  }

  static BaseOptions options = BaseOptions(
    headers: {
      "Accept": "application/json",
    },
    baseUrl: KEndPoints.baseUrl,
    contentType: 'application/json',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 10),
    sendTimeout: const Duration(minutes: 10),
    validateStatus: (status) => status! < 500,
  );

  final _dio = Dio(options);
  final _dioStatusCodeCheck = Dio(options);

  Future<Response> get(String path,
      {Map<String, dynamic>? params, Options? options}) {
    return _dio.get(path, queryParameters: params, options: options);
  }

  Future<Response> statusCodeCheck(String path,
      {Map<String, dynamic>? params, Options? options}) {
    return _dioStatusCodeCheck.get(path,
        queryParameters: params, options: options);
  }

  Future<Response> post(String path,
      {Map<String, dynamic>? params, Options? options, data}) {
    return _dio.post(path,
        data: data, queryParameters: params, options: options);
  }

  Future<Response> paymentPost(String path,
      {Map<String, dynamic>? params, Options? options, data}) {
    return _dio.post(path,
        data: data, queryParameters: params, options: options);
  }

  Future<Response> postWithFiles(String path,
      {Map<String, dynamic>? params, Options? options, data}) {
    return _dio.post(
      path,
      data: FormData.fromMap(data),
      queryParameters: params,
      options: options
        ?..headers?.addAll(
          {
            "Accept": "application/json",
            // "Content-Type": "multipart/form-data",
          },
        ),
    );
  }

  Future<Response> patch(String path,
      {Map<String, dynamic>? params, Options? options, data}) {
    return _dio.patch(path,
        data: data, queryParameters: params, options: options);
  }

  Future<Response> put(String path,
      {Map<String, dynamic>? params, Options? options, data}) {
    return _dio.put(path,
        data: data, queryParameters: params, options: options);
  }

  Future<Response> delete(String path,
      {Map<String, dynamic>? params, Options? options, data}) {
    return _dio.delete(path,
        data: data, queryParameters: params, options: options);
  }

  Future<Response> request(
    String path, {
    data,
    Map<String, dynamic>? params,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.request(
      path,
      data: data,
      queryParameters: params,
      options: options,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  Future postRequestWithDynamicBody(
      {required Map<String, dynamic> body,
      // Map<String, String>? headers,
      String? url}) async {
    debugPrint('body post${body.toString()}');
    debugPrint("url$url");

    try {
      var response = await Dio().post(url!,
          data: body,
          options: Options(headers: {
            'Accept': 'application/json',
          }, followRedirects: false));
      log("response in dio = ${response.data.toString()}");
      if (response.statusCode == 200) {
        return jsonDecode(response.toString());
      }

      //  return jsonDecode(response.toString());
    } catch (e) {
      log("error = $e");
      // if (e.response?.statusCode == 422) {
      //   final errors = e.response?.data['errors'];
      //   print("error = $errors");
      // } else {
      //   print("error = $e");
      // }
    }
  }

  Future getRequest({
    required String url,
    Map<String, String>? headers,
  }) async {
    var request = http.Request('GET', Uri.parse(url));
    request.headers.addAll({
      'Accept': 'application/json',
    });
    if (headers != null) request.headers.addAll(headers);
    debugPrint("request headers ${request.headers.toString()}");
    http.StreamedResponse response = await request.send();
    String result = await response.stream.bytesToString();
    return json.decode(result);
  }

  Future postRequest({
    required String url,
    required Map<String, String> body,
    List<http.MultipartFile> files = const [],
    Map<String, String>? headers,
  }) async {
    debugPrint(body.toString());
    debugPrint("${KEndPoints.baseUrl}$url");
    var request = MultipartRequest(
      'POST',
      Uri.parse('https://api.yaqees.com/yaqees/public/api/save-student-scores'),
      onProgress: (int bytes, int total) async {
        final progress = bytes / total;
        log(">>>>>>>>> progress: $progress");
      },
    );
    request.fields.addAll(body);
    for (int i = 0; i < files.length; i++) {
      request.files.add(files[i]);
    }

    request.headers.addAll({});
    // if (SharedPref.getUserObg() != null) {
    //   request.headers.addAll(
    //       {'Authorization': 'Bearer ${SharedPref.getUserObg()?.accessToken??''}'});
    // }
    if (headers != null) request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () async =>
              await KHelper.showError(message: " The API call timed out. "));
      String result = await response.stream.bytesToString();
      log(response.statusCode.toString());
      if (response.statusCode == 401) {
        return;
      }
      log(result.toString());
      return json.decode(result);
    } on SocketException {
      KHelper.showError(message: "there_is_no_internet");
    } on HttpException catch (httpException) {
      KHelper.showError(message: httpException.message.toString());
    } on FormatException catch (formException) {
      KHelper.showError(message: formException.message.toString());
    } on TimeoutException catch (timeOutException) {
      KHelper.showError(message: timeOutException.message.toString());
    } on HandshakeException catch (handShakeException) {
      KHelper.showError(message: handShakeException.message.toString());
    } catch (error) {
      KHelper.showError(message: error.toString());
      return null;
    }
  }
}
