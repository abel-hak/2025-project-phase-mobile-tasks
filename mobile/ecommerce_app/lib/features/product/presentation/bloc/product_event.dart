import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllProductEvent extends ProductEvent {
  final String token;

  const LoadAllProductEvent({required this.token});

  @override
  List<Object?> get props => [token];
}

class GetSingleProductEvent extends ProductEvent {
  final String id;
  final String token;

  const GetSingleProductEvent({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}

class UpdateProductEvent extends ProductEvent {
  final Product product;
  final String token;

  const UpdateProductEvent({required this.product, required this.token});

  @override
  List<Object?> get props => [product, token];
}

class DeleteProductEvent extends ProductEvent {
  final String id;
  final String token;

  const DeleteProductEvent({required this.id, required this.token});

  @override
  List<Object?> get props => [id, token];
}

class CreateProductEvent extends ProductEvent {
  final Product product;
  final String token;

  const CreateProductEvent({required this.product, required this.token});

  @override
  List<Object?> get props => [product, token];
}
