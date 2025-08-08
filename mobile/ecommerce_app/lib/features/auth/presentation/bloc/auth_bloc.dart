import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;
  final CheckAuthStatus checkAuthStatus;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.checkAuthStatus,
  }) : super(AuthInitial()) {
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signIn(
      SignInParams(
        email: event.email,
        password: event.password,
      ),
    );

    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (auth) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', auth.token);
        emit(AuthAuthenticated(auth));
      },
    );
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    print('AuthBloc: Handling SignUpEvent');
    print('AuthBloc: Email - ${event.email}');
    print('AuthBloc: Name - ${event.name}');

    emit(AuthLoading());
    print('AuthBloc: Emitted AuthLoading state');

    try {
      print('AuthBloc: Calling signUp usecase');
      final result = await signUp(
        SignUpParams(
          email: event.email,
          password: event.password,
          name: event.name,
        ),
      );
      print('AuthBloc: signUp usecase completed');

      await result.fold(
        (failure) async {
          print('AuthBloc: Sign up failed - ${failure.message}');
          if (!emit.isDone) emit(AuthError(failure.message));
        },
        (auth) async {
          print('AuthBloc: Sign up successful, saving token');
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', auth.token);
            print('AuthBloc: Token saved, emitting AuthAuthenticated');
            if (!emit.isDone) emit(AuthAuthenticated(auth));
          } catch (e) {
            print('AuthBloc: Failed to save token - $e');
            if (!emit.isDone)
              emit(AuthError('Failed to save authentication token'));
          }
        },
      );
    } catch (e) {
      print('AuthBloc: Unexpected error during sign up - $e');
      if (!emit.isDone) emit(AuthError('An unexpected error occurred'));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signOut(NoParams());

    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkAuthStatus(NoParams());

    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (auth) async => emit(
        auth != null ? AuthAuthenticated(auth) : AuthUnauthenticated(),
      ),
    );
  }
}
