import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String content;
  final String type;
  final String senderId;
  final String chatId;

  const MessageEntity({
    required this.id,
    required this.content,
    required this.type,
    required this.senderId,
    required this.chatId,
  });

  @override
  List<Object?> get props => [id, content, type, senderId, chatId];
}
