import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllProductEvent extends ProductEvent {
  const LoadAllProductEvent();
}

class GetSingleProductEvent extends ProductEvent {
  final String id;

  const GetSingleProductEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class UpdateProductEvent extends ProductEvent {
  final Product product;

  const UpdateProductEvent({required this.product});

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final String id;

  const DeleteProductEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class CreateProductEvent extends ProductEvent {
  final Product product;

  const CreateProductEvent({required this.product});

  @override
  List<Object?> get props => [product];
}
