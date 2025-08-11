import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/routes.dart';
import '../models/product.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/sign_in_screen.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> products = [
    Product(
      name: 'Air Jordan 1 Retro High',
      description:
          'Iconic Air Jordan 1 Retro High sneakers. Premium materials with classic design and exceptional comfort for everyday style.',
      price: 180,
      category: "Men's shoe",
      rating: 4.8,
      imageUrl:
          'assets/images/Air-Jordan-1-Retro-High-Travis-Scott-Product.png',
    ),
    Product(
      name: 'Puma Shoes',
      description:
          'Contemporary sports shoes designed for performance and style. Features advanced cushioning and breathable materials.',
      price: 150,
      category: "Men's shoe",
      rating: 4.5,
      imageUrl: 'assets/images/puma.png',
    ),
    Product(
      name: 'Travis Scott Edition',
      description:
          'Limited edition Travis Scott collaboration sneakers. Unique design with premium materials and exclusive styling.',
      price: 135,
      category: "Men's shoe",
      rating: 4.2,
      imageUrl: 'assets/images/travis.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Check auth state when page loads
    Future.microtask(() {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthUnauthenticated) {
        Navigator.of(context).pushReplacementNamed(Routes.signIn);
      }
    });
  }

  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    // Redirect to sign-in if not authenticated
    if (authState is! AuthAuthenticated) {
      return const SignInScreen();
    }

    // Only show home page content if authenticated
    final userName = authState.auth.name;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthUnauthenticated,
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacementNamed(Routes.signIn);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xfff7f7f7),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'July 14, 2023',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                'Hello, $userName',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(SignOutEvent());
                              },
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Title and Search Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Products',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.search_rounded,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.search);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Product List
                  Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {
                              final product = products[index];
                              Navigator.pushNamed(
                                context,
                                Routes.productDetails,
                                arguments: product,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: Image.asset(
                                      products[index].imageUrl,
                                      height: 250,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              products[index].name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '\$${products[index].price}',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              products[index].category,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '(${products[index].rating})',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'chat',
                backgroundColor: const Color(0xff4463F0),
                mini: true,
                onPressed: () {
                  Navigator.pushNamed(context, Routes.chatList);
                },
                child: const Icon(Icons.chat_outlined, size: 28),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'add',
                backgroundColor: const Color(0xff4463F0),
                shape: const CircleBorder(),
                onPressed: () async {
                  final newProduct = await Navigator.pushNamed(
                    context,
                    Routes.addProduct,
                  );
                  if (newProduct != null && newProduct is Product) {
                    setState(() {
                      products.add(newProduct);
                    });
                  }
                },
                child: const Icon(Icons.add_rounded, size: 24),
              ),
            ],
          ),
        );
      },
    );
  }
}
