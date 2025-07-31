import 'product.dart';

class ProductManager {
  final List<Product> _products = [];

  // Add a new product
  void addProduct(String name, String description, double price) {
    try {
      _products.add(Product(name, description, price));
    } catch (e) {
      throw ArgumentError('Failed to add product: ${e.toString()}');
    }
  }

  // View all products
  List<Product> getAllProducts() {
    return List.unmodifiable(_products);
  }

  // View a single product
  Product? getProduct(String name) {
    try {
      return _products.firstWhere((product) => product.name == name);
    } catch (e) {
      return null;
    }
  }

  // Edit a product
  bool editProduct(String name, {String? newName, String? newDescription, double? newPrice}) {
    var product = getProduct(name);
    if (product == null) return false;

    try {
      if (newName != null) product.name = newName;
      if (newDescription != null) product.description = newDescription;
      if (newPrice != null) product.price = newPrice;
      return true;
    } catch (e) {
      throw ArgumentError('Failed to edit product: ${e.toString()}');
    }
  }

  // Delete a product
  bool deleteProduct(String name) {
    var product = getProduct(name);
    if (product == null) return false;
    
    _products.remove(product);
    return true;
  }
}
