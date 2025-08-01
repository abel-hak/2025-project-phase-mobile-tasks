import 'package:flutter_test/flutter_test.dart';
import 'package:product_app/features/product/data/models/product_model.dart';

void main() {
  final tProductModel = ProductModel(
    id: '1',
    name: 'Test Product',
    description: 'Test Description',
    price: 99.99,
    imageUrl: 'test_image.jpg',
    category: 'Test Category',
    rating: 4.5,
  );

  final tProductJson = {
    'id': '1',
    'name': 'Test Product',
    'description': 'Test Description',
    'price': 99.99,
    'imageUrl': 'test_image.jpg',
    'category': 'Test Category',
    'rating': 4.5,
  };

  group('ProductModel', () {
    test('should create a valid model from JSON', () {
      // arrange
      final Map<String, dynamic> jsonMap = tProductJson;

      // act
      final result = ProductModel.fromJson(jsonMap);

      // assert
      expect(result, isA<ProductModel>());
      expect(result.id, tProductModel.id);
      expect(result.name, tProductModel.name);
      expect(result.description, tProductModel.description);
      expect(result.price, tProductModel.price);
      expect(result.imageUrl, tProductModel.imageUrl);
      expect(result.category, tProductModel.category);
      expect(result.rating, tProductModel.rating);
    });

    test('should convert to JSON map correctly', () {
      // act
      final result = tProductModel.toJson();

      // assert
      expect(result, tProductJson);
    });

    test('should handle integer price and rating in JSON', () {
      // arrange
      final jsonWithIntegers = {
        'id': '1',
        'name': 'Test Product',
        'description': 'Test Description',
        'price': 99,
        'imageUrl': 'test_image.jpg',
        'category': 'Test Category',
        'rating': 4,
      };

      // act
      final result = ProductModel.fromJson(jsonWithIntegers);

      // assert
      expect(result.price, 99.0);
      expect(result.rating, 4.0);
    });
  });
}
