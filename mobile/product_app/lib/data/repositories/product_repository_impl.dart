import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource dataSource;

  ProductRepositoryImpl(this.dataSource);

  @override
  Future<ProductEntity> insertProduct(ProductEntity product) async {
    return await dataSource.insertProduct(product);
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    return await dataSource.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await dataSource.deleteProduct(id);
  }

  @override
  Future<ProductEntity> getProduct(String id) async {
    return await dataSource.getProduct(id);
  }

  @override
  Future<List<ProductEntity>> getAllProducts() async {
    return await dataSource.getAllProducts();
  }
}
