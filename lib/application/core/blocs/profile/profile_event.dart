// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ChangeAvatarEvent extends ProfileEvent {
  final String avatar;

  const ChangeAvatarEvent({required this.avatar});

  @override
  List<Object> get props => [avatar];
}

class ChangeRememberPasswordEvent extends ProfileEvent {
  final bool rememeberPassword;

  const ChangeRememberPasswordEvent({required this.rememeberPassword});

  @override
  List<Object> get props => [rememeberPassword];
}
