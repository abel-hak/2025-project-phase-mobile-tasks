import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class OnMessageReceived {
  final ChatRepository repository;

  OnMessageReceived(this.repository);

  Stream<MessageEntity> call() {
    return repository.onMessageReceived();
  }
}
