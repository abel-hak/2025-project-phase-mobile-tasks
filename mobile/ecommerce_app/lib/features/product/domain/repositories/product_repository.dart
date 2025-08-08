import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  /// Gets all products
  /// 
  /// Returns [UnauthorizedFailure] if not authenticated
  /// Returns [ForbiddenFailure] if not authorized
  /// Returns [ServerFailure] if server error occurs
  /// Returns [NoInternetFailure] if no internet connection
  Future<Either<Failure, List<Product>>> getAllProducts({required String token});

  /// Gets a product by ID
  /// 
  /// Returns [UnauthorizedFailure] if not authenticated
  /// Returns [ForbiddenFailure] if not authorized
  /// Returns [ServerFailure] if server error occurs
  /// Returns [NoInternetFailure] if no internet connection
  /// Returns [CacheFailure] if cache error occurs
  Future<Either<Failure, Product>> getProduct(String id, {required String token});

  /// Creates a new product
  /// 
  /// Returns [UnauthorizedFailure] if not authenticated
  /// Returns [ForbiddenFailure] if not authorized
  /// Returns [ServerFailure] if server error occurs
  /// Returns [NoInternetFailure] if no internet connection
  Future<Either<Failure, Product>> createProduct(Product product, {required String token});

  /// Updates an existing product
  /// 
  /// Returns [UnauthorizedFailure] if not authenticated
  /// Returns [ForbiddenFailure] if not authorized
  /// Returns [ServerFailure] if server error occurs
  /// Returns [NoInternetFailure] if no internet connection
  Future<Either<Failure, Product>> updateProduct(Product product, {required String token});

  /// Deletes a product
  /// 
  /// Returns [UnauthorizedFailure] if not authenticated
  /// Returns [ForbiddenFailure] if not authorized
  /// Returns [ServerFailure] if server error occurs
  /// Returns [NoInternetFailure] if no internet connection
  /// Returns [CacheFailure] if cache error occurs
  Future<Either<Failure, void>> deleteProduct(String id, {required String token});
}
