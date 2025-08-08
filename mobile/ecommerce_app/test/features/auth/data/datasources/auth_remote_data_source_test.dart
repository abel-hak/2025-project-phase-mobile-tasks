import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:product_app/core/error/exceptions.dart';
import 'package:product_app/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:product_app/features/auth/data/models/auth_model.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'auth_remote_data_source_test.mocks.dart';

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockClient mockClient;
  const baseUrl = 'http://test.api';

  setUp(() {
    mockClient = MockClient();
    dataSource = AuthRemoteDataSourceImpl(
      client: mockClient,
      baseUrl: baseUrl,
    );
  });

  group('signIn', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    final tAuthModel = AuthModel(
      id: 'test_id',
      name: 'Test User',
      email: tEmail,
      token: 'test_token',
    );

    test('should return AuthModel when the response code is 200', () async {
      // arrange
      when(mockClient.post(
        Uri.parse('$baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': tEmail,
          'password': tPassword,
        }),
      )).thenAnswer((_) async => http.Response(
            json.encode({
              'id': 'test_id',
              'name': 'Test User',
              'email': tEmail,
              'token': 'test_token',
            }),
            200,
          ));

      // act
      final result = await dataSource.signIn(
        email: tEmail,
        password: tPassword,
      );

      // assert
      expect(result, equals(tAuthModel));
    });

    test('should throw ServerException when the response code is not 200',
        () async {
      // arrange
      when(mockClient.post(
        Uri.parse('$baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': tEmail,
          'password': tPassword,
        }),
      )).thenAnswer((_) async => http.Response(
            json.encode({'message': 'Invalid credentials'}),
            401,
          ));

      // act
      final call = dataSource.signIn;

      // assert
      expect(
        () => call(email: tEmail, password: tPassword),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('signUp', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tName = 'Test User';
    final tAuthModel = AuthModel(
      id: 'test_id',
      name: tName,
      email: tEmail,
      token: 'test_token',
    );

    test('should return AuthModel when the response code is 201', () async {
      // arrange
      when(mockClient.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': tEmail,
          'password': tPassword,
          'name': tName,
        }),
      )).thenAnswer((_) async => http.Response(
            json.encode({
              'id': 'test_id',
              'name': tName,
              'email': tEmail,
              'token': 'test_token',
            }),
            201,
          ));

      // act
      final result = await dataSource.signUp(
        email: tEmail,
        password: tPassword,
        name: tName,
      );

      // assert
      expect(result, equals(tAuthModel));
    });

    test('should throw ServerException when the response code is not 201',
        () async {
      // arrange
      when(mockClient.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': tEmail,
          'password': tPassword,
          'name': tName,
        }),
      )).thenAnswer((_) async => http.Response(
            json.encode({'message': 'Email already exists'}),
            400,
          ));

      // act
      final call = dataSource.signUp;

      // assert
      expect(
        () => call(
          email: tEmail,
          password: tPassword,
          name: tName,
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('signOut', () {
    const tToken = 'test_token';

    test('should complete successfully when the response code is 200', () async {
      // arrange
      when(mockClient.post(
        Uri.parse('$baseUrl/auth/signout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tToken',
        },
      )).thenAnswer((_) async => http.Response('', 200));

      // act
      await dataSource.signOut(tToken);

      // assert
      verify(mockClient.post(
        Uri.parse('$baseUrl/auth/signout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tToken',
        },
      ));
    });

    test('should throw ServerException when the response code is not 200',
        () async {
      // arrange
      when(mockClient.post(
        Uri.parse('$baseUrl/auth/signout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tToken',
        },
      )).thenAnswer((_) async => http.Response(
            json.encode({'message': 'Invalid token'}),
            401,
          ));

      // act
      final call = dataSource.signOut;

      // assert
      expect(
        () => call(tToken),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('checkAuthStatus', () {
    const tToken = 'test_token';
    final tAuthModel = AuthModel(
      id: 'test_id',
      name: 'Test User',
      email: 'test@example.com',
      token: tToken,
    );

    test('should return AuthModel when the response code is 200', () async {
      // arrange
      when(mockClient.get(
        Uri.parse('$baseUrl/auth/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tToken',
        },
      )).thenAnswer((_) async => http.Response(
            json.encode({
              'id': 'test_id',
              'name': 'Test User',
              'email': 'test@example.com',
            }),
            200,
          ));

      // act
      final result = await dataSource.checkAuthStatus(tToken);

      // assert
      expect(result, equals(tAuthModel));
    });

    test('should return null when the response code is 401', () async {
      // arrange
      when(mockClient.get(
        Uri.parse('$baseUrl/auth/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tToken',
        },
      )).thenAnswer((_) async => http.Response('', 401));

      // act
      final result = await dataSource.checkAuthStatus(tToken);

      // assert
      expect(result, isNull);
    });

    test('should throw ServerException when the response code is not 200 or 401',
        () async {
      // arrange
      when(mockClient.get(
        Uri.parse('$baseUrl/auth/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tToken',
        },
      )).thenAnswer((_) async => http.Response(
            json.encode({'message': 'Server error'}),
            500,
          ));

      // act
      final call = dataSource.checkAuthStatus;

      // assert
      expect(
        () => call(tToken),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
