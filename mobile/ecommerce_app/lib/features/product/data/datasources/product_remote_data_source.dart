import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  /// Gets a Product by its ID from the remote data source
  /// 
  /// Throws a ServerException if something goes wrong
  Future<ProductModel> getProduct(String id);

  /// Inserts a new Product into the remote data source
  /// 
  /// Throws a ServerException if something goes wrong
  Future<void> insertProduct(ProductModel product);

  /// Updates an existing Product in the remote data source
  /// 
  /// Throws a ServerException if something goes wrong
  Future<void> updateProduct(ProductModel product);

  /// Deletes a Product from the remote data source
  /// 
  /// Throws a ServerException if something goes wrong
  Future<void> deleteProduct(String id);
}
