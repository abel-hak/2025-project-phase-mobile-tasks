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
  Future<void> insertProduct(ProductModel product) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock successful insertion
      if (product.price >= 0) {
        return;
      } else {
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
