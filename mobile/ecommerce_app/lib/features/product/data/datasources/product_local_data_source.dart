import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  /// Gets all Products from the local cache
  /// 
  /// Throws a CacheException if no cached data is present
  Future<List<ProductModel>> getCachedProducts();

  /// Gets a Product by its ID from the local cache
  /// 
  /// Throws a CacheException if no cached data is present
  Future<ProductModel> getCachedProduct(String id);

  /// Caches a list of Products in the local storage
  /// 
  /// Throws a CacheException if caching fails
  Future<void> cacheProducts(List<ProductModel> products);

  /// Caches a Product in the local storage
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
