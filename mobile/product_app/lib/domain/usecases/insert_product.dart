import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class InsertProduct {
  final ProductRepository repository;

  InsertProduct(this.repository);

  Future<ProductEntity> call(ProductEntity product) async {
    return await repository.insertProduct(product);
  }
}
