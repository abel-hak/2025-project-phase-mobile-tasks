import '../../domain/entities/auth.dart';

class AuthModel extends Auth {
  const AuthModel({
    required super.id,
    required super.name,
    required super.email,
    required super.token,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    // Fallback to _id if id is missing
    final id = json['id'] ?? json['_id'];
    final name = json['name'];
    final email = json['email'];
    final token = json['token'];

    // Debug print statements (optional but helpful)
    if (id == null) print('DEBUG: Missing "id" or "_id" field');
    if (name == null) print('DEBUG: Missing "name" field');
    if (email == null) print('DEBUG: Missing "email" field');
    if (token == null) print('DEBUG: Missing "token" field');

    if (id == null || name == null || email == null || token == null) {
      throw Exception(
        '❌ Missing required fields in AuthModel.fromJson: $json',
      );
    }

    return AuthModel(
      id: id as String,
      name: name as String,
      email: email as String,
      token: token as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
