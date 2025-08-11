import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, chatId, senderId, content, timestamp];
}
