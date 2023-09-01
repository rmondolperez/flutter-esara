part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoginUserCiChanged extends LoginEvent {
  final String ci;

  LoginUserCiChanged({required this.ci});
}

class LoginUserPasswordChanged extends LoginEvent {
  final String password;

  LoginUserPasswordChanged({required this.password});
}

class RememberSessionChanged extends LoginEvent {
  final bool isRememberSession;

  RememberSessionChanged({required this.isRememberSession});
}

class PasswordVisibility extends LoginEvent {
  final bool isPasswordVisible;

  PasswordVisibility({required this.isPasswordVisible});
}

class LoginFormInitial extends LoginEvent {}

class LoginFormSubmitting extends LoginEvent {}
