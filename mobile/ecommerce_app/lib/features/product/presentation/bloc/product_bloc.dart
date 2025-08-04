import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_all_products.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/update_product.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProducts getAllProducts;
  final GetProduct getProduct;
  final CreateProduct createProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;

  ProductBloc({
    required this.getAllProducts,
    required this.getProduct,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
  }) : super(const InitialState()) {
    on<LoadAllProductEvent>(_onLoadAllProducts);
    on<GetSingleProductEvent>(_onGetSingleProduct);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onLoadAllProducts(
    LoadAllProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const LoadingState());
    final result = await getAllProducts();
    result.fold(
      (failure) => emit(ErrorState(message: failure.toString())),
      (products) => emit(LoadedAllProductState(products: products)),
    );
  }

  Future<void> _onGetSingleProduct(
    GetSingleProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const LoadingState());
    final result = await getProduct(event.id);
    result.fold(
      (failure) => emit(ErrorState(message: failure.toString())),
      (product) => emit(LoadedSingleProductState(product: product)),
    );
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const LoadingState());
    final result = await createProduct(event.product);
    result.fold(
      (failure) => emit(ErrorState(message: failure.toString())),
      (_) => add(const LoadAllProductEvent()), // Reload products after creation
    );
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const LoadingState());
    final result = await updateProduct(event.product);
    result.fold(
      (failure) => emit(ErrorState(message: failure.toString())),
      (_) => add(const LoadAllProductEvent()), // Reload products after update
    );
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const LoadingState());
    final result = await deleteProduct(event.id);
    result.fold(
      (failure) => emit(ErrorState(message: failure.toString())),
      (_) => add(const LoadAllProductEvent()), // Reload products after deletion
    );
  }
}
