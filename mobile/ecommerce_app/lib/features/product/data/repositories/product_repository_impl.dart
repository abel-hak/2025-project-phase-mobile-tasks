import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

typedef AuthTokenProvider = Future<String?> Function();

class ProductRepositoryImpl implements ProductRepository {
  final AuthTokenProvider getToken;
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.getToken,
  });

  @override
  Future<Either<Failure, void>> deleteProduct(String id, {required String token}) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteProduct(id, token: token);
        await localDataSource.removeCachedProduct(id);
        return const Right(null);
      } else {
        await localDataSource.removeCachedProduct(id);
        return const Right(null);
      }
    } on UnauthorizedException {
      return Left(UnauthorizedFailure(message: 'Unauthorized access'));
    } on ForbiddenException {
      return Left(ForbiddenFailure(message: 'Access forbidden'));
    } on ServerException {
      return Left(ServerFailure(message: 'Server error occurred'));
    } on CacheException {
      return Left(CacheFailure(message: 'Cache operation failed'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getAllProducts({required String token}) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteProducts = await remoteDataSource.getAllProducts(token: token);
        await localDataSource.cacheProducts(remoteProducts);
        return Right(remoteProducts);
      } else {
        final localProducts = await localDataSource.getCachedProducts();
        return Right(localProducts);
      }
    } on UnauthorizedException {
      return Left(UnauthorizedFailure(message: 'Unauthorized access'));
    } on ForbiddenException {
      return Left(ForbiddenFailure(message: 'Access forbidden'));
    } on ServerException {
      return Left(ServerFailure(message: 'Server error occurred'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(String id, {required String token}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProduct = await remoteDataSource.getProduct(id, token: token);
        await localDataSource.cacheProduct(remoteProduct);
        return Right(remoteProduct);
      } on UnauthorizedException {
        return Left(UnauthorizedFailure(message: 'Unauthorized access'));
      } on ForbiddenException {
        return Left(ForbiddenFailure(message: 'Access forbidden'));
      } on ServerException {
        return Left(ServerFailure(message: 'Server error occurred'));
      }
    } else {
      try {
        final localProduct = await localDataSource.getCachedProduct(id);
        return Right(localProduct);
      } on CacheException {
        return Left(CacheFailure(message: 'Cache operation failed'));
      }
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(Product product, {required String token}) async {
    try {
      if (await networkInfo.isConnected) {
        final productModel = ProductModel(
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          category: product.category,
          rating: product.rating,
        );
        final createdProduct = await remoteDataSource.createProduct(
          productModel,
          token: token,
        );
        await localDataSource.cacheProduct(createdProduct);
        return Right(createdProduct);
      } else {
        return Left(NoInternetFailure(message: 'No internet connection'));
      }
    } on UnauthorizedException {
      return Left(UnauthorizedFailure(message: 'Unauthorized access'));
    } on ForbiddenException {
      return Left(ForbiddenFailure(message: 'Access forbidden'));
    } on ServerException {
      return Left(ServerFailure(message: 'Server error occurred'));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product, {required String token}) async {
    final productModel = ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      rating: product.rating,
    );

    try {
      if (await networkInfo.isConnected) {
        final updatedProduct = await remoteDataSource.updateProduct(product.id, productModel, token: token);
        await localDataSource.cacheProduct(updatedProduct);
        return Right(updatedProduct);
      } else {
        return Left(NoInternetFailure(message: 'No internet connection'));
      }
    } on UnauthorizedException {
      return Left(UnauthorizedFailure(message: 'Unauthorized access'));
    } on ForbiddenException {
      return Left(ForbiddenFailure(message: 'Access forbidden'));
    } on ServerException {
      return Left(ServerFailure(message: 'Server error occurred'));
    } on CacheException {
      return Left(CacheFailure(message: 'Cache operation failed'));
    }
  }
}
