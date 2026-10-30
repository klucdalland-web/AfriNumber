import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/api_exception.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile.dart';
import '../../domaine/profile_repository.dart';

class ProfilRepositoryImplement implements ProfileRepository {
  ProfilRepositoryImplement(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<UserModel> getProfile() async {
    final rawData = await _request(_remote.getProfile);
    if (kDebugMode) {
      print('=== Profile API Raw Response ===');
      print(rawData);
    }
    final userModel = UserModel.fromJson(rawData);
    if (kDebugMode) {
      print('=== Parsed UserModel Object ===');
      print(userModel.toString());
    }
    return userModel;
  }

  Future<T> _request<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      if (error.error case final ApiException apiException) {
        throw apiException;
      }
      rethrow;
    }
  }
}
