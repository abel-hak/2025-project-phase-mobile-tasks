import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:product_app/core/network/network_info.dart';
import 'package:product_app/features/product/data/datasources/product_local_data_source.dart';
import 'package:product_app/features/product/data/datasources/product_remote_data_source.dart';
import 'package:product_app/features/product/data/datasources/product_local_data_source_impl.dart';
import 'package:product_app/features/product/data/datasources/product_remote_data_source_impl.dart';
import 'package:product_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:product_app/features/product/domain/repositories/product_repository.dart';
import 'package:product_app/features/product/domain/usecases/create_product.dart';
import 'package:product_app/features/product/domain/usecases/delete_product.dart';
import 'package:product_app/features/product/domain/usecases/get_all_products.dart';
import 'package:product_app/features/product/domain/usecases/get_product.dart';
import 'package:product_app/features/product/domain/usecases/update_product.dart';
import 'package:product_app/features/product/presentation/bloc/product_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Product
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
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(client: sl()),
  );
  
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}
