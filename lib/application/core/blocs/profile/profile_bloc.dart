// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> with HydratedMixin {
  ProfileBloc() : super(ProfileState()) {
    on<ChangeAvatarEvent>((event, emit) {
      emit(state.copyWith(avatar: event.avatar));
    });

    on<ChangeRememberPasswordEvent>((event, emit) {
      emit(state.copyWith(rememberPassword: event.rememeberPassword));
    });
  }

  @override
  ProfileState? fromJson(Map<String, dynamic> json) {
    return ProfileState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(ProfileState state) {
    return state.toMap();
  }
}
