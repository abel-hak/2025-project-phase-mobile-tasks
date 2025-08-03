import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'product_repository_impl_test.mocks.dart';
import 'package:product_app/core/error/exceptions.dart';
import 'package:product_app/core/network/network_info.dart';
import 'package:product_app/domain/entities/product.dart';
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

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    mockLocalDataSource = MockProductLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getProduct', () {
    const tId = '1';
    final tProductModel = ProductModel(
      id: tId,
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test Category',
      rating: 4.5,
    );

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getProduct(any))
          .thenAnswer((_) async => tProductModel);
      // act
      await repository.getProduct(tId);
      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return remote data when remote call is successful', () async {
        // arrange
        when(mockRemoteDataSource.getProduct(any))
            .thenAnswer((_) async => tProductModel);
        // act
        final result = await repository.getProduct(tId);
        // assert
        verify(mockRemoteDataSource.getProduct(tId));
        expect(result, equals(tProductModel));
      });

      test('should cache data locally when remote call is successful', () async {
        // arrange
        when(mockRemoteDataSource.getProduct(any))
            .thenAnswer((_) async => tProductModel);
        // act
        await repository.getProduct(tId);
        // assert
        verify(mockRemoteDataSource.getProduct(tId));
        verify(mockLocalDataSource.cacheProduct(tProductModel));
      });

      test('should return cached data when remote call fails', () async {
        // arrange
        when(mockRemoteDataSource.getProduct(any)).thenThrow(ServerException());
        when(mockLocalDataSource.getProduct(any))
            .thenAnswer((_) async => tProductModel);
        // act
        final result = await repository.getProduct(tId);
        // assert
        verify(mockRemoteDataSource.getProduct(tId));
        verify(mockLocalDataSource.getProduct(tId));
        expect(result, equals(tProductModel));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return cached data when available', () async {
        // arrange
        when(mockLocalDataSource.getProduct(any))
            .thenAnswer((_) async => tProductModel);
        // act
        final result = await repository.getProduct(tId);
        // assert
        verifyNever(mockRemoteDataSource.getProduct(any));
        verify(mockLocalDataSource.getProduct(tId));
        expect(result, equals(tProductModel));
      });

      test('should throw CacheException when no cached data is present', () async {
        // arrange
        when(mockLocalDataSource.getProduct(any)).thenThrow(CacheException());
        // act
        final call = repository.getProduct;
        // assert
        expect(() => call(tId), throwsA(isA<CacheException>()));
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

    test('should throw ServerException when offline', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      // act
      final call = repository.insertProduct;
      // assert
      expect(() => call(tProduct), throwsA(isA<ServerException>()));
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should insert product to remote and cache locally when successful',
          () async {
        // arrange
        when(mockRemoteDataSource.insertProduct(any)).thenAnswer((_) async => {});
        // act
        await repository.insertProduct(tProduct);
        // assert
        verify(mockRemoteDataSource.insertProduct(any));
        verify(mockLocalDataSource.cacheProduct(any));
      });

      test('should throw ServerException when remote insert fails', () async {
        // arrange
        when(mockRemoteDataSource.insertProduct(any))
            .thenThrow(ServerException());
        // act
        final call = repository.insertProduct;
        // assert
        expect(() => call(tProduct), throwsA(isA<ServerException>()));
      });
    });
  });
}
