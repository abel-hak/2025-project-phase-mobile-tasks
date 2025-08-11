import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/repositories/chat_repository.dart';

part 'chat_messages_event.dart';
part 'chat_messages_state.dart';

class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final ChatRepository chatRepository;

  ChatMessagesBloc({required this.chatRepository})
      : super(ChatMessagesInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<AddMessage>(_onAddMessage);
    on<ReceiveMessage>(_onReceiveMessage);
  }

  void _onLoadMessages(
      LoadMessages event, Emitter<ChatMessagesState> emit) async {
    emit(ChatMessagesLoading());
    try {
      final messages =
          await chatRepository.getMessagesForChat(event.chatId, event.token);
      emit(ChatMessagesLoaded(messages));
    } catch (e) {
      emit(ChatMessagesError(e.toString()));
    }
  }

  void _onAddMessage(AddMessage event, Emitter<ChatMessagesState> emit) {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;
      final updatedMessages = List<MessageEntity>.from(currentState.messages)
        ..add(event.message);
      emit(ChatMessagesLoaded(updatedMessages));
    }
  }

  void _onReceiveMessage(
      ReceiveMessage event, Emitter<ChatMessagesState> emit) {
    if (state is ChatMessagesLoaded) {
      final currentState = state as ChatMessagesLoaded;
      final updatedMessages = List<MessageEntity>.from(currentState.messages)
        ..add(event.message);
      emit(ChatMessagesLoaded(updatedMessages));
    }
  }
}
