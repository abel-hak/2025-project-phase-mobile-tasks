import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/chat/presentation/bloc/chat_list_bloc/chat_list_event.dart';
import '../features/chat/presentation/screens/chat_list_screen.dart';
import '../features/chat/presentation/bloc/chat_bloc.dart';
import '../injection_container.dart';
import '../models/product.dart';
import '../screens/add_update_page.dart';
import '../screens/details_page.dart';
import '../screens/home_page.dart';
import '../screens/search_page.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/sign_in_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/chat/presentation/bloc/chat_list_bloc/chat_list_bloc.dart';
import '../features/chat/presentation/bloc/chat_messages/chat_messages_bloc.dart';
import '../features/chat/presentation/screens/chat_detail_screen.dart';
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
  static const String chatList = '/chat-list';
  static const String chatDetail = '/chat-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return SlidePageRoute(
          child: const SplashScreen(),
        );
      case home:
        return MaterialPageRoute(
          builder: (context) {
            final authState = context.read<AuthBloc>().state;
            if (authState is! AuthAuthenticated) {
              return const SignInScreen();
            }
            return const HomePage();
          },
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
      case chatList:
        return MaterialPageRoute(
          builder: (context) {
            final authState = context.read<AuthBloc>().state;
            final token = authState is AuthAuthenticated ? authState.auth.token : '';
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => sl<ChatListBloc>()..add(LoadChatList(token)),
                ),
                BlocProvider(
                  create: (_) => sl<ChatBloc>(),
                ),
              ],
              child: const ChatListScreen(),
            );
          },
        );
      case chatDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<ChatMessagesBloc>(),
            child: ChatDetailScreen(
              chatId: args['chatId'] as String,
              receiverName: args['receiverName'] as String,
              token: args['token'] as String,
            ),
          ),
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
