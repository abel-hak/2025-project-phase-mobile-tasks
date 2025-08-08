import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_app/core/error/exceptions.dart';
import 'package:product_app/core/error/failures.dart';
import 'package:product_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:product_app/features/auth/data/models/auth_model.dart';
import 'package:product_app/features/auth/data/repositories/auth_repository_impl.dart';

@GenerateNiceMocks([
  MockSpec<AuthRemoteDataSource>(),
  MockSpec<SharedPreferences>(),
])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockSharedPreferences = MockSharedPreferences();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      sharedPreferences: mockSharedPreferences,
    );
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tName = 'Test User';
  const tToken = 'test_token';

  final tAuthModel = AuthModel(
    id: 'test_id',
    name: tName,
    email: tEmail,
    token: tToken,
  );

  group('signIn', () {
    test('should return remote data when the call is successful', () async {
      // arrange
      when(mockRemoteDataSource.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => tAuthModel);
      when(mockSharedPreferences.setString('token', tToken))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.signIn(
        email: tEmail,
        password: tPassword,
      );

      // assert
      verify(mockRemoteDataSource.signIn(
        email: tEmail,
        password: tPassword,
      ));
      verify(mockSharedPreferences.setString('token', tToken));
      expect(result, equals(Right(tAuthModel)));
    });

    test('should return server failure when the call is unsuccessful', () async {
      // arrange
      when(mockRemoteDataSource.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(ServerException(message: 'Server error'));

      // act
      final result = await repository.signIn(
        email: tEmail,
        password: tPassword,
      );

      // assert
      verify(mockRemoteDataSource.signIn(
        email: tEmail,
        password: tPassword,
      ));
      expect(result, equals(Left(ServerFailure(message: 'Server error'))));
    });
  });

  group('signUp', () {
    test('should return remote data when the call is successful', () async {
      // arrange
      when(mockRemoteDataSource.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      )).thenAnswer((_) async => tAuthModel);
      when(mockSharedPreferences.setString('token', tToken))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.signUp(
        email: tEmail,
        password: tPassword,
        name: tName,
      );

      // assert
      verify(mockRemoteDataSource.signUp(
        email: tEmail,
        password: tPassword,
        name: tName,
      ));
      verify(mockSharedPreferences.setString('token', tToken));
      expect(result, equals(Right(tAuthModel)));
    });

    test('should return server failure when the call is unsuccessful', () async {
      // arrange
      when(mockRemoteDataSource.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
        name: anyNamed('name'),
      )).thenThrow(ServerException(message: 'Server error'));

      // act
      final result = await repository.signUp(
        email: tEmail,
        password: tPassword,
        name: tName,
      );

      // assert
      verify(mockRemoteDataSource.signUp(
        email: tEmail,
        password: tPassword,
        name: tName,
      ));
      expect(result, equals(Left(ServerFailure(message: 'Server error'))));
    });
  });

  group('signOut', () {
    test('should return unit when the call is successful', () async {
      // arrange
      when(mockSharedPreferences.getString('token'))
          .thenAnswer((_) => tToken);
      when(mockRemoteDataSource.signOut(any))
          .thenAnswer((_) async => null);
      when(mockSharedPreferences.remove('token'))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.signOut();

      // assert
      verify(mockSharedPreferences.getString('token'));
      verify(mockRemoteDataSource.signOut(tToken));
      verify(mockSharedPreferences.remove('token'));
      expect(result, equals(const Right(null)));
    });

    test('should return server failure when the call is unsuccessful', () async {
      // arrange
      when(mockSharedPreferences.getString('token'))
          .thenAnswer((_) => tToken);
      when(mockRemoteDataSource.signOut(any))
          .thenThrow(ServerException(message: 'Server error'));

      // act
      final result = await repository.signOut();

      // assert
      verify(mockSharedPreferences.getString('token'));
      verify(mockRemoteDataSource.signOut(tToken));
      expect(result, equals(Left(ServerFailure(message: 'Server error'))));
    });

    test('should return unit when no token is stored', () async {
      // arrange
      when(mockSharedPreferences.getString('token'))
          .thenAnswer((_) => null);

      // act
      final result = await repository.signOut();

      // assert
      verify(mockSharedPreferences.getString('token'));
      verifyNever(mockRemoteDataSource.signOut(any));
      expect(result, equals(const Right(null)));
    });
  });

  group('checkAuthStatus', () {
    test('should return auth model when token is valid', () async {
      // arrange
      when(mockSharedPreferences.getString('token'))
          .thenAnswer((_) => tToken);
      when(mockRemoteDataSource.checkAuthStatus(any))
          .thenAnswer((_) async => tAuthModel);

      // act
      final result = await repository.checkAuthStatus();

      // assert
      verify(mockSharedPreferences.getString('token'));
      verify(mockRemoteDataSource.checkAuthStatus(tToken));
      expect(result, equals(Right(tAuthModel)));
    });

    test('should return null when no token is stored', () async {
      // arrange
      when(mockSharedPreferences.getString('token'))
          .thenAnswer((_) => null);

      // act
      final result = await repository.checkAuthStatus();

      // assert
      verify(mockSharedPreferences.getString('token'));
      verifyNever(mockRemoteDataSource.checkAuthStatus(any));
      expect(result, equals(const Right(null)));
    });

    test('should return null and remove token when token is invalid', () async {
      // arrange
      when(mockSharedPreferences.getString('token'))
          .thenAnswer((_) => tToken);
      when(mockRemoteDataSource.checkAuthStatus(any))
          .thenAnswer((_) async => null);
      when(mockSharedPreferences.remove('token'))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.checkAuthStatus();

      // assert
      verify(mockSharedPreferences.getString('token'));
      verify(mockRemoteDataSource.checkAuthStatus(tToken));
      verify(mockSharedPreferences.remove('token'));
      expect(result, equals(const Right(null)));
    });

    test('should return server failure when the call fails', () async {
      // arrange
      when(mockSharedPreferences.getString('token'))
          .thenAnswer((_) => tToken);
      when(mockRemoteDataSource.checkAuthStatus(any))
          .thenThrow(ServerException(message: 'Server error'));

      // act
      final result = await repository.checkAuthStatus();

      // assert
      verify(mockSharedPreferences.getString('token'));
      verify(mockRemoteDataSource.checkAuthStatus(tToken));
      expect(result, equals(Left(ServerFailure(message: 'Server error'))));
    });
  });
}
