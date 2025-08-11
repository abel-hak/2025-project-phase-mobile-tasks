import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/api_constants.dart' as api;
import 'core/network/network_info.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/check_auth_status.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/data/datasources/chat_socket_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/delete_chat.dart';
import 'features/chat/domain/usecases/get_messages_for_chat.dart';
import 'features/chat/domain/usecases/get_my_chats.dart';
import 'features/chat/domain/usecases/initiate_chat.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/chat/presentation/bloc/chat_list_bloc/chat_list_bloc.dart';
import 'features/chat/presentation/bloc/chat_messages/chat_messages_bloc.dart';
import 'features/product/data/datasources/product_local_data_source.dart';
import 'features/product/data/datasources/product_local_data_source_impl.dart';
import 'features/product/data/datasources/product_remote_data_source.dart';
import 'features/product/data/datasources/product_remote_data_source_impl.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/domain/usecases/create_product.dart';
import 'features/product/domain/usecases/delete_product.dart';
import 'features/product/domain/usecases/get_all_products.dart';
import 'features/product/domain/usecases/get_product.dart';
import 'features/product/domain/usecases/update_product.dart';
import 'features/product/presentation/bloc/product_bloc.dart';

final sl = GetIt.instance;

// API URLs
const baseUrl = 'https://g5-flutter-learning-path-be-tvum.onrender.com/api/v2'; // Real API URL for products
const chatBaseUrl = api.baseSocketUrl; // Use base URL for Socket.IO
const chatApiUrl = api.baseApiUrl; // Use v3 API URL for chat HTTP endpoints

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signUp: sl(),
      signIn: sl(),
      signOut: sl(),
      checkAuthStatus: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      client: sl(),
      baseUrl: baseUrl,
    ),
  );

  // Features - Product
  // Bloc
  sl.registerFactory(
    () => ProductBloc(
      getAllProducts: sl(),
      getProduct: sl(),
      createProduct: sl(),
      updateProduct: sl(),
      deleteProduct: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllProducts(sl()));
  sl.registerLazySingleton(() => GetProduct(sl()));
  sl.registerLazySingleton(() => CreateProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      getToken: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(
      client: sl(),
      baseUrl: baseUrl,
    ),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());

  // Features - Chat
  // Bloc
  sl.registerFactory(
    () => ChatBloc(
      chatRepository: sl(),
      initiateChat: sl(),
      deleteChat: sl(),
    ),
  );

  sl.registerFactory(
    () => ChatListBloc(sl()),
  );

  sl.registerFactory(
    () => ChatMessagesBloc(chatRepository: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMyChats(sl()));
  sl.registerLazySingleton(() => GetMessagesForChat(sl()));
  sl.registerLazySingleton(() => InitiateChat(sl()));
  sl.registerLazySingleton(() => DeleteChat(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      socketDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      client: sl(),
      baseUrl: chatApiUrl, // Use v3 API URL for all chat HTTP endpoints
    ),
  );

  sl.registerLazySingleton<ChatSocketDataSource>(
    () => ChatSocketDataSourceImpl(
      chatBaseUrl,
      socketNamespace: api.socketNamespace,
    ),
  );
}
