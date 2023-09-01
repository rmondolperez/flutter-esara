// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
part of 'login_bloc.dart';

class LoginState {
  final String ci;
  final String password;
  final bool isRememberSession;
  final bool isPasswordVisible;

  LoginState({
    this.ci = '',
    this.password = '',
    this.isRememberSession = false,
    this.isPasswordVisible = true,
  });

  LoginState copyWith({
    String? ci,
    String? password,
    bool? isRememberSession,
    bool? isPasswordVisible,
  }) {
    return LoginState(
      ci: ci ?? this.ci,
      password: password ?? this.password,
      isRememberSession: isRememberSession ?? this.isRememberSession,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ci': ci,
      'password': password,
      'isRememberSession': isRememberSession,
      'isPasswordVisible': isPasswordVisible,
    };
  }
}

class Login extends LoginState {}

class LoginInitial extends LoginState {}

class LoginPerform extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  String message;
  LoginFailure({
    required this.message,
  });
}
