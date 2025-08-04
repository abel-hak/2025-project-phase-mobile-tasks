import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
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
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteProduct(id);
        await localDataSource.removeCachedProduct(id);
        return const Right(null);
      } else {
        await localDataSource.removeCachedProduct(id);
        return const Right(null);
      }
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getAllProducts();
        await localDataSource.cacheProducts(remoteProducts);
        return Right(remoteProducts);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localProducts = await localDataSource.getCachedProducts();
        return Right(localProducts);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProduct = await remoteDataSource.getProduct(id);
        await localDataSource.cacheProduct(remoteProduct);
        return Right(remoteProduct);
      } on ServerException {
        try {
          final localProduct = await localDataSource.getCachedProduct(id);
          return Right(localProduct);
        } on CacheException {
          return Left(CacheFailure());
        }
      }
    } else {
      try {
        final localProduct = await localDataSource.getCachedProduct(id);
        return Right(localProduct);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, void>> createProduct(Product product) async {
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
        await remoteDataSource.createProduct(productModel);
        await localDataSource.cacheProduct(productModel);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
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
      
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateProduct(productModel);
        await localDataSource.updateCachedProduct(productModel);
        return const Right(null);
      } else {
        await localDataSource.updateCachedProduct(productModel);
        return const Right(null);
      }
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
