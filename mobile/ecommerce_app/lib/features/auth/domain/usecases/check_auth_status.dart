import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatus implements UseCase<Auth?, NoParams> {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  @override
  Future<Either<Failure, Auth?>> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}
