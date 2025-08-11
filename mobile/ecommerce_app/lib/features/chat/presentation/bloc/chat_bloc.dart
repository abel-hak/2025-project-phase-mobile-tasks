import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/delete_chat.dart';
import '../../domain/usecases/initiate_chat.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final InitiateChat initiateChat;
  final DeleteChat deleteChat;

  ChatBloc({
    required this.chatRepository,
    required this.initiateChat,
    required this.deleteChat,
  }) : super(ChatInitial()) {
    on<ConnectSocket>((event, emit) {
      chatRepository.connect(event.token);

      chatRepository.onMessageReceived().listen((message) {
        add(MessageReceived(message));
      });

      chatRepository.onMessageDelivered().listen((message) {
        add(MessageDelivered(message));
      });

      emit(ChatConnected());
    });

    on<DisconnectSocket>((event, emit) {
      chatRepository.disconnect();
      emit(ChatDisconnected());
    });

    on<SendMessage>((event, emit) {
      chatRepository.sendMessage(event.message);
      emit(ChatMessageSent());
    });

    on<MessageReceived>((event, emit) {
      emit(ChatMessageReceived(event.message));
    });

    on<MessageDelivered>((event, emit) {
      emit(ChatMessageDelivered(event.message));
    });

    on<InitiateChatRequest>((event, emit) async {
      emit(ChatInitiating());
      final result = await initiateChat(InitiateChatParams(
        token: event.token,
        userId: event.userId,
      ));
      result.fold(
        (failure) => emit(ChatInitiateError(failure.message)),
        (chat) => emit(ChatInitiated(chat)),
      );
    });

    on<DeleteChatRequest>((event, emit) async {
      emit(ChatDeleting());
      final result = await deleteChat(DeleteChatParams(
        token: event.token,
        chatId: event.chatId,
      ));
      result.fold(
        (failure) => emit(ChatDeleteError(failure.message)),
        (_) => emit(ChatDeleted()),
      );
    });
  }
}
