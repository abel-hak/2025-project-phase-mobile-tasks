import '../../../../core/error/exceptions.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      await localDataSource.removeCachedProduct(id);
    } on ServerException {
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(String id) async {
    try {
      final remoteProduct = await remoteDataSource.getProduct(id);
      await localDataSource.cacheProduct(remoteProduct);
      return remoteProduct;
    } on ServerException {
      try {
        final localProduct = await localDataSource.getProduct(id);
        return localProduct;
      } on CacheException {
        rethrow;
      }
    }
  }

  @override
  Future<void> insertProduct(Product product) async {
    try {
      final productModel = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        category: product.category,
        rating: product.rating,
      );
      await remoteDataSource.insertProduct(productModel);
      await localDataSource.cacheProduct(productModel);
    } on ServerException {
      rethrow;
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      final productModel = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        category: product.category,
        rating: product.rating,
      );
      await remoteDataSource.updateProduct(productModel);
      await localDataSource.updateCachedProduct(productModel);
    } on ServerException {
      rethrow;
    }
  }
}
