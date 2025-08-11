import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class InitiateChat implements UseCase<ChatEntity, InitiateChatParams> {
  final ChatRepository repository;

  InitiateChat(this.repository);

  @override
  Future<Either<Failure, ChatEntity>> call(InitiateChatParams params) async {
    try {
      final chat = await repository.initiateChat(params.token, params.userId);
      return Right(chat);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class InitiateChatParams {
  final String token;
  final String userId;

  InitiateChatParams({required this.token, required this.userId});
}
