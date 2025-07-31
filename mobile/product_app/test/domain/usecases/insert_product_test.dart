import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:product_app/domain/entities/product_entity.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/domain/usecases/insert_product.dart';

@GenerateMocks([ProductRepository])
void main() {
  late InsertProduct usecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = InsertProduct(mockRepository);
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

  test('should insert product through the repository', () async {
    // arrange
    when(mockRepository.insertProduct(testProduct))
        .thenAnswer((_) async => testProduct);

    // act
    final result = await usecase(testProduct);

    // assert
    expect(result, testProduct);
    verify(mockRepository.insertProduct(testProduct));
    verifyNoMoreInteractions(mockRepository);
  });
}
