import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';
import 'product_local_data_source.dart';

const CACHED_PRODUCTS_KEY = 'CACHED_PRODUCTS';

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProductLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    final jsonString = await sharedPreferences.getString('CACHED_PRODUCTS');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw CacheException();
    }
  }

  @override
  Future<ProductModel> getCachedProduct(String id) async {
    final jsonString = sharedPreferences.getString('$CACHED_PRODUCTS_KEY:$id');
    if (jsonString != null) {
      return ProductModel.fromJson(json.decode(jsonString));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final List<Map<String, dynamic>> jsonList = products.map((product) => product.toJson()).toList();
    await sharedPreferences.setString('CACHED_PRODUCTS', json.encode(jsonList));
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    final jsonString = json.encode(product.toJson());
    final success = await sharedPreferences.setString(
      '$CACHED_PRODUCTS_KEY:${product.id}',
      jsonString,
    );
    if (!success) {
      throw CacheException();
    }
  }

  @override
  Future<void> updateCachedProduct(ProductModel product) async {
    if (!sharedPreferences.containsKey('$CACHED_PRODUCTS_KEY:${product.id}')) {
      throw CacheException();
    }
    final jsonString = json.encode(product.toJson());
    final success = await sharedPreferences.setString(
      '$CACHED_PRODUCTS_KEY:${product.id}',
      jsonString,
    );
    if (!success) {
      throw CacheException();
    }
  }

  @override
  Future<void> removeCachedProduct(String id) async {
    if (!sharedPreferences.containsKey('$CACHED_PRODUCTS_KEY:$id')) {
      throw CacheException();
    }
    final success = await sharedPreferences.remove('$CACHED_PRODUCTS_KEY:$id');
    if (!success) {
      throw CacheException();
    }
  }
}
