import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/chat_socket_data_source.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatSocketDataSource socketDataSource;
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({
    required this.socketDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> connect(String token) async {
    socketDataSource.connect(token);
  }

  @override
  Future<void> sendMessage(MessageEntity message) async {
    final model = MessageModel.fromEntity(message);
    socketDataSource.sendMessage(model);
  }

  @override
  Stream<MessageEntity> onMessageReceived() {
    return socketDataSource
        .onMessageReceived()
        .map((model) => model.toEntity());
  }

  @override
  Stream<MessageEntity> onMessageDelivered() {
    return socketDataSource
        .onMessageDelivered()
        .map((model) => model.toEntity());
  }

  @override
  Future<List<ChatEntity>> getMyChats(String token) async {
    final models = await remoteDataSource.getMyChats(token);
    return models; // Because ChatModel extends ChatEntity
  }

  @override
  Future<List<MessageEntity>> getMessagesForChat(
      String chatId, String token) async {
    final models = await remoteDataSource.getMessagesForChat(chatId, token);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> disconnect() async {
    socketDataSource.disconnect();
  }

  @override
  Future<ChatEntity> initiateChat(String token, String userId) async {
    final model = await remoteDataSource.initiateChat(token, userId);
    return model; // Because ChatModel extends ChatEntity
  }

  @override
  Future<void> deleteChat(String token, String chatId) async {
    await remoteDataSource.deleteChat(token, chatId);
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String token, String query) async {
    return await remoteDataSource.searchUsers(token, query);
  }
}
