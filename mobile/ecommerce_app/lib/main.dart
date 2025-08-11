import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routes.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/chat/presentation/bloc/chat_messages/chat_messages_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (_) => di.sl<ChatBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<ChatMessagesBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Product App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: Routes.splash,
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }
}
