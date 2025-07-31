import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:product_app/domain/entities/product_entity.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/domain/usecases/update_product.dart';

@GenerateMocks([ProductRepository])
void main() {
  late UpdateProduct usecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = UpdateProduct(mockRepository);
  });

  final testProduct = ProductEntity(
    id: '1',
    name: 'Updated Product',
    description: 'Updated Description',
    price: 149.99,
    imageUrl: 'assets/images/travis.png',
    category: "Men's shoe",
    rating: 4.8,
  );

  test('should update product through the repository', () async {
    // arrange
    when(mockRepository.updateProduct(testProduct))
        .thenAnswer((_) async => testProduct);

    // act
    final result = await usecase(testProduct);

    // assert
    expect(result, testProduct);
    verify(mockRepository.updateProduct(testProduct));
    verifyNoMoreInteractions(mockRepository);
  });
}
