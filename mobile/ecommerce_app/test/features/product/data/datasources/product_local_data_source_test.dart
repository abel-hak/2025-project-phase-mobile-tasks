import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:product_app/core/error/exceptions.dart';
import 'package:product_app/features/product/data/datasources/product_local_data_source_impl.dart';
import 'package:product_app/features/product/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'product_local_data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late ProductLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = ProductLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getProduct', () {
    final tId = '1';
    final tProductModel = ProductModel(
      id: tId,
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test Category',
      rating: 4.5,
    );

    test('should return Product from SharedPreferences when there is one in the cache',
        () async {
      // arrange
      when(mockSharedPreferences.getString('$CACHED_PRODUCTS_KEY:$tId'))
          .thenReturn(json.encode(tProductModel.toJson()));
      // act
      final result = await dataSource.getProduct(tId);
      // assert
      verify(mockSharedPreferences.getString('$CACHED_PRODUCTS_KEY:$tId'));
      expect(result, equals(tProductModel));
    });

    test('should throw CacheException when there is no cached value', () async {
      // arrange
      when(mockSharedPreferences.getString('$CACHED_PRODUCTS_KEY:$tId'))
          .thenReturn(null);
      // act
      final call = dataSource.getProduct;
      // assert
      expect(() => call(tId), throwsA(isA<CacheException>()));
    });
  });

  group('cacheProduct', () {
    final tProductModel = ProductModel(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test Category',
      rating: 4.5,
    );

    test('should call SharedPreferences to cache the data', () async {
      // arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);
      // act
      await dataSource.cacheProduct(tProductModel);
      // assert
      final expectedJsonString = json.encode(tProductModel.toJson());
      verify(mockSharedPreferences.setString(
        '$CACHED_PRODUCTS_KEY:${tProductModel.id}',
        expectedJsonString,
      ));
    });

    test('should throw CacheException when set returns false', () async {
      // arrange
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => false);
      // act
      final call = dataSource.cacheProduct;
      // assert
      expect(() => call(tProductModel), throwsA(isA<CacheException>()));
    });
  });

  group('updateCachedProduct', () {
    final tProductModel = ProductModel(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test Category',
      rating: 4.5,
    );

    test('should update an existing product in SharedPreferences', () async {
      // arrange
      when(mockSharedPreferences.containsKey(any)).thenReturn(true);
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);
      // act
      await dataSource.updateCachedProduct(tProductModel);
      // assert
      final expectedJsonString = json.encode(tProductModel.toJson());
      verify(mockSharedPreferences.setString(
        '$CACHED_PRODUCTS_KEY:${tProductModel.id}',
        expectedJsonString,
      ));
    });

    test('should throw CacheException when product does not exist', () async {
      // arrange
      when(mockSharedPreferences.containsKey(any)).thenReturn(false);
      // act
      final call = dataSource.updateCachedProduct;
      // assert
      expect(() => call(tProductModel), throwsA(isA<CacheException>()));
    });
  });

  group('removeCachedProduct', () {
    final tId = '1';

    test('should remove an existing product from SharedPreferences', () async {
      // arrange
      when(mockSharedPreferences.containsKey(any)).thenReturn(true);
      when(mockSharedPreferences.remove(any)).thenAnswer((_) async => true);
      // act
      await dataSource.removeCachedProduct(tId);
      // assert
      verify(mockSharedPreferences.remove('$CACHED_PRODUCTS_KEY:$tId'));
    });

    test('should throw CacheException when product does not exist', () async {
      // arrange
      when(mockSharedPreferences.containsKey(any)).thenReturn(false);
      // act
      final call = dataSource.removeCachedProduct;
      // assert
      expect(() => call(tId), throwsA(isA<CacheException>()));
    });

    test('should throw CacheException when remove fails', () async {
      // arrange
      when(mockSharedPreferences.containsKey(any)).thenReturn(true);
      when(mockSharedPreferences.remove(any)).thenAnswer((_) async => false);
      // act
      final call = dataSource.removeCachedProduct;
      // assert
      expect(() => call(tId), throwsA(isA<CacheException>()));
    });
  });
}
