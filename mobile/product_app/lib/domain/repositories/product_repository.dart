import '../entities/product.dart';

abstract class ProductRepository {
  Future<void> insertProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String productId);
  Future<Product> getProduct(String productId);
}
