import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:product_app/core/error/failures.dart';
import 'package:product_app/features/auth/domain/entities/auth.dart';
import 'package:product_app/features/auth/domain/usecases/sign_up.dart';

import '../mocks.mocks.dart';

void main() {
  late SignUp useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignUp(mockAuthRepository);
  });

  const tEmail = 'test@test.com';
  const tPassword = 'password123';
  const tName = 'Test User';
  const tAuth = Auth(
    id: 'user123',
    name: tName,
    email: tEmail,
    token: 'token123',
  );

  test(
    'should sign up user when repository succeeds',
    () async {
      // arrange
      when(mockAuthRepository.signUp(
        email: tEmail,
        password: tPassword,
        name: tName,
      )).thenAnswer((_) async => const Right(tAuth));

      // act
      final result = await useCase(SignUpParams(
        email: tEmail,
        password: tPassword,
        name: tName,
      ));

      // assert
      expect(result, const Right(tAuth));
      verify(mockAuthRepository.signUp(
        email: tEmail,
        password: tPassword,
        name: tName,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return failure when repository fails',
    () async {
      // arrange
      when(mockAuthRepository.signUp(
        email: tEmail,
        password: tPassword,
        name: tName,
      )).thenAnswer((_) async => Left(ServerFailure(message: 'Server error')));

      // act
      final result = await useCase(SignUpParams(
        email: tEmail,
        password: tPassword,
        name: tName,
      ));

      // assert
      expect(result, Left(ServerFailure(message: 'Server error')));
      verify(mockAuthRepository.signUp(
        email: tEmail,
        password: tPassword,
        name: tName,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
