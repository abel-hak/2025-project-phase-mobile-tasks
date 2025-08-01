import '../entities/product.dart';

abstract class InsertProductUseCase {
  Future<void> execute(Product product);
}

abstract class UpdateProductUseCase {
  Future<void> execute(Product product);
}

abstract class DeleteProductUseCase {
  Future<void> execute(String productId);
}

abstract class GetProductUseCase {
  Future<Product> execute(String productId);
}
