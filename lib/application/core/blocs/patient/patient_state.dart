// ignore_for_file: must_be_immutable

part of 'patient_bloc.dart';

@immutable
class PatientState {
  String? name;
  String? lastName;
  String? ci;
  String? historiaClinica;
  String? password;
  String? passwordConfirm;
  String? emergencyNumbers;

  PatientState({
    this.name,
    this.lastName,
    this.ci,
    this.historiaClinica,
    this.password,
    this.passwordConfirm,
    this.emergencyNumbers,
  });

  PatientState copyWith({
    String? name,
    String? lastName,
    String? ci,
    String? historiaClinica,
    String? password,
    String? passwordConfirm,
    String? emergencyNumbers,
  }) {
    return PatientState(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      ci: ci ?? this.ci,
      historiaClinica: historiaClinica ?? this.historiaClinica,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
      emergencyNumbers: emergencyNumbers ?? this.emergencyNumbers,
    );
  }
}

class PatientInitial extends PatientState {}

class PatientRegister extends PatientState {}

class PatientRegistered extends PatientState {}

class PatientUploadingGaitFile extends PatientState {}

class PatientUploadGaitFileSuccess extends PatientState {}

class PatientUploadingStanceFile extends PatientState {}

class PatientUploadStanceFileSuccess extends PatientState {}

class PatientUploadingSpeechFile extends PatientState {}

class PatientUploadSpeechFileSuccess extends PatientState {}

class PatientUploadingFingerFile extends PatientState {}

class PatientUploadFingerFileSuccess extends PatientState {}

class PatientUploadingHandFile extends PatientState {}

class PatientUploadHandFileSuccess extends PatientState {}

class PatientFailure extends PatientState {
  String message;
  PatientFailure({
    required this.message,
  });
}

class PatientGaitFailure extends PatientState {
  String message;
  PatientGaitFailure({
    required this.message,
  });
}

class PatientStanceFailure extends PatientState {
  String message;
  PatientStanceFailure({
    required this.message,
  });
}

class PatientSpeechFailure extends PatientState {
  String message;
  PatientSpeechFailure({
    required this.message,
  });
}

class PatientFingerFailure extends PatientState {
  String message;
  PatientFingerFailure({
    required this.message,
  });
}

class PatientHandFailure extends PatientState {
  String message;
  PatientHandFailure({
    required this.message,
  });
}
