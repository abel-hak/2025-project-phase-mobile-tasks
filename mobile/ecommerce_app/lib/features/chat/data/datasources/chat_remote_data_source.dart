import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart' as chat_model;
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<chat_model.ChatModel>> getMyChats(String token);
  Future<List<MessageModel>> getMessagesForChat(String chatId, String token);
  Future<chat_model.ChatModel> initiateChat(String token, String userId);
  Future<void> deleteChat(String token, String chatId);
  Future<List<Map<String, dynamic>>> searchUsers(String token, String query);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ChatRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<List<chat_model.ChatModel>> getMyChats(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/chats'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data = json['data'];
      return data.map((chat) => chat_model.ChatModel.fromJson(chat)).toList();
    } else {
      throw Exception('❌ Failed to load chats: ${response.statusCode}');
    }
  }

  @override
  Future<List<MessageModel>> getMessagesForChat(
      String chatId, String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/chats/$chatId/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data = json['data'];
      return data.map((message) => MessageModel.fromJson(message)).toList();
    } else {
      throw Exception('❌ Failed to load messages: ${response.statusCode}');
    }
  }

  @override
  Future<chat_model.ChatModel> initiateChat(String token, String userId) async {
    print('🚀 Initiating chat with userId: $userId');
    final response = await client.post(
      Uri.parse('$baseUrl/chats'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
      }),
    );

    print('📡 Chat initiation response status: ${response.statusCode}');
    print('📡 Chat initiation response body: ${response.body}');

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final chat = chat_model.ChatModel.fromJson(json['data']);
      print('✅ Chat initiated successfully: ${chat.id}');
      return chat;
    } else {
      print(
          '❌ Failed to initiate chat: ${response.statusCode} - ${response.body}');
      throw Exception(
          'Failed to initiate chat: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Future<void> deleteChat(String token, String chatId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/chats/$chatId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('❌ Failed to delete chat: ${response.statusCode}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(
      String token, String query) async {
    print('🔍 Searching users with query: $query');
    final response = await client.get(
      Uri.parse('$baseUrl/users/search?query=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('📡 User search response status: ${response.statusCode}');
    print('📡 User search response body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      return data.cast<Map<String, dynamic>>();
    } else {
      print(
          '❌ Failed to search users: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to search users');
    }
  }
}
