import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_app/core/error/failures.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'product_repository_impl_test.mocks.dart';
import 'package:product_app/core/error/exceptions.dart';
import 'package:product_app/core/network/network_info.dart';
import 'package:product_app/features/product/domain/entities/product.dart';
import 'package:product_app/features/product/data/datasources/product_local_data_source.dart';
import 'package:product_app/features/product/data/datasources/product_remote_data_source.dart';
import 'package:product_app/features/product/data/models/product_model.dart';
import 'package:product_app/features/product/data/repositories/product_repository_impl.dart';

@GenerateMocks([ProductRemoteDataSource, ProductLocalDataSource, NetworkInfo])
void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemoteDataSource;
  late MockProductLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late ProductModel tProductModel;

  late Future<String?> Function() mockGetToken;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    mockLocalDataSource = MockProductLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockGetToken = () async => 'test_token';
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
      getToken: mockGetToken,
    );

    tProductModel = ProductModel(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test',
      rating: 4.5,
    );
  });

  group('getProduct', () {
    const tId = '1';

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getProduct(any, token: anyNamed('token')))
          .thenAnswer((_) async => tProductModel);
      // act
      await repository.getProduct(tId, token: 'test_token');
      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return remote data when remote call is successful',
        () async {
          // arrange
          when(mockRemoteDataSource.getProduct(tId, token: 'test_token'))
              .thenAnswer((_) async => tProductModel);
          // act
          final result = await repository.getProduct(tId, token: 'test_token');
          // assert
          verify(mockRemoteDataSource.getProduct(tId, token: 'test_token'));
          verify(mockLocalDataSource.cacheProduct(tProductModel));
          expect(result, equals(Right(tProductModel)));
        },
      );

      test(
        'should cache data locally when remote call is successful',
        () async {
          // arrange
          when(mockRemoteDataSource.getProduct(any, token: anyNamed('token')))
              .thenAnswer((_) async => tProductModel);
          // act
          await repository.getProduct(tId, token: 'test_token');
          // assert
          verify(mockRemoteDataSource.getProduct(tId, token: 'test_token'));
          verify(mockLocalDataSource.cacheProduct(tProductModel));
        },
      );

      test('should return server failure when remote call fails', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getProduct(tId, token: 'test_token'))
            .thenThrow(ServerException(message: 'Server error occurred'));
        // act
        final result = await repository.getProduct(tId, token: 'test_token');
        // assert
        verify(mockRemoteDataSource.getProduct(tId, token: 'test_token'));
        verifyNever(mockLocalDataSource.getCachedProduct(tId));
        expect(result, equals(Left(ServerFailure(message: 'Server error occurred'))));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return cached data when available', () async {
        // arrange
        when(mockLocalDataSource.getCachedProduct(any))
            .thenAnswer((_) async => tProductModel);
        // act
        final result = await repository.getProduct(tId, token: 'test_token');
        // assert
        verify(mockLocalDataSource.getCachedProduct(tId));
        expect(result, equals(Right(tProductModel)));
      });

      test(
        'should return CacheFailure when no cached data is present',
        () async {
          // arrange
          when(mockRemoteDataSource.getAllProducts(token: anyNamed('token')))
              .thenThrow(ServerException(message: 'Server error occurred'));
          when(mockLocalDataSource.getCachedProduct(any))
              .thenThrow(CacheException(message: 'Cache operation failed'));
          // act
          final result = await repository.getProduct(tId, token: 'test_token');
          // assert
          expect(result, equals(Left(CacheFailure(message: 'Cache operation failed'))));
        },
      );
    });
  });

  group('updateProduct', () {
    test('should update product in remote data source when online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.updateProduct(tProductModel.id, tProductModel, token: 'test_token'))
          .thenAnswer((_) async => tProductModel);
      // act
      final result = await repository.updateProduct(tProductModel, token: 'test_token');
      // assert
      verify(mockRemoteDataSource.updateProduct(tProductModel.id, tProductModel, token: 'test_token'));
      expect(result, equals(Right(tProductModel)));
    });

    test('should return no internet failure when offline', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      // act
      final result = await repository.updateProduct(tProductModel, token: 'test_token');
      // assert
      verifyZeroInteractions(mockRemoteDataSource);
      expect(result, equals(Left(NoInternetFailure(message: 'No internet connection'))));
    });

    test('should return unauthorized failure when token is invalid', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.updateProduct(tProductModel.id, tProductModel, token: 'test_token'))
          .thenThrow(UnauthorizedException(message: 'Unauthorized access'));
      // act
      final result = await repository.updateProduct(tProductModel, token: 'test_token');
      // assert
      verify(mockRemoteDataSource.updateProduct(tProductModel.id, tProductModel, token: 'test_token'));
      expect(result, equals(Left(UnauthorizedFailure(message: 'Unauthorized access'))));
    });

    test('should return forbidden failure when user lacks permission', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.updateProduct(tProductModel.id, tProductModel, token: 'test_token'))
          .thenThrow(ForbiddenException(message: 'Access forbidden'));
      // act
      final result = await repository.updateProduct(tProductModel, token: 'test_token');
      // assert
      verify(mockRemoteDataSource.updateProduct(tProductModel.id, tProductModel, token: 'test_token'));
      expect(result, equals(Left(ForbiddenFailure(message: 'Access forbidden'))));
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return server failure when remote update fails', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.updateProduct(tProductModel.id, tProductModel, token: 'test_token'))
            .thenThrow(ServerException(message: 'Server error occurred'));
        // act
        final result = await repository.updateProduct(tProductModel, token: 'test_token');
        // assert
        verify(mockRemoteDataSource.updateProduct(tProductModel.id, tProductModel, token: 'test_token'));
        expect(result, equals(Left(ServerFailure(message: 'Server error occurred'))));
      });
    });
  });

  group('insertProduct', () {
    final tProduct = Product(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test Category',
      rating: 4.5,
    );

    test('should return NoInternetFailure when offline', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      // act
      final result = await repository.createProduct(tProduct, token: 'test_token');
      // assert
      expect(result, equals(Left(NoInternetFailure(message: 'No internet connection'))));
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should create product in remote data source', () async {
        // arrange
        when(mockRemoteDataSource.createProduct(any, token: anyNamed('token')))
            .thenAnswer((_) async => tProductModel);
        // act
        final result = await repository.createProduct(tProductModel, token: 'test_token');
        // assert
        expect(result, equals(Right(tProductModel)));
        verify(mockRemoteDataSource.createProduct(any, token: 'test_token'));
        verify(mockLocalDataSource.cacheProduct(tProductModel));
      });

      test('should return ServerFailure when remote create fails', () async {
        // arrange
        when(mockRemoteDataSource.createProduct(any, token: anyNamed('token')))
            .thenThrow(ServerException(message: 'Server error occurred'));
        // act
        final result = await repository.createProduct(tProductModel, token: 'test_token');
        // assert
        expect(result, equals(Left(ServerFailure(message: 'Server error occurred'))));
      });
    });
  });
}
