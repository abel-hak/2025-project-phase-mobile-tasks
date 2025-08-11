import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<void> connect(String token);
  Future<void> disconnect();
  Future<void> sendMessage(MessageEntity message);
  Stream<MessageEntity> onMessageReceived();
  Stream<MessageEntity> onMessageDelivered();

  Future<List<ChatEntity>> getMyChats(String token);
  Future<List<MessageEntity>> getMessagesForChat(String chatId, String token);
  Future<ChatEntity> initiateChat(String token, String userId);
  Future<void> deleteChat(String token, String chatId);
  Future<List<Map<String, dynamic>>> searchUsers(String token, String query);
}
