import 'package:flutter/material.dart';
import 'page_transitions.dart';
import '../screens/home_page.dart';
import '../screens/add_update_page.dart';
import '../screens/details_page.dart';
import '../screens/search_page.dart';
import '../models/product.dart';

class Routes {
  static const String home = '/';
  static const String addProduct = '/add-product';
  static const String editProduct = '/edit-product';
  static const String productDetails = '/product-details';
  static const String search = '/search';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return SlidePageRoute(
          child: const HomePage(),
        );
      case addProduct:
        return SlidePageRoute(
          child: const AddUpdatePage(),
        );
      case editProduct:
        final product = settings.arguments as Product;
        return SlidePageRoute(
          child: AddUpdatePage(product: product),
        );
      case productDetails:
        final product = settings.arguments as Product;
        return SlidePageRoute(
          child: DetailsPage(product: product),
        );
      case search:
        return SlidePageRoute(
          child: const SearchPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found!'),
            ),
          ),
        );
    }
  }
}
