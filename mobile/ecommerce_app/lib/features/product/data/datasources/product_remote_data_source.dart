import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  /// Gets all Products from the remote data source
  /// 
  /// Throws [ServerException] if server error occurs
  /// Throws [UnauthorizedException] if not authenticated
  /// Throws [ForbiddenException] if not authorized
  Future<List<ProductModel>> getAllProducts({String? token});

  /// Gets a Product by its ID from the remote data source
  /// 
  /// Throws [ServerException] if server error occurs
  /// Throws [UnauthorizedException] if not authenticated
  /// Throws [ForbiddenException] if not authorized
  Future<ProductModel> getProduct(String id, {String? token});

  /// Creates a new Product in the remote data source
  /// 
  /// Throws [ServerException] if server error occurs
  /// Throws [UnauthorizedException] if not authenticated
  /// Throws [ForbiddenException] if not authorized
  Future<ProductModel> createProduct(ProductModel product, {String? token});

  /// Updates an existing Product in the remote data source
  /// 
  /// Throws [ServerException] if server error occurs
  /// Throws [UnauthorizedException] if not authenticated
  /// Throws [ForbiddenException] if not authorized
  Future<ProductModel> updateProduct(String id, ProductModel product, {String? token});

  /// Deletes a Product from the remote data source
  /// 
  /// Throws [ServerException] if server error occurs
  /// Throws [UnauthorizedException] if not authenticated
  /// Throws [ForbiddenException] if not authorized
  Future<void> deleteProduct(String id, {String? token});
}
