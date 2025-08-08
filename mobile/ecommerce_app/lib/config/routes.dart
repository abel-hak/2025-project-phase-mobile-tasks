import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/add_update_page.dart';
import '../screens/details_page.dart';
import '../screens/home_page.dart';
import '../screens/search_page.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/sign_in_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import 'page_transitions.dart';

class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String addProduct = '/add-product';
  static const String editProduct = '/edit-product';
  static const String productDetails = '/product-details';
  static const String search = '/search';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return SlidePageRoute(
          child: const SplashScreen(),
        );
      case home:
        return SlidePageRoute(
          child: const HomePage(),
        );
      case signIn:
        return SlidePageRoute(
          child: const SignInScreen(),
        );
      case signUp:
        return SlidePageRoute(
          child: const SignUpScreen(),
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
