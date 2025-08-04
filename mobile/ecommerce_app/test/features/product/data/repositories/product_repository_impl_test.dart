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

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    mockLocalDataSource = MockProductLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
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
      when(
        mockRemoteDataSource.getProduct(any),
      ).thenAnswer((_) async => tProductModel);
      // act
      await repository.getProduct(tId);
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
          when(mockRemoteDataSource.getProduct(any))
            .thenAnswer((_) async => tProductModel);
          // act
          final result = await repository.getProduct(tId);
          // assert
          verify(mockRemoteDataSource.getProduct(tId));
          verify(mockLocalDataSource.cacheProduct(tProductModel));
          expect(result, equals(Right(tProductModel)));
        },
      );

      test(
        'should cache data locally when remote call is successful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.getProduct(any),
          ).thenAnswer((_) async => tProductModel);
          // act
          await repository.getProduct(tId);
          // assert
          verify(mockRemoteDataSource.getProduct(tId));
          verify(mockLocalDataSource.cacheProduct(tProductModel));
        },
      );

      test('should return cached data when remote call fails', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getProduct(tId))
          .thenThrow(ServerException());
        when(mockLocalDataSource.getCachedProduct(tId))
          .thenAnswer((_) async => tProductModel);
        // act
        final result = await repository.getProduct(tId);
        // assert
        verify(mockRemoteDataSource.getProduct(tId));
        verify(mockLocalDataSource.getCachedProduct(tId));
        expect(result, equals(Right(tProductModel)));
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
        final result = await repository.getProduct(tId);
        // assert
        verify(mockLocalDataSource.getCachedProduct(tId));
        expect(result, equals(Right(tProductModel)));
      });

      test(
        'should return CacheFailure when no cached data is present',
        () async {
          // arrange
          when(mockLocalDataSource.getCachedProduct(any))
              .thenThrow(CacheException());
          // act
          final result = await repository.getProduct(tId);
          // assert
          expect(result, equals(Left(CacheFailure())));
        },
      );
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

    test('should throw ServerException when offline', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      // act
      final call = repository.createProduct;
      // assert
      expect(() => call(tProduct), throwsA(isA<ServerException>()));
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should create product in remote data source', () async {
        // arrange
        when(
          mockRemoteDataSource.createProduct(tProductModel),
        ).thenAnswer((_) async => {});
        // act
        final result = await repository.createProduct(tProductModel);
        // assert
        expect(result, equals(const Right(null)));
        verify(mockRemoteDataSource.createProduct(tProductModel));
        verify(mockLocalDataSource.cacheProduct(tProductModel));
      });

      test('should return ServerFailure when remote create fails', () async {
        // arrange
        when(
          mockRemoteDataSource.createProduct(tProductModel),
        ).thenThrow(ServerException());
        // act
        final result = await repository.createProduct(tProductModel);
        // assert
        expect(result, equals(Left(ServerFailure())));
      });
    });
  });
}
