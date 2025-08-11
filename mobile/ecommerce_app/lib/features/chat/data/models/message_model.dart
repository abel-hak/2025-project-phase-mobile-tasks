import '../../domain/entities/message_entity.dart';

class MessageModel {
  final String id;
  final String content;
  final String type;
  final UserModel sender;
  final ChatModel chat;

  MessageModel({
    required this.id,
    required this.content,
    required this.type,
    required this.sender,
    required this.chat,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'],
      content: json['content'],
      type: json['type'],
      sender: UserModel.fromJson(json['sender']),
      chat: ChatModel.fromJson(json['chat']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chat.id,
      'content': content,
      'type': type,
    };
  }

  /// ✅ This should be a static method
  static MessageModel fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      content: entity.content,
      type: entity.type,
      sender: UserModel(
        id: entity.senderId,
        name: '',
        email: '',
      ),
      chat: ChatModel(id: entity.chatId),
    );
  }

  /// ✅ Converts model to entity
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      content: content,
      type: type,
      senderId: sender.id,
      chatId: chat.id,
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class ChatModel {
  final String id;

  ChatModel({required this.id});

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['_id'],
    );
  }
}
