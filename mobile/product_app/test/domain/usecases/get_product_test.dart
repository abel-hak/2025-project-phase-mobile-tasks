import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:product_app/domain/entities/product_entity.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/domain/usecases/get_product.dart';

@GenerateMocks([ProductRepository])
void main() {
  late GetProduct getProductUsecase;
  late GetAllProducts getAllProductsUsecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    getProductUsecase = GetProduct(mockRepository);
    getAllProductsUsecase = GetAllProducts(mockRepository);
  });

  final testProduct = ProductEntity(
    id: '1',
    name: 'Test Product',
    description: 'Test Description',
    price: 99.99,
    imageUrl: 'assets/images/travis.png',
    category: "Men's shoe",
    rating: 4.5,
  );

  final testProducts = [
    testProduct,
    ProductEntity(
      id: '2',
      name: 'Another Product',
      description: 'Another Description',
      price: 149.99,
      imageUrl: 'assets/images/puma.png',
      category: "Men's shoe",
      rating: 4.8,
    ),
  ];

  group('GetProduct', () {
    test('should get product by id through the repository', () async {
      // arrange
      when(mockRepository.getProduct(testProduct.id))
          .thenAnswer((_) async => testProduct);

      // act
      final result = await getProductUsecase(testProduct.id);

      // assert
      expect(result, testProduct);
      verify(mockRepository.getProduct(testProduct.id));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetAllProducts', () {
    test('should get all products through the repository', () async {
      // arrange
      when(mockRepository.getAllProducts())
          .thenAnswer((_) async => testProducts);

      // act
      final result = await getAllProductsUsecase();

      // assert
      expect(result, testProducts);
      verify(mockRepository.getAllProducts());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
