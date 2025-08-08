import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:product_app/core/usecases/usecase.dart';
import 'package:product_app/features/auth/domain/entities/auth.dart';
import 'package:product_app/features/auth/domain/usecases/check_auth_status.dart';

import '../mocks.mocks.dart';

void main() {
  late CheckAuthStatus useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = CheckAuthStatus(mockAuthRepository);
  });

  const tAuth = Auth(
    id: 'test_id',
    name: 'Test User',
    email: 'test@example.com',
    token: 'test_token',
  );

  test('should get auth status from the repository', () async {
    // arrange
    when(mockAuthRepository.checkAuthStatus())
        .thenAnswer((_) async => const Right(tAuth));

    // act
    final result = await useCase(NoParams());

    // assert
    expect(result, equals(const Right(tAuth)));
    verify(mockAuthRepository.checkAuthStatus());
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return null when user is not authenticated', () async {
    // arrange
    when(mockAuthRepository.checkAuthStatus())
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await useCase(NoParams());

    // assert
    expect(result, equals(const Right(null)));
    verify(mockAuthRepository.checkAuthStatus());
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
