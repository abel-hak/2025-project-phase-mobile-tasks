import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_app/core/injection/injection_container.dart' as di;
import 'package:product_app/core/network/network_info.dart';
import 'package:product_app/features/product/data/datasources/product_local_data_source.dart';
import 'package:product_app/features/product/data/datasources/product_remote_data_source.dart';
import 'package:product_app/features/product/data/datasources/product_local_data_source_impl.dart';
import 'package:product_app/features/product/data/datasources/product_remote_data_source_impl.dart';
import 'package:product_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:product_app/features/product/domain/repositories/product_repository.dart';
import 'package:product_app/features/product/domain/usecases/get_all_products.dart';
import 'package:product_app/features/product/domain/usecases/get_product.dart';
import 'package:product_app/features/product/domain/usecases/create_product.dart';
import 'package:product_app/features/product/domain/usecases/update_product.dart';
import 'package:product_app/features/product/domain/usecases/delete_product.dart';
import 'package:product_app/features/product/presentation/bloc/product_bloc.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await di.init();
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  test('should register ProductBloc as factory', () {
    // act
    final productBloc = GetIt.instance<ProductBloc>();
    final productBloc2 = GetIt.instance<ProductBloc>();

    // assert
    expect(productBloc, isA<ProductBloc>());
    expect(productBloc, isNot(same(productBloc2)));
  });

  test('should register use cases as lazy singletons', () {
    // act & assert
    final getAllProducts = GetIt.instance<GetAllProducts>();
    final getProduct = GetIt.instance<GetProduct>();
    final createProduct = GetIt.instance<CreateProduct>();
    final updateProduct = GetIt.instance<UpdateProduct>();
    final deleteProduct = GetIt.instance<DeleteProduct>();

    expect(getAllProducts, isA<GetAllProducts>());
    expect(getProduct, isA<GetProduct>());
    expect(createProduct, isA<CreateProduct>());
    expect(updateProduct, isA<UpdateProduct>());
    expect(deleteProduct, isA<DeleteProduct>());
  });

  test('should register repository implementations as lazy singletons', () {
    // act & assert
    final repository = GetIt.instance<ProductRepository>();
    final localDataSource = GetIt.instance<ProductLocalDataSource>();
    final remoteDataSource = GetIt.instance<ProductRemoteDataSource>();
    final networkInfo = GetIt.instance<NetworkInfo>();

    expect(repository, isA<ProductRepositoryImpl>());
    expect(localDataSource, isA<ProductLocalDataSourceImpl>());
    expect(remoteDataSource, isA<ProductRemoteDataSourceImpl>());
    expect(networkInfo, isA<NetworkInfoImpl>());
  });

  test('should register external dependencies as lazy singletons', () {
    // act & assert
    expect(GetIt.instance<SharedPreferences>(), isA<SharedPreferences>());
    expect(GetIt.instance<http.Client>(), isA<http.Client>());
    expect(GetIt.instance<InternetConnectionChecker>(), isA<InternetConnectionChecker>());
  });
}
