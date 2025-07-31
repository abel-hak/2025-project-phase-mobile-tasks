import 'data/datasources/product_data_source.dart';
import 'data/datasources/product_data_source_memory.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/usecases/delete_product.dart';
import 'domain/usecases/get_product.dart';
import 'domain/usecases/insert_product.dart';
import 'domain/usecases/update_product.dart';

class Injection {
  static final Injection instance = Injection._internal();
  
  factory Injection() {
    return instance;
  }

  Injection._internal();

  // Data sources
  late final ProductDataSource _productDataSource = InMemoryProductDataSource();

  // Repositories
  late final ProductRepository _productRepository = ProductRepositoryImpl(_productDataSource);

  // Use cases
  late final GetProduct getProduct = GetProduct(_productRepository);
  late final GetAllProducts getAllProducts = GetAllProducts(_productRepository);
  late final InsertProduct insertProduct = InsertProduct(_productRepository);
  late final UpdateProduct updateProduct = UpdateProduct(_productRepository);
  late final DeleteProduct deleteProduct = DeleteProduct(_productRepository);
}
