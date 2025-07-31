import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:product_app/domain/repositories/product_repository.dart';
import 'package:product_app/domain/usecases/delete_product.dart';

@GenerateMocks([ProductRepository])
void main() {
  late DeleteProduct usecase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    usecase = DeleteProduct(mockRepository);
  });

  test('should delete product through the repository', () async {
    // arrange
    const productId = '1';
    when(mockRepository.deleteProduct(productId))
        .thenAnswer((_) async => null);

    // act
    await usecase(productId);

    // assert
    verify(mockRepository.deleteProduct(productId));
    verifyNoMoreInteractions(mockRepository);
  });
}
