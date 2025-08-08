import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../models/auth_model.dart';

const baseApiUrl =
    'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v2';

abstract class AuthRemoteDataSource {
  Future<AuthModel?> checkAuthStatus(String token);

  Future<AuthModel> signIn({
    required String email,
    required String password,
  });

  Future<AuthModel> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<void> signOut(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({required this.client, this.baseUrl = baseApiUrl});

  @override
  Future<AuthModel?> checkAuthStatus(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final user = data['data'];

      return AuthModel(
        id: user['_id'] ?? user['id'],
        name: user['name'],
        email: user['email'],
        token: token,
      );
    } else if (response.statusCode == 401) {
      return null;
    } else {
      throw ServerException(message: 'Failed to check auth status');
    }
  }

  @override
  Future<AuthModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final loginData = json.decode(response.body);
      final token = loginData['data']['access_token'];

      // Fetch user details
      final userResponse = await client.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (userResponse.statusCode == 200) {
        final responseData = json.decode(userResponse.body);
        final userData = responseData['data'];

        if (userData == null) {
          // If user data is not available, create AuthModel with token and email
          return AuthModel(
            id: '', // Use empty string as fallback
            name: email.split('@')[0], // Use email prefix as fallback name
            email: email,
            token: token,
          );
        }

        return AuthModel(
          id: userData['_id'] ?? userData['id'] ?? '',
          name: userData['name'] ?? email.split('@')[0],
          email: userData['email'] ?? email,
          token: token,
        );
      } else {
        throw ServerException(message: 'Failed to fetch user info');
      }
    } else {
      throw ServerException(message: 'Failed to sign in');
    }
  }

  @override
  Future<AuthModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // Step 1: Register user
    final registerResponse = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (registerResponse.statusCode != 201) {
      throw ServerException(message: 'Failed to register user');
    }

    // Step 2: Log in to get token
    final loginResponse = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (loginResponse.statusCode != 201 && loginResponse.statusCode != 200) {
      throw ServerException(message: 'Failed to login after registration');
    }

    final loginData = json.decode(loginResponse.body);
    final token = loginData['data']['access_token'];

    // Step 3: Fetch user details
    final userResponse = await client.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (userResponse.statusCode != 200) {
      throw ServerException(message: 'Failed to fetch user details');
    }

    final responseData = json.decode(userResponse.body);
    final userData = responseData['data'];

    if (userData == null) {
      // If user data is not available, create AuthModel with token only
      return AuthModel(
        id: '', // Use empty string or generate a temporary ID
        name: name, // Use the name provided during signup
        email: email, // Use the email provided during signup
        token: token,
      );
    }

    return AuthModel(
      id: userData['_id'] ?? userData['id'] ?? '',
      name: userData['name'] ?? name,
      email: userData['email'] ?? email,
      token: token,
    );
  }

  @override
  Future<void> signOut(String token) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/signout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw ServerException(message: 'Failed to sign out');
    }
  }
}
