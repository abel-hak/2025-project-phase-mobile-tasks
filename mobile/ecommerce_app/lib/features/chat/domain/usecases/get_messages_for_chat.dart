import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesForChat {
  final ChatRepository repository;

  GetMessagesForChat(this.repository);

  Future<List<MessageEntity>> call({
    required String chatId,
    required String token,
  }) {
    return repository.getMessagesForChat(chatId, token);
  }
}
