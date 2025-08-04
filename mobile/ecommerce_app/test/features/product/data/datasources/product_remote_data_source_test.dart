import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:product_app/core/error/exceptions.dart';
import 'package:product_app/features/product/data/datasources/product_remote_data_source_impl.dart';
import 'package:product_app/features/product/data/models/product_model.dart';

import 'product_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
const baseUrl = 'https://example.com';

void main() {
  late ProductRemoteDataSourceImpl dataSource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = ProductRemoteDataSourceImpl(
      client: mockHttpClient,
      baseUrl: baseUrl,
    );
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

  group('createProduct', () {
    final tProductModel = ProductModel(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test',
      rating: 4.5,
    );

    test('should perform a POST request to create a product', () async {
      // arrange
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      // act
      await dataSource.createProduct(tProductModel);

      // assert
      verify(mockHttpClient.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(tProductModel.toJson()),
      ));
    });

    test('should complete successfully when price is valid', () async {
      // arrange
      when(mockHttpClient.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(tProductModel.toJson()),
      )).thenAnswer((_) async => http.Response('{}', 200));

      // act & assert
      await expectLater(dataSource.createProduct(tProductModel), completes);
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
      final call = dataSource.createProduct;

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
