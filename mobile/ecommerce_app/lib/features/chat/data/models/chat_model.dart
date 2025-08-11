import '../../domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.user1Id,
    required super.user2Id,
    required super.user1Name,
    required super.user2Name,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['_id'],
      user1Id: json['user1']['_id'],
      user2Id: json['user2']['_id'],
      user1Name: json['user1']['name'],
      user2Name: json['user2']['name'],
    );
  }
}
