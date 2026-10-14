part of 'auth_bloc.dart';

@freezed
abstract class AuthState with _$AuthState {
  factory AuthState._({
    @Default(AuthStatus.unauthenticated) AuthStatus status,
  }) = _AuthState;
}

extension XAuthState on AuthState {
  static AuthState guest() => AuthState._(status: AuthStatus.guest);

  static AuthState authenticated() =>
      AuthState._(status: AuthStatus.authenticated);
      
  static AuthState unauthenticated() =>
      AuthState._(status: AuthStatus.unauthenticated);
}
