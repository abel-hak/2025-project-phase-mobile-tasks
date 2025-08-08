import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:product_app/core/error/failures.dart';
import 'package:product_app/features/auth/domain/entities/auth.dart';
import 'package:product_app/features/auth/domain/usecases/sign_in.dart';

import '../mocks.mocks.dart';

void main() {
  late SignIn useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignIn(mockAuthRepository);
  });

  const tEmail = 'test@test.com';
  const tPassword = 'password123';
  const tAuth = Auth(
    id: 'user123',
    name: 'Test User',
    email: 'test@test.com',
    token: 'token123',
  );

  test(
    'should sign in user when repository succeeds',
    () async {
      // arrange
      when(mockAuthRepository.signIn(
        email: tEmail,
        password: tPassword,
      )).thenAnswer((_) async => const Right(tAuth));

      // act
      final result = await useCase(SignInParams(
        email: tEmail,
        password: tPassword,
      ));

      // assert
      expect(result, const Right(tAuth));
      verify(mockAuthRepository.signIn(
        email: tEmail,
        password: tPassword,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return failure when repository fails',
    () async {
      // arrange
      final failure = ServerFailure(message: 'Server error');
      when(mockAuthRepository.signIn(
        email: tEmail,
        password: tPassword,
      )).thenAnswer((_) async => Left(failure));

      // act
      final result = await useCase(SignInParams(
        email: tEmail,
        password: tPassword,
      ));

      // assert
      expect(result, Left(failure));
      verify(mockAuthRepository.signIn(
        email: tEmail,
        password: tPassword,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
