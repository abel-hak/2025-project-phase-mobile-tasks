import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:product_app/core/network/network_info.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([InternetConnectionChecker])
void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker mockConnectionChecker;

  setUp(() {
    mockConnectionChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(mockConnectionChecker);
  });

  group('isConnected', () {
    test('should forward the call to InternetConnectionChecker.hasConnection', () async {
      // arrange
      final tHasConnectionFuture = Future.value(true);
      when(mockConnectionChecker.hasConnection).thenAnswer((_) => tHasConnectionFuture);
      
      // act
      final result = networkInfo.isConnected;
      
      // assert
      verify(mockConnectionChecker.hasConnection);
      expect(result, tHasConnectionFuture);
    });
  });
}
