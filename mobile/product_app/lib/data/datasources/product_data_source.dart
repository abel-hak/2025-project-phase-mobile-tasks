import '../../domain/entities/product_entity.dart';

abstract class ProductDataSource {
  Future<ProductEntity> insertProduct(ProductEntity product);
  Future<ProductEntity> updateProduct(ProductEntity product);
  Future<void> deleteProduct(String id);
  Future<ProductEntity> getProduct(String id);
  Future<List<ProductEntity>> getAllProducts();
}
