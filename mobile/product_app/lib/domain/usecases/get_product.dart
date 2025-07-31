import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProduct {
  final ProductRepository repository;

  GetProduct(this.repository);

  Future<ProductEntity> call(String id) async {
    return await repository.getProduct(id);
  }
}

class GetAllProducts {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  Future<List<ProductEntity>> call() async {
    return await repository.getAllProducts();
  }
}
