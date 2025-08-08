import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, Auth>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final authModel = await remoteDataSource.signIn(
        email: email,
        password: password,
      );

      await sharedPreferences.setString('token', authModel.token);
      return Right(authModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Auth>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    print('AuthRepositoryImpl: Starting sign up process');
    print('AuthRepositoryImpl: Email - $email');
    print('AuthRepositoryImpl: Name - $name');

    try {
      print('AuthRepositoryImpl: Calling remote data source');
      final authModel = await remoteDataSource.signUp(
        email: email,
        password: password,
        name: name,
      );
      print('AuthRepositoryImpl: Remote data source call successful');

      print('AuthRepositoryImpl: Saving token to SharedPreferences');
      await sharedPreferences.setString('token', authModel.token);
      print('AuthRepositoryImpl: Token saved successfully');

      return Right(authModel);
    } on ServerException catch (e) {
      print('AuthRepositoryImpl: ServerException caught - ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      print('AuthRepositoryImpl: Unexpected error - $e');
      return Left(ServerFailure(message: 'Failed to sign up: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final token = sharedPreferences.getString('token');
      if (token != null) {
        await remoteDataSource.signOut(token);
      }
      await sharedPreferences.remove('token');
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Auth?>> checkAuthStatus() async {
    try {
      final token = sharedPreferences.getString('token');
      if (token == null) {
        return const Right(null);
      }

      final authModel = await remoteDataSource.checkAuthStatus(token);
      if (authModel == null) {
        await sharedPreferences.remove('token');
      }
      return Right(authModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
