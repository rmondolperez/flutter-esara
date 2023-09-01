// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'patient_bloc.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object> get props => [];
}

class NameTextFieldEvent extends PatientEvent {
  final String name;

  const NameTextFieldEvent({required this.name});

  @override
  List<Object> get props => [name];
}

class LastNameTextField extends PatientEvent {
  final String lastName;

  const LastNameTextField({required this.lastName});

  @override
  List<Object> get props => [lastName];
}

class CiTextField extends PatientEvent {
  final String ci;

  const CiTextField({required this.ci});

  @override
  List<Object> get props => [ci];
}

class HistoriaClinicaTextField extends PatientEvent {
  final String historiaClinica;

  const HistoriaClinicaTextField({required this.historiaClinica});

  @override
  List<Object> get props => [historiaClinica];
}

class PasswordTextField extends PatientEvent {
  final String password;

  const PasswordTextField({required this.password});

  @override
  List<Object> get props => [password];
}

class PasswordConfirmacionTextField extends PatientEvent {
  final String passwordConfirmacion;

  const PasswordConfirmacionTextField({required this.passwordConfirmacion});

  @override
  List<Object> get props => [passwordConfirmacion];
}

class ChangeEmergencyNumbersEvent extends PatientEvent {
  final String emergencyNumbers;

  const ChangeEmergencyNumbersEvent({required this.emergencyNumbers});

  @override
  List<Object> get props => [emergencyNumbers];
}

class RegisterPacienteFormSubmitting extends PatientEvent {}

class UploadPacienteGaitTestSubmitting extends PatientEvent {
  final String path;
  const UploadPacienteGaitTestSubmitting({
    required this.path,
  });
}

class UploadPacienteStanceTestSubmitting extends PatientEvent {
  final String path;
  const UploadPacienteStanceTestSubmitting({
    required this.path,
  });
}

class UploadPacienteSpeechTestSubmitting extends PatientEvent {
  final String path;
  const UploadPacienteSpeechTestSubmitting({
    required this.path,
  });
}

class UploadPacienteFingerTestSubmitting extends PatientEvent {
  final String path;
  const UploadPacienteFingerTestSubmitting({
    required this.path,
  });
}

class UploadPacienteHandTestSubmitting extends PatientEvent {
  final String path;
  const UploadPacienteHandTestSubmitting({
    required this.path,
  });
}
