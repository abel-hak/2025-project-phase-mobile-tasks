import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth.dart';

abstract class AuthRepository {
  Future<Either<Failure, Auth>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, Auth>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, Auth?>> checkAuthStatus();
}
