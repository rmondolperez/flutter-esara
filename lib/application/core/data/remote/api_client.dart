// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:esara/application/core/data/local/secure_storage/local_secure_storage.dart';

import '../../interceptors/dio_interceptors.dart';
import '../repository.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio();
    _dio.interceptors.add(DioInterceptors());
    _dio.interceptors.add(
      LogInterceptor(
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: true,
        request: true,
        requestBody: true,
      ),
    );
  }

  final String _url = 'http://10.0.2.2:8000/api';

  Future<Either<ApiFailure, bool>> register(
    String name,
    String lastName,
    String ci,
    String noHistoriaClinica,
    String password,
    String passwordConfirmacion,
  ) async {
    try {
      var response = await _dio.post(
        '$_url/register/pacient',
        data: {
          'name': name,
          'lastname': lastName,
          'ci': ci,
          'no_historia_clinica': noHistoriaClinica,
          'password': password,
          'password_confirmation': passwordConfirmacion,
        },
      );

      if (response.statusCode == 200) {
        var jsonResult = jsonDecode(response.data);
        var code = jsonResult['data']['verification_code'];
        await _verifyUser(code);
        return const Right(true);
      }
    } on DioException catch (_) {
      return const Left(ApiFailure(code: 422, message: 'error'));
    }
    return const Left(ApiFailure(code: 422, message: "error"));
  }

  Future<Either<ApiFailure, bool>> _verifyUser(
    String verification_code,
  ) async {
    try {
      var response = await _dio.post(
        '$_url/verify/user',
        data: {
          'verification_code': verification_code,
        },
      );

      if (response.statusCode == 200) {
        return const Right(true);
      }
    } on DioException catch (_) {
      return const Left(ApiFailure(code: 422, message: 'error'));
    }
    return const Left(ApiFailure(code: 422, message: "error"));
  }

  Future<Either<ApiFailure, bool>> login(
    String ci,
    String password,
  ) async {
    try {
      var response = await _dio.post(
        '$_url/user/login',
        data: {
          'ci': ci,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        var jsonResult = jsonDecode(response.data);
        var code = jsonResult['token'];
        await _saveToken(code);
        return const Right(true);
      }
    } on DioException catch (_) {
      return const Left(ApiFailure(code: 422, message: 'error'));
    }
    return const Left(ApiFailure(code: 422, message: "error"));
  }

  Future<Either<ApiFailure, bool>> uploadMediaFile(
    String path,
  ) async {
    try {
      String _token = await Repository.localStorage.getToken() ?? '';

      FormData formData = FormData.fromMap(
          {'auth_token': _token, 'file': await MultipartFile.fromFile(path)});

      var response = await _dio.post('$_url/files', data: formData);

      if (response.statusCode == 200) {
        return const Right(true);
      }
    } on DioException catch (_) {
      return const Left(ApiFailure(code: 422, message: 'error'));
    }
    return const Left(ApiFailure(code: 422, message: "error"));
  }
}

Future<bool> _saveToken(String token) async {
  bool savedToken = await Repository.localStorage.setToken(token);
  return savedToken;
}

class ApiFailure {
  final int code;
  final String message;
  const ApiFailure({
    required this.code,
    required this.message,
  });
}
