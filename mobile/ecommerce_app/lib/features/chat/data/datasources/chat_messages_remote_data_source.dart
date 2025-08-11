import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../models/message_model.dart';

abstract class ChatMessagesRemoteDataSource {
  Future<List<MessageModel>> getMessages(String chatId, String token);
}

class ChatMessagesRemoteDataSourceImpl implements ChatMessagesRemoteDataSource {
  final http.Client client;

  ChatMessagesRemoteDataSourceImpl(this.client);

  @override
  Future<List<MessageModel>> getMessages(String chatId, String token) async {
    final response = await client.get(
      Uri.parse('$baseSocketUrl/api/v3/chats/$chatId/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat messages');
    }
  }
}
