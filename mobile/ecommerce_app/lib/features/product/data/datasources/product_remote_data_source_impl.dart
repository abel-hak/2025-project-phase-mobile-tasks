import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';
import 'product_remote_data_source.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ProductRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'https://g5-flutter-learning-path-be.onrender.com/api/v2',
  });

  Map<String, String> _getHeaders(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  @override
  Future<List<ProductModel>> getAllProducts({String? token}) async {
    final response = await client.get(
      Uri.parse('$baseUrl/products'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      final List<dynamic> jsonList = jsonMap['data'];
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException(message: 'Unauthorized access');
    } else if (response.statusCode == 403) {
      throw ForbiddenException(message: 'Access forbidden');
    } else {
      throw ServerException(message: 'Server error occurred');
    }
  }

  @override
  Future<ProductModel> getProduct(String id, {String? token}) async {
    final response = await client.get(
      Uri.parse('$baseUrl/products/$id'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      return ProductModel.fromJson(jsonMap['data']);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException(message: 'Unauthorized access');
    } else if (response.statusCode == 403) {
      throw ForbiddenException(message: 'Access forbidden');
    } else {
      throw ServerException(message: 'Server error occurred');
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product, {String? token}) async {
    // Create form data for multipart request
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products'));
    
    // Add auth header if token provided
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add form fields
    request.fields['name'] = product.name;
    request.fields['description'] = product.description;
    request.fields['price'] = product.price.toString();
    
    // Add image file if a local path is provided
    if (product.imageUrl.isNotEmpty) {
      final file = File(product.imageUrl);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', file.path));
      }
    }

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final jsonMap = json.decode(response.body);
      return ProductModel.fromJson(jsonMap['data']);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException(message: 'Unauthorized access');
    } else if (response.statusCode == 403) {
      throw ForbiddenException(message: 'Access forbidden');
    } else {
      throw ServerException(message: 'Server error occurred');
    }
  }

  @override
  Future<ProductModel> updateProduct(String id, ProductModel product, {String? token}) async {
    if (id.isEmpty) {
      throw ServerException(message: 'Product ID cannot be empty');
    }
    final response = await client.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: _getHeaders(token),
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      return ProductModel.fromJson(jsonMap['data']);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException(message: 'Unauthorized access');
    } else if (response.statusCode == 403) {
      throw ForbiddenException(message: 'Access forbidden');
    } else {
      throw ServerException(message: 'Server error occurred');
    }
  }

  @override
  Future<void> deleteProduct(String id, {String? token}) async {
    if (id.isEmpty) {
      throw ServerException(message: 'Product ID cannot be empty');
    }
    final response = await client.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: _getHeaders(token),
    );

    if (response.statusCode == 204) {
      return;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException(message: 'Unauthorized access');
    } else if (response.statusCode == 403) {
      throw ForbiddenException(message: 'Access forbidden');
    } else {
      throw ServerException(message: 'Server error occurred');
    }
  }
}
