part of 'chat_messages_bloc.dart';

abstract class ChatMessagesEvent extends Equatable {
  const ChatMessagesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatMessagesEvent {
  final String chatId;
  final String token;

  const LoadMessages({required this.chatId, required this.token});

  @override
  List<Object?> get props => [chatId, token];
}

class AddMessage extends ChatMessagesEvent {
  final MessageEntity message;

  const AddMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class ReceiveMessage extends ChatMessagesEvent {
  final MessageEntity message;

  const ReceiveMessage(this.message);

  @override
  List<Object?> get props => [message];
}
