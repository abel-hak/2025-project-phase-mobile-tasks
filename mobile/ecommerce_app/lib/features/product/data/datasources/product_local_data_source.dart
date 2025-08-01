import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  /// Gets a Product by its ID from the local cache
  /// 
  /// Throws a CacheException if no cached data is present
  Future<ProductModel> getProduct(String id);

  /// Caches a Product locally
  /// 
  /// Throws a CacheException if caching fails
  Future<void> cacheProduct(ProductModel product);

  /// Updates a cached Product
  /// 
  /// Throws a CacheException if the product doesn't exist or update fails
  Future<void> updateCachedProduct(ProductModel product);

  /// Removes a Product from the cache
  /// 
  /// Throws a CacheException if the product doesn't exist or deletion fails
  Future<void> removeCachedProduct(String id);
}
