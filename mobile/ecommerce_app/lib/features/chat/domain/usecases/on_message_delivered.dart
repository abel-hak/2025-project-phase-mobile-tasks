import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class OnMessageDelivered {
  final ChatRepository repository;

  OnMessageDelivered(this.repository);

  Stream<MessageEntity> call() {
    return repository.onMessageDelivered();
  }
}
