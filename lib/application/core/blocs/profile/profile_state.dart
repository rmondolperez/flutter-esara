// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: must_be_immutable

part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final String avatar;
  final bool rememberPassword;

  const ProfileState({this.avatar = '', this.rememberPassword = false});

  ProfileState copyWith({
    String? avatar,
    bool? rememberPassword,
  }) {
    return ProfileState(
      avatar: avatar ?? this.avatar,
      rememberPassword: rememberPassword ?? this.rememberPassword,
    );
  }

  List<Object?> get props => [avatar, rememberPassword];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'avatar': avatar,
    };
  }

  factory ProfileState.fromMap(Map<String, dynamic> map) {
    return ProfileState(
      avatar: map['avatar'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileState.fromJson(String source) =>
      ProfileState.fromMap(json.decode(source) as Map<String, dynamic>);
}
