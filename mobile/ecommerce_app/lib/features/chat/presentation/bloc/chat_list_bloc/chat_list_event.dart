import 'package:equatable/equatable.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatList extends ChatListEvent {
  final String token;

  const LoadChatList(this.token);

  @override
  List<Object?> get props => [token];
}
