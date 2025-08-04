import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class InitialState extends ProductState {
  const InitialState();
}

class LoadingState extends ProductState {
  const LoadingState();
}

class LoadedAllProductState extends ProductState {
  final List<Product> products;

  const LoadedAllProductState({required this.products});

  @override
  List<Object?> get props => [products];
}

class LoadedSingleProductState extends ProductState {
  final Product product;

  const LoadedSingleProductState({required this.product});

  @override
  List<Object?> get props => [product];
}

class ErrorState extends ProductState {
  final String message;

  const ErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
