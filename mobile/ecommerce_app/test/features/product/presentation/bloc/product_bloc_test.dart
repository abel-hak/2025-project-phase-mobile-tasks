import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'product_bloc_test.mocks.dart';
import 'package:product_app/core/error/failures.dart';
import 'package:product_app/features/product/domain/entities/product.dart';
import 'package:product_app/features/product/domain/repositories/product_repository.dart';
import 'package:product_app/features/product/domain/usecases/create_product.dart';
import 'package:product_app/features/product/domain/usecases/delete_product.dart';
import 'package:product_app/features/product/domain/usecases/get_all_products.dart';
import 'package:product_app/features/product/domain/usecases/get_product.dart';
import 'package:product_app/features/product/domain/usecases/update_product.dart';
import 'package:product_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:product_app/features/product/presentation/bloc/product_event.dart';
import 'package:product_app/features/product/presentation/bloc/product_state.dart';

@GenerateMocks([ProductRepository], customMocks: [])
void main() {
  late ProductBloc bloc;
  late MockProductRepository mockRepository;
  late GetAllProducts getAllProducts;
  late GetProduct getProduct;
  late CreateProduct createProduct;
  late UpdateProduct updateProduct;
  late DeleteProduct deleteProduct;

  setUp(() {
    mockRepository = MockProductRepository();
    getAllProducts = GetAllProducts(mockRepository);
    getProduct = GetProduct(mockRepository);
    createProduct = CreateProduct(mockRepository);
    updateProduct = UpdateProduct(mockRepository);
    deleteProduct = DeleteProduct(mockRepository);

    bloc = ProductBloc(
      getAllProducts: getAllProducts,
      getProduct: getProduct,
      createProduct: createProduct,
      updateProduct: updateProduct,
      deleteProduct: deleteProduct,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be InitialState', () {
    expect(bloc.state, const InitialState());
  });

  group('LoadAllProductEvent', () {
    final products = [
      Product(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'test.jpg',
        category: 'Test Category',
        rating: 4.5,
      ),
    ];

    test(
      'should emit [LoadingState, LoadedAllProductState] when successful',
      () {
        when(
          mockRepository.getAllProducts(),
        ).thenAnswer((_) async => Right(products));

        final expected = [
          const LoadingState(),
          LoadedAllProductState(products: products),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const LoadAllProductEvent());
      },
    );

    test('should emit [LoadingState, ErrorState] when unsuccessful', () {
      when(
        mockRepository.getAllProducts(),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final expected = [const LoadingState(), isA<ErrorState>()];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const LoadAllProductEvent());
    });
  });

  group('GetSingleProductEvent', () {
    final product = Product(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test Category',
      rating: 4.5,
    );

    test(
      'should emit [LoadingState, LoadedSingleProductState] when successful',
      () {
        when(
          mockRepository.getProduct('1'),
        ).thenAnswer((_) async => Right(product));

        final expected = [
          const LoadingState(),
          LoadedSingleProductState(product: product),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const GetSingleProductEvent(id: '1'));
      },
    );

    test('should emit [LoadingState, ErrorState] when unsuccessful', () {
      when(
        mockRepository.getProduct('1'),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final expected = [const LoadingState(), isA<ErrorState>()];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const GetSingleProductEvent(id: '1'));
    });
  });

  group('CreateProductEvent', () {
    final product = Product(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test Category',
      rating: 4.5,
    );

    test(
      'should emit [LoadingState] and call LoadAllProductEvent when successful',
      () {
        when(
          mockRepository.createProduct(product),
        ).thenAnswer((_) async => const Right(null));
        when(
          mockRepository.getAllProducts(),
        ).thenAnswer((_) async => Right([]));

        final expected = [
          const LoadingState(),
          const LoadedAllProductState(products: []),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(CreateProductEvent(product: product));
      },
    );

    test('should emit [LoadingState, ErrorState] when unsuccessful', () {
      when(
        mockRepository.createProduct(product),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final expected = [const LoadingState(), isA<ErrorState>()];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(CreateProductEvent(product: product));
    });
  });

  group('UpdateProductEvent', () {
    final product = Product(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test Category',
      rating: 4.5,
    );

    test(
      'should emit [LoadingState] and call LoadAllProductEvent when successful',
      () {
        when(
          mockRepository.updateProduct(product),
        ).thenAnswer((_) async => const Right(null));
        when(
          mockRepository.getAllProducts(),
        ).thenAnswer((_) async => Right([]));

        final expected = [
          const LoadingState(),
          const LoadedAllProductState(products: []),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(UpdateProductEvent(product: product));
      },
    );

    test('should emit [LoadingState, ErrorState] when unsuccessful', () {
      when(
        mockRepository.updateProduct(product),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final expected = [const LoadingState(), isA<ErrorState>()];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(UpdateProductEvent(product: product));
    });
  });

  group('DeleteProductEvent', () {
    test(
      'should emit [LoadingState] and call LoadAllProductEvent when successful',
      () {
        when(
          mockRepository.deleteProduct('1'),
        ).thenAnswer((_) async => const Right(null));
        when(
          mockRepository.getAllProducts(),
        ).thenAnswer((_) async => Right([]));

        final expected = [
          const LoadingState(),
          const LoadedAllProductState(products: []),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));
        bloc.add(const DeleteProductEvent(id: '1'));
      },
    );

    test('should emit [LoadingState, ErrorState] when unsuccessful', () {
      when(
        mockRepository.deleteProduct('1'),
      ).thenAnswer((_) async => Left(ServerFailure()));

      final expected = [const LoadingState(), isA<ErrorState>()];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const DeleteProductEvent(id: '1'));
    });
  });
}
