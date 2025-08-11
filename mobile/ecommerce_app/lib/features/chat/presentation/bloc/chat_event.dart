import 'package:equatable/equatable.dart';
import '../../domain/entities/message_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ConnectSocket extends ChatEvent {
  final String token;

  const ConnectSocket(this.token);

  @override
  List<Object?> get props => [token];
}

class DisconnectSocket extends ChatEvent {}

class SendMessage extends ChatEvent {
  final MessageEntity message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageReceived extends ChatEvent {
  final MessageEntity message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageDelivered extends ChatEvent {
  final MessageEntity message;

  const MessageDelivered(this.message);

  @override
  List<Object?> get props => [message];
}

class InitiateChatRequest extends ChatEvent {
  final String token;
  final String userId;

  const InitiateChatRequest({
    required this.token,
    required this.userId,
  });

  @override
  List<Object?> get props => [token, userId];
}

class DeleteChatRequest extends ChatEvent {
  final String token;
  final String chatId;

  const DeleteChatRequest({
    required this.token,
    required this.chatId,
  });

  @override
  List<Object?> get props => [token, chatId];
}
