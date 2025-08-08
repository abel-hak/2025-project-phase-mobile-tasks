import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../models/auth_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({required this.client, String? baseUrl})
      : baseUrl = baseUrl ??
            'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v2' {
    print('[AuthRemoteDataSourceImpl] Constructed with baseUrl: $baseUrl');
  }

  @override
  Future<void> signOut(String token) async {
    print('RemoteDataSource: User signed out (token: $token)');
  }

  @override
  Future<AuthModel?> checkAuthStatus(String token) async {
    print(
        'RemoteDataSource: Checking auth status with token: ${token.substring(0, 10)}...');
    try {
      final userResponse = await client.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
          'RemoteDataSource: Auth status check response: ${userResponse.statusCode}');
      if (userResponse.statusCode != 200) {
        print(
            'RemoteDataSource: Auth status check failed: ${userResponse.statusCode}');
        return null;
      }

      final responseData = json.decode(userResponse.body);
      if (responseData['statusCode'] != 200 || responseData['data'] == null) {
        print('RemoteDataSource: Invalid response format or error');
        return null;
      }

      final userData = responseData['data'];
      return AuthModel.fromJson({
        'id': userData['_id'] ?? userData['id'],
        'name': userData['name'],
        'email': userData['email'],
        'token': token,
      });
    } catch (e) {
      print('RemoteDataSource: Error checking auth status: $e');
      return null;
    }
  }

  @override
  Future<AuthModel> signIn({
    required String email,
    required String password,
  }) async {
    print('RemoteDataSource: Starting sign in process');
    print('RemoteDataSource: Email - $email');
    print('RemoteDataSource: BaseUrl - $baseUrl');

    try {
      final loginUrl = Uri.parse('$baseUrl/auth/login');
      final loginBody = json.encode({
        'email': email,
        'password': password,
      });

      final loginResponse = await client.post(
        loginUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: loginBody,
      );

      print('RemoteDataSource: Login status - ${loginResponse.statusCode}');
      print('RemoteDataSource: Login response - ${loginResponse.body}');

      if (loginResponse.statusCode != 201 && loginResponse.statusCode != 200) {
        throw ServerException(
          message:
              'Failed to sign in (${loginResponse.statusCode}): ${loginResponse.body}',
        );
      }

      final responseData = json.decode(loginResponse.body);
      if (responseData['statusCode'] != 201 || responseData['data'] == null) {
        throw ServerException(message: 'Invalid response format or error');
      }

      final token = responseData['data']['access_token'];

      final userResponse = await client.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (userResponse.statusCode != 200) {
        throw ServerException(message: 'Failed to get user details');
      }

      final userData = json.decode(userResponse.body);
      if (userData['statusCode'] != 200 || userData['data'] == null) {
        throw ServerException(message: 'Invalid user data response');
      }

      final user = userData['data'];
      return AuthModel.fromJson({
        'id': user['_id'] ?? user['id'],
        'name': user['name'],
        'email': user['email'],
        'token': token,
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<AuthModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final client = http.Client();
      final registerUrl = Uri.parse('$baseUrl/auth/register');
      final loginUrl = Uri.parse('$baseUrl/auth/login');
      final userDetailsUrl = Uri.parse('$baseUrl/users/me');

      // Step 1 - Register
      final registerBody = json.encode({
        'name': name,
        'email': email,
        'password': password,
      });

      final registerResponse = await client.post(
        registerUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: registerBody,
      );

      if (registerResponse.statusCode != 201 &&
          registerResponse.statusCode != 200) {
        throw ServerException(
            message:
                'Failed to register user (${registerResponse.statusCode}): ${registerResponse.body}');
      }

      final registerData = json.decode(registerResponse.body);
      final userData = registerData['data'];
      final id = userData['_id'] ?? userData['id'];

      if (id == null) {
        throw ServerException(message: 'User ID missing in register response');
      }

      // Step 2 - Login
      final loginBody = json.encode({
        'email': email,
        'password': password,
      });

      final loginResponse = await client.post(
        loginUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: loginBody,
      );

      if (loginResponse.statusCode != 201 && loginResponse.statusCode != 200) {
        throw ServerException(
            message:
                'Failed to login after registration (${loginResponse.statusCode}): ${loginResponse.body}');
      }

      final loginData = json.decode(loginResponse.body);
      final token = loginData['data']['access_token'];

      if (token == null || token is! String) {
        throw ServerException(message: 'Invalid or missing token in login');
      }

      // Step 3 - Get user details
      final userDetailsResponse = await client.get(
        userDetailsUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (userDetailsResponse.statusCode != 200) {
        throw ServerException(
            message:
                'Failed to get user details (${userDetailsResponse.statusCode}): ${userDetailsResponse.body}');
      }

      final userDetailsData = json.decode(userDetailsResponse.body);
      final user = userDetailsData['data'];

      final modelJson = {
        'id': user['_id'] ?? user['id'],
        'name': user['name'],
        'email': user['email'],
        'token': token,
      };

      print('💥 Constructing AuthModel from: $modelJson');

      return AuthModel.fromJson(modelJson);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Sign-up failed: ${e.toString()}');
    }
  }
}
