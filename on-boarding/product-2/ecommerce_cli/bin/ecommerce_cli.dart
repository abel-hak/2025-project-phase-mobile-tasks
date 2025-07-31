import 'dart:io';
import 'package:ecommerce_cli/product_manager.dart';

void main() {
  final productManager = ProductManager();

  while (true) {
    print('\nEcommerce CLI Application');
    print('1. Add Product');
    print('2. View All Products');
    print('3. View Single Product');
    print('4. Edit Product');
    print('5. Delete Product');
    print('6. Exit');
    print('Enter your choice (1-6): ');

    var choice = stdin.readLineSync();

    try {
      switch (choice) {
        case '1':
          addProduct(productManager);
          break;
        case '2':
          viewAllProducts(productManager);
          break;
        case '3':
          viewSingleProduct(productManager);
          break;
        case '4':
          editProduct(productManager);
          break;
        case '5':
          deleteProduct(productManager);
          break;
        case '6':
          print('Goodbye!');
          exit(0);
        default:
          print('Invalid choice. Please try again.');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }
}

void addProduct(ProductManager manager) {
  print('Enter product name: ');
  var name = stdin.readLineSync() ?? '';
  print('Enter product description: ');
  var description = stdin.readLineSync() ?? '';
  print('Enter product price: ');
  var priceStr = stdin.readLineSync() ?? '';

  try {
    var price = double.parse(priceStr);
    manager.addProduct(name, description, price);
    print('Product added successfully!');
  } catch (e) {
    print('Failed to add product: ${e.toString()}');
  }
}

void viewAllProducts(ProductManager manager) {
  var products = manager.getAllProducts();
  if (products.isEmpty) {
    print('No products available.');
    return;
  }

  print('\nAll Products:');
  for (var product in products) {
    print('\n${product.toString()}\n---');
  }
}

void viewSingleProduct(ProductManager manager) {
  print('Enter product name: ');
  var name = stdin.readLineSync() ?? '';

  var product = manager.getProduct(name);
  if (product == null) {
    print('Product not found.');
    return;
  }

  print('\n${product.toString()}');
}

void editProduct(ProductManager manager) {
  print('Enter product name to edit: ');
  var name = stdin.readLineSync() ?? '';

  print('Enter new name (press Enter to skip): ');
  var newName = stdin.readLineSync();
  print('Enter new description (press Enter to skip): ');
  var newDescription = stdin.readLineSync();
  print('Enter new price (press Enter to skip): ');
  var newPriceStr = stdin.readLineSync();

  double? newPrice;
  if (newPriceStr?.isNotEmpty ?? false) {
    try {
      newPrice = double.parse(newPriceStr!);
    } catch (e) {
      print('Invalid price format.');
      return;
    }
  }

  if (newName?.isEmpty ?? true) newName = null;
  if (newDescription?.isEmpty ?? true) newDescription = null;

  var success = manager.editProduct(
    name,
    newName: newName,
    newDescription: newDescription,
    newPrice: newPrice,
  );

  if (success) {
    print('Product updated successfully!');
  } else {
    print('Product not found.');
  }
}

void deleteProduct(ProductManager manager) {
  print('Enter product name to delete: ');
  var name = stdin.readLineSync() ?? '';

  var success = manager.deleteProduct(name);
  if (success) {
    print('Product deleted successfully!');
  } else {
    print('Product not found.');
  }
}
