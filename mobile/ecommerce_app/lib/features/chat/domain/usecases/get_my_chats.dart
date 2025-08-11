import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class GetMyChats {
  final ChatRepository repository;

  GetMyChats(this.repository);

  Future<List<ChatEntity>> call(String token) {
    return repository.getMyChats(token);
  }
}
