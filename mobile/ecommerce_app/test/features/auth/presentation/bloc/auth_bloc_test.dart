import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_app/core/error/failures.dart';
import 'package:product_app/features/auth/domain/entities/auth.dart';
import 'package:product_app/features/auth/domain/usecases/check_auth_status.dart';
import 'package:product_app/features/auth/domain/usecases/sign_in.dart';
import 'package:product_app/features/auth/domain/usecases/sign_out.dart';
import 'package:product_app/features/auth/domain/usecases/sign_up.dart';
import 'package:product_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:product_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:product_app/features/auth/presentation/bloc/auth_state.dart';

import '../../domain/mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.setMockInitialValues({});

  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late SignIn signIn;
  late SignUp signUp;
  late SignOut signOut;
  late CheckAuthStatus checkAuthStatus;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signIn = SignIn(mockAuthRepository);
    signUp = SignUp(mockAuthRepository);
    signOut = SignOut(mockAuthRepository);
    checkAuthStatus = CheckAuthStatus(mockAuthRepository);

    authBloc = AuthBloc(
      signIn: signIn,
      signUp: signUp,
      signOut: signOut,
      checkAuthStatus: checkAuthStatus,
    );
  });

  const tAuth = Auth(
    id: 'test_user_id',
    name: 'Test User',
    email: 'test@example.com',
    token: 'test_token',
  );

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tName = 'Test User';
  const tErrorMessage = 'An error occurred';

  group('SignUpEvent', () {
    test(
      'should emit [AuthLoading, AuthAuthenticated] when sign up is successful',
      () async {
        // arrange
        when(mockAuthRepository.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        )).thenAnswer((_) async => const Right(tAuth));

        // act
        authBloc.add(const SignUpEvent(
          email: tEmail,
          password: tPassword,
          name: tName,
        ));

        // assert
        await expectLater(
          authBloc.stream,
          emitsInOrder([
            AuthLoading(),
            AuthAuthenticated(tAuth),
          ]),
        );
        verify(mockAuthRepository.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        ));
      },
    );

    test(
      'should emit [AuthLoading, AuthError] when sign up fails',
      () async {
        // arrange
        when(mockAuthRepository.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        )).thenAnswer((_) async => Left(ServerFailure(message: tErrorMessage)));

        // act
        authBloc.add(const SignUpEvent(
          email: tEmail,
          password: tPassword,
          name: tName,
        ));

        // assert
        await expectLater(
          authBloc.stream,
          emitsInOrder([
            AuthLoading(),
            AuthError(tErrorMessage),
          ]),
        );
        verify(mockAuthRepository.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        ));
      },
    );
  });

  group('SignInEvent', () {
    test(
      'should emit [AuthLoading, AuthAuthenticated] when sign in is successful',
      () async {
        // arrange
        final auth = Auth(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          token: 'token123',
        );
        when(mockAuthRepository.signIn(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => Right(auth));

        // act
        authBloc.add(SignInEvent(
          email: 'test@test.com',
          password: 'password',
        ));

        // assert
        final expected = [
          AuthLoading(),
          AuthAuthenticated(auth),
        ];
        await expectLater(authBloc.stream, emitsInOrder(expected));
      },
    );

    test(
      'should emit [AuthLoading, AuthError] when sign in fails',
      () async {
        // arrange
        final failure = ServerFailure(message: 'Server error');
        when(mockAuthRepository.signIn(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => Left(failure));

        // act
        authBloc.add(SignInEvent(
          email: 'test@test.com',
          password: 'password',
        ));

        // assert
        final expected = [
          AuthLoading(),
          AuthError(failure.message),
        ];
        await expectLater(authBloc.stream, emitsInOrder(expected));
      },
    );
  });

  group('SignOutEvent', () {
    test(
      'should emit [AuthLoading, AuthUnauthenticated] when sign out is successful',
      () async {
        // arrange
        when(mockAuthRepository.signOut())
            .thenAnswer((_) async => const Right(null));

        // assert later
        final expected = [
          AuthLoading(),
          AuthUnauthenticated(),
        ];
        expectLater(authBloc.stream, emitsInOrder(expected));

        // act
        authBloc.add(SignOutEvent());
      },
    );

    test(
      'should emit [AuthLoading, AuthError] when sign out fails',
      () async {
        // arrange
        when(mockAuthRepository.signOut()).thenAnswer(
            (_) async => Left(ServerFailure(message: tErrorMessage)));

        // assert later
        final expected = [
          AuthLoading(),
          AuthError(tErrorMessage),
        ];
        expectLater(authBloc.stream, emitsInOrder(expected));

        // act
        authBloc.add(SignOutEvent());
      },
    );
  });
}
