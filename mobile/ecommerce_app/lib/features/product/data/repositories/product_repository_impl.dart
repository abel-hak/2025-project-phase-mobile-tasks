import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<void> deleteProduct(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteProduct(id);
        await localDataSource.removeCachedProduct(id);
      } on ServerException {
        rethrow;
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Product> getProduct(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProduct = await remoteDataSource.getProduct(id);
        await localDataSource.cacheProduct(remoteProduct);
        return remoteProduct;
      } on ServerException {
        final localProduct = await localDataSource.getProduct(id);
        return localProduct;
      }
    } else {
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
    final productModel = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      rating: product.rating,
    );

    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.insertProduct(productModel);
        await localDataSource.cacheProduct(productModel);
      } on ServerException {
        rethrow;
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    final productModel = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      rating: product.rating,
    );

    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateProduct(productModel);
        await localDataSource.updateCachedProduct(productModel);
      } on ServerException {
        rethrow;
      }
    } else {
      throw ServerException();
    }
  }
}
