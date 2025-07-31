import '../../domain/entities/product_entity.dart';
import 'product_data_source.dart';

class InMemoryProductDataSource implements ProductDataSource {
  final List<ProductEntity> _products = [
    ProductEntity(
      id: '1',
      name: 'Air Jordan 1 Retro High',
      description: 'Travis Scott collaboration featuring a reverse Swoosh design',
      price: 999.99,
      imageUrl: 'assets/images/Air-Jordan-1-Retro-High-Travis-Scott-Product.png',
      category: "Men's shoe",
      rating: 4.8,
    ),
    ProductEntity(
      id: '2',
      name: 'Puma RS-X',
      description: 'Modern running-inspired sneakers with bold design',
      price: 149.99,
      imageUrl: 'assets/images/puma.png',
      category: "Men's shoe",
      rating: 4.5,
    ),
  ];

  @override
  Future<ProductEntity> insertProduct(ProductEntity product) async {
    final newProduct = product.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _products.add(newProduct);
    return newProduct;
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      throw Exception('Product not found');
    }
    _products[index] = product;
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((product) => product.id == id);
  }

  @override
  Future<ProductEntity> getProduct(String id) async {
    final product = _products.firstWhere(
      (product) => product.id == id,
      orElse: () => throw Exception('Product not found'),
    );
    return product;
  }

  @override
  Future<List<ProductEntity>> getAllProducts() async {
    return List.from(_products);
  }
}
