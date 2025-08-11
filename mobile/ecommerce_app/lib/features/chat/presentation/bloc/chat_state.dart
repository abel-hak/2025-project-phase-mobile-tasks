import 'package:equatable/equatable.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatConnected extends ChatState {}

class ChatDisconnected extends ChatState {}

class ChatMessageSent extends ChatState {}

class ChatMessageReceived extends ChatState {
  final MessageEntity message;

  const ChatMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatMessageDelivered extends ChatState {
  final MessageEntity message;

  const ChatMessageDelivered(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatInitiating extends ChatState {}

class ChatInitiated extends ChatState {
  final ChatEntity chat;

  const ChatInitiated(this.chat);

  @override
  List<Object?> get props => [chat];
}

class ChatInitiateError extends ChatState {
  final String message;

  const ChatInitiateError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatDeleting extends ChatState {}

class ChatDeleted extends ChatState {}

class ChatDeleteError extends ChatState {
  final String message;

  const ChatDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
