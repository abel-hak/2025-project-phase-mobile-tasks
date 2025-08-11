import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../bloc/chat_list_bloc/chat_list_bloc.dart';
import '../bloc/chat_list_bloc/chat_list_event.dart';
import '../bloc/chat_list_bloc/chat_list_state.dart';

import './chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Load chats when screen opens
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final token = authState.auth.token;
      print('📦 Loading chats with token: $token');
      context.read<ChatListBloc>().add(LoadChatList(token));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3FD),
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFEEF3FD),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                final token = authState.auth.token;
                print('📦 Refreshing chats with token: $token');
                context.read<ChatListBloc>().add(LoadChatList(token));
              }
            },
          ),
        ],
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatInitiating) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Initiating chat...')),
            );
          } else if (state is ChatInitiated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chat started successfully!')),
            );
            // Refresh chat list after successful initiation
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              context
                  .read<ChatListBloc>()
                  .add(LoadChatList(authState.auth.token));
            }
          } else if (state is ChatInitiateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child:
            BlocBuilder<ChatListBloc, ChatListState>(builder: (context, state) {
          if (state is ChatListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatListLoaded) {
            final chats = state.chats;

            if (chats.isEmpty) {
              return const Center(child: Text("No chats found."));
            }

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final authState = context.read<AuthBloc>().state;
                if (authState is! AuthAuthenticated)
                  return const SizedBox.shrink();

                // Show the other user's name based on who is logged in
                final currentUserId = authState.auth.id;
                final receiverName = chat.user1Id == currentUserId
                    ? chat
                        .user2Name // If user1 is current user, show user2's name
                    : chat
                        .user1Name; // If user2 is current user, show user1's name

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          chatId: chat.id,
                          receiverName:
                              receiverName, // Use correct receiver name
                          token: authState.auth.token,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[300],
                    child: Text(
                      receiverName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    receiverName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Tap to view chat'),
                );
              },
            );
          } else if (state is ChatListError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const SizedBox.shrink();
          }
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showNewChatDialog(context);
        },
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('New Chat'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Start New Chat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  hintText:
                      'Enter the user ID (e.g., 66c730840740f8c2bae904e0)',
                  helperText: 'You need the exact user ID to start a chat',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (userIdController.text.isEmpty) return;

                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<ChatBloc>().add(
                        InitiateChatRequest(
                          token: authState.auth.token,
                          userId: userIdController.text.trim(),
                        ),
                      );
                }
                Navigator.pop(context);
              },
              child: const Text('Start Chat'),
            ),
          ],
        );
      },
    );
  }
}
