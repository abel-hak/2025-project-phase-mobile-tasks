import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';
import 'product_remote_data_source.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ProductRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'https://mock-ecommerce-api.dev/v1',
  });

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final response = await client.get(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<ProductModel> getProduct(String id) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock successful response
      if (id == '1') {
        return ProductModel(
          id: '1',
          name: 'Mock Product',
          description: 'A mock product for testing',
          price: 99.99,
          imageUrl: 'mock.jpg',
          category: 'Test',
          rating: 4.5,
        );
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> createProduct(ProductModel product) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock successful update
      if (product.id.isNotEmpty) {
        return;
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock successful deletion
      if (id.isNotEmpty) {
        return;
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
