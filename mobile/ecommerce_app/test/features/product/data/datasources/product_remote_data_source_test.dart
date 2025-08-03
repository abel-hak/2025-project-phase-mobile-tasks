import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:product_app/core/error/exceptions.dart';
import 'package:product_app/features/product/data/datasources/product_remote_data_source_impl.dart';
import 'package:product_app/features/product/data/models/product_model.dart';

import 'product_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late ProductRemoteDataSourceImpl dataSource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = ProductRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('getProduct', () {
    test('should return a Product when id is 1', () async {
      // act
      final result = await dataSource.getProduct('1');

      // assert
      expect(result, isA<ProductModel>());
      expect(result.id, '1');
      expect(result.name, 'Mock Product');
    });

    test('should throw ServerException when id is not 1', () async {
      // act
      final call = dataSource.getProduct;

      // assert
      expect(() => call('2'), throwsA(isA<ServerException>()));
    });
  });

  group('insertProduct', () {
    final tProduct = ProductModel(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test',
      rating: 4.5,
    );

    test('should complete successfully when price is valid', () async {
      // act & assert
      expect(dataSource.insertProduct(tProduct), completes);
    });

    test('should throw ServerException when price is negative', () async {
      // arrange
      final invalidProduct = ProductModel(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: -1,
        imageUrl: 'test.jpg',
        category: 'Test',
        rating: 4.5,
      );

      // act
      final call = dataSource.insertProduct;

      // assert
      expect(() => call(invalidProduct), throwsA(isA<ServerException>()));
    });
  });

  group('updateProduct', () {
    final tProduct = ProductModel(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test',
      rating: 4.5,
    );

    test('should complete successfully when id is not empty', () async {
      // act & assert
      expect(dataSource.updateProduct(tProduct), completes);
    });

    test('should throw ServerException when id is empty', () async {
      // arrange
      final invalidProduct = ProductModel(
        id: '',
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'test.jpg',
        category: 'Test',
        rating: 4.5,
      );

      // act
      final call = dataSource.updateProduct;

      // assert
      expect(() => call(invalidProduct), throwsA(isA<ServerException>()));
    });
  });

  group('deleteProduct', () {
    test('should complete successfully when id is not empty', () async {
      // act & assert
      expect(dataSource.deleteProduct('1'), completes);
    });

    test('should throw ServerException when id is empty', () async {
      // act
      final call = dataSource.deleteProduct;

      // assert
      expect(() => call(''), throwsA(isA<ServerException>()));
    });
  });
}
