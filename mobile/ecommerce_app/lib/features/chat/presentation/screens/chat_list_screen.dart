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
import '../widgets/chat_list_item.dart';
import '../widgets/user_status_list.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final token = authState.auth.token;
        context.read<ChatListBloc>().add(LoadChatList(token));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
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
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xff498CF0),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () => _showAddChatDialog(context),
            ),
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context
                      .read<ChatListBloc>()
                      .add(LoadChatList(authState.auth.token));
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // User status list
            Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xff498CF0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(33),
                  bottomRight: Radius.circular(33),
                ),
              ),
              child: const UserStatusList(),
            ),
            // Add gap between status list and chat list
            const SizedBox(height: 8),

            // Chat list
            Expanded(
              child: BlocBuilder<ChatListBloc, ChatListState>(
                builder: (context, state) {
                  if (state is ChatListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatListLoaded) {
                    final chats = state.chats;

                    if (chats.isEmpty) {
                      return const Center(child: Text('No chats found'));
                    }

                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        final authState = context.read<AuthBloc>().state;
                        if (authState is! AuthAuthenticated) {
                          return const SizedBox.shrink();
                        }

                        // Show the other user's name based on who is logged in
                        final currentUserId = authState.auth.id;
                        final receiverName = chat.user1Id == currentUserId
                            ? chat.user2Name
                            : chat.user1Name;

                        // Assign an avatar color based on index
                        final avatarImages = [
                          'user7.png',
                          'user8.png',
                          'user9.png',
                        ];
                        final avatarImage = avatarImages[index % avatarImages.length];

                        return ChatListItem(
                          name: receiverName,
                          message: 'Tap to view chat',
                          time:
                              '2m ago', // We'll implement real timestamps later
                          avatarImage: avatarImage,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailScreen(
                                  chatId: chat.id,
                                  receiverName: receiverName,
                                  token: authState.auth.token,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }

                  if (state is ChatListError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddChatDialog(BuildContext context) {
    final userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                hintText: 'Enter the user ID (e.g., 66c730840740f8c2bae904e0)',
                helperText: 'You need the exact user ID to start a chat',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (userIdController.text.isNotEmpty) {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<ChatBloc>().add(
                        InitiateChatRequest(
                          token: authState.auth.token,
                          userId: userIdController.text,
                        ),
                      );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }
}
