import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class DeleteChat implements UseCase<void, DeleteChatParams> {
  final ChatRepository repository;

  DeleteChat(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteChatParams params) async {
    try {
      await repository.deleteChat(params.token, params.chatId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class DeleteChatParams {
  final String token;
  final String chatId;

  DeleteChatParams({required this.token, required this.chatId});
}
