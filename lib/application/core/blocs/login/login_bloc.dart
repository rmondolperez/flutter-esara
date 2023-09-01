import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../data/repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState()) {
    on<LoginUserCiChanged>((event, emit) {
      emit(state.copyWith(
          ci: event.ci,
          password: state.password,
          isRememberSession: state.isRememberSession));
    });

    on<LoginUserPasswordChanged>((event, emit) {
      emit(state.copyWith(
          password: event.password,
          ci: state.ci,
          isRememberSession: state.isRememberSession));
    });

    on<RememberSessionChanged>((event, emit) {
      emit(state.copyWith(
          isRememberSession: event.isRememberSession,
          password: state.password,
          ci: state.ci));
    });

    on<PasswordVisibility>((event, emit) {
      emit(state.copyWith(isPasswordVisible: event.isPasswordVisible));
    });

    on<LoginFormInitial>((event, emit) {
      emit(Login());
    });

    on<LoginFormSubmitting>((event, emit) async {
      String ci = state.ci;
      String password = state.password;
      emit(LoginInitial());
      Future.delayed(const Duration(seconds: 3));
      final loginResult = await Repository.remote.login(ci, password);

      loginResult.fold((l) {
        emit(LoginFailure(message: l.message));
      }, (r) {
        emit(LoginSuccess());
      });
    });
  }
}
