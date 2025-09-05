import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../cache/shard_pref/shard_prefrance.dart';

class ApiServicess {
////////////////////////// ====> api baseURL <==== //////////////////////////////////////
  static const String _baseURL = "https://hadeethenc.com/api/v1";

////////////////////////// ====> api parameters <==== //////////////////////////////////////

  final String login = "login";
  final String logout = "logout";
  final String register = "register";
  final String getCategories = '$_baseURL/categories/list/?language=ar';
  String getDetails({int? hadithId}) =>
      '$_baseURL/hadeeths/one/?language=ar&id=$hadithId';

////////////////////////// ====> post Request <==== //////////////////////////////////////

  Future postRequest({
    required String url,
    required Map<String, String> body,
    List<http.MultipartFile> files = const [],
    Map<String, String>? headers,
  }) async {
    debugPrint(body.toString());
    debugPrint("$_baseURL$url");
    var request = MultipartRequest(
      'POST',
      Uri.parse('$_baseURL$url'),
      onProgress: (int bytes, int total) async {
        final progress = bytes / total;
        log(">>>>>>>>> progress: $progress");
      },
    );

    request.fields.addAll(body);
    for (int i = 0; i < files.length; i++) {
      request.files.add(files[i]);
    }

    request.headers.addAll({
      'Accept': 'application/json',
    });
    // if (SharedPref.getUserObg() != null) {
    //   request.headers.addAll(
    //       {'Authorization': 'Bearer ${SharedPref.getUserObg()?.accessToken??''}'});
    // }
    if (headers != null) request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    String result = await response.stream.bytesToString();
    log(response.statusCode.toString());
    // if (response.statusCode == 401) {
    //   Modular.to.pushReplacementNamed(LoginScreen.routeName);
    //   return;
    // }
    log(result.toString());
    try {
      return json.decode(result);
    } catch (e) {
      return null;
    }
  }

////////////////////////// ====> post Request With Dynamic Body  <==== //////////////////////////////////////

  Future postRequestWithDynamicBody(
      {required Map<String, dynamic> body,
      // Map<String, String>? headers,
      required String url}) async {
    debugPrint(body.toString());
    debugPrint("$_baseURL$url");

    try {
      var response = await Dio().post('$_baseURL$url',
          data: body,
          options: Options(headers: {
            'Accept': 'application/json',
          }, followRedirects: false));
      log("response in dio = ${response.data.toString()}");
      if (response.statusCode == 200) {
        return jsonDecode(response.toString());
      }

      //  return jsonDecode(response.toString());
    } on DioException catch (e) {
      log("error = $e");
      // if (e.response?.statusCode == 422) {
      //   final errors = e.response?.data['errors'];
      //   print("error = $errors");
      // } else {
      //   print("error = $e");
      // }
    }
  }

////////////////////////// ====> GET REQUEST  <==== //////////////////////////////////////

  Future getRequest({
    required String url,
    Map<String, String>? headers,
  }) async {
    debugPrint('$_baseURL$url');

    var request = http.Request('GET', Uri.parse('$_baseURL$url'));
    request.headers.addAll({
      'Accept': 'application/json',

      // 'Authorization': 'Bearer ${SharedPref.getUserObg().token}'
    });
    if (headers != null) request.headers.addAll(headers);
    debugPrint('get header ${request.headers.toString()}');

    http.StreamedResponse response = await request.send();

    String result = await response.stream.bytesToString();
    log(" respon statusCode ${response.statusCode.toString()}");
    log(" respon $response");
    // if (response.statusCode == 401) {
    //   return;
    // }
    // log(result.toString());
    return json.decode(result);
  }

////////////////////////// ====> DELETE REQUEST  <==== //////////////////////////////////////
  Future getRequestByQuery({
    // required String url,
    required String q,
    Map<String, String>? headers,
  }) async {
    // debugPrint('$_baseURL$url');

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://www.googleapis.com/books/v1/volumes?Filtering-free-ebooks&q=$q&key=AIzaSyAfBkJnGJqabhUMrHH--LvXRlyBltn5_QI'));
    request.headers.addAll({
      'Accept': 'application/json',

      // 'Authorization': 'Bearer ${SharedPref.getUserObg().token}'
    });
    if (headers != null) request.headers.addAll(headers);
    debugPrint(request.headers.toString());

    http.StreamedResponse response = await request.send();

    String result = await response.stream.bytesToString();
    log(response.statusCode.toString());
    if (response.statusCode == 401) {
      return;
    }
    // log(result.toString());
    return json.decode(result);
  }

  Future deleteRequest({
    required String url,
    List<http.MultipartFile> files = const [],
    Map<String, String>? headers,
  }) async {
    debugPrint("$_baseURL$url");
    var request = MultipartRequest(
      'DELETE',
      Uri.parse('$_baseURL$url'),
      onProgress: (int bytes, int total) async {
        final progress = bytes / total;
        log(">>>>>>>>> progress: $progress");
      },
    );
    request.headers.addAll({
      'Accept': 'application/json',
      'lang': SharedPref.getCurrentLang() ?? "en",
    });
    // if (SharedPref.getUserObg() != null) {
    //   request.headers.addAll(
    //       {'Authorization': 'Bearer ${SharedPref.getUserObg()?.accessToken??''}'});
    // }
    if (headers != null) request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    String result = await response.stream.bytesToString();
    log(response.statusCode.toString());
    // if (response.statusCode == 401) {
    //   Modular.to.pushReplacementNamed(LoginScreen.routeName);
    //   return;
    // }
    log(result.toString());
    try {
      return json.decode(result);
    } catch (e) {
      return null;
    }
  }

////////////////////////// ====>get Data From Url using HTTP Packge <==== //////////////////////////////////////

  Future<Uint8List?> getDataFromUrl({
    required String? url,
    Map<String, String>? headers,
  }) async {
    try {
      if (url == null) return null;
      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/json',
        // 'Authorization': 'Bearer ${SharedPref.getUserObg().token}'
      });
      if (headers != null) request.headers.addAll(headers);
      debugPrint(request.headers.toString());

      http.StreamedResponse response = await request.send();
      return await response.stream.toBytes();
    } catch (e) {
      log(">>>>>>>>>>>>>>>::$e");
      return null;
    }
  }
}

////////////////////////// ====> Multi part Request <==== //////////////////////////////////////

class MultipartRequest extends http.MultipartRequest {
  MultipartRequest(
    super.method,
    super.url, {
    required this.onProgress,
  });
  final void Function(int bytes, int totalBytes) onProgress;

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();

    final total = contentLength;
    int bytes = 0;

    final t = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress(bytes, total);
        if (total >= bytes) {
          sink.add(data);
        }
      },
    );
    final stream = byteStream.transform(t);
    return http.ByteStream(stream);
  }
}
