import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/message_entity.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_messages/chat_messages_bloc.dart';
import '../bloc/chat_state.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String receiverName;
  final String token;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.receiverName,
    required this.token,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String _currentUserId;
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();

    // Get user ID from AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.auth.id;
      _chatBloc = context.read<ChatBloc>();

      // Connect socket
      print('🔌 Connecting socket with token: ${widget.token}');
      _chatBloc.add(ConnectSocket(widget.token));
    }

    // Fetch chat messages from API
    context.read<ChatMessagesBloc>().add(
          LoadMessages(chatId: widget.chatId, token: widget.token),
        );

    // Listen for socket messages
    final chatBloc = context.read<ChatBloc>();
    chatBloc.stream.listen((state) {
      if (state is ChatMessageReceived || state is ChatMessageDelivered) {
        final message = (state as dynamic).message as MessageEntity;
        if (message.chatId == widget.chatId) {
          context.read<ChatMessagesBloc>().add(ReceiveMessage(message));
          _scrollToBottom();
        }
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final newMessage = MessageEntity(
        id: '',
        content: text,
        chatId: widget.chatId,
        senderId: _currentUserId,
        type: 'text',
      );

      context.read<ChatBloc>().add(SendMessage(newMessage));
      context.read<ChatMessagesBloc>().add(AddMessage(newMessage));
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // Disconnect socket
    _chatBloc.add(DisconnectSocket());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receiverName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text("Chat",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        leading: const BackButton(color: Colors.black),
        actions: const [
          Icon(Icons.call_outlined, color: Colors.black),
          SizedBox(width: 16),
          Icon(Icons.videocam_outlined, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
              builder: (context, state) {
                if (state is ChatMessagesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatMessagesLoaded) {
                  final messages = state.messages;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == _currentUserId;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFF4463F0)
                                : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg.content,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is ChatMessagesError) {
                  return Center(child: Text("Error: ${state.message}"));
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.emoji_emotions_outlined, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Write your message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.mic_none_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon:
                      const Icon(Icons.send_rounded, color: Color(0xFF4463F0)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
