import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:product_app/core/error/failures.dart';
import 'package:product_app/core/usecases/usecase.dart';
import 'package:product_app/features/auth/domain/usecases/sign_out.dart';

import '../mocks.mocks.dart';

void main() {
  late SignOut useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignOut(mockAuthRepository);
  });

  test(
    'should sign out user when repository succeeds',
    () async {
      // arrange
      when(mockAuthRepository.signOut())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase(NoParams());

      // assert
      expect(result, const Right(null));
      verify(mockAuthRepository.signOut());
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return failure when repository fails',
    () async {
      // arrange
      final failure = ServerFailure(message: 'Server error');
      when(mockAuthRepository.signOut())
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await useCase(NoParams());

      // assert
      expect(result, Left(failure));
      verify(mockAuthRepository.signOut());
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
