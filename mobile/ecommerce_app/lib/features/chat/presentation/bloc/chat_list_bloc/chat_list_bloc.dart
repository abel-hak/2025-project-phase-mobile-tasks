import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_my_chats.dart';
import 'chat_list_event.dart';
import 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetMyChats getMyChats;

  ChatListBloc(this.getMyChats) : super(ChatListInitial()) {
    on<LoadChatList>((event, emit) async {
      emit(ChatListLoading());
      try {
        final chats = await getMyChats(event.token);
        emit(ChatListLoaded(chats));
      } catch (e) {
        emit(ChatListError(e.toString()));
      }
    });
  }
}
