// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/repository.dart';

part 'patient_event.dart';
part 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  PatientBloc() : super(PatientInitial()) {
    on<NameTextFieldEvent>((event, emit) {
      emit(state.copyWith(
          name: event.name,
          lastName: state.lastName,
          ci: state.ci,
          historiaClinica: state.historiaClinica,
          password: state.password,
          passwordConfirm: state.passwordConfirm));
    });

    on<LastNameTextField>((event, emit) {
      emit(state.copyWith(
          lastName: event.lastName,
          name: state.name,
          ci: state.ci,
          historiaClinica: state.historiaClinica,
          password: state.password,
          passwordConfirm: state.passwordConfirm));
    });

    on<CiTextField>((event, emit) {
      emit(state.copyWith(
          ci: event.ci,
          name: state.name,
          lastName: state.lastName,
          historiaClinica: state.historiaClinica,
          password: state.password,
          passwordConfirm: state.passwordConfirm));
    });

    on<HistoriaClinicaTextField>((event, emit) {
      emit(state.copyWith(
          historiaClinica: event.historiaClinica,
          ci: state.ci,
          name: state.name,
          lastName: state.lastName,
          password: state.password,
          passwordConfirm: state.passwordConfirm));
    });

    on<PasswordTextField>((event, emit) {
      emit(state.copyWith(
          password: event.password,
          name: state.name,
          lastName: state.lastName,
          ci: state.ci,
          historiaClinica: state.historiaClinica,
          passwordConfirm: state.passwordConfirm));
      add(PasswordConfirmacionTextField(passwordConfirmacion: event.password));
    });

    on<PasswordConfirmacionTextField>((event, emit) {
      emit(state.copyWith(
          password: state.password,
          name: state.name,
          lastName: state.lastName,
          ci: state.ci,
          historiaClinica: state.historiaClinica,
          passwordConfirm: event.passwordConfirmacion));
    });

    on<RegisterPacienteFormSubmitting>((event, emit) async {
      String name = state.name ?? '';
      String lastName = state.lastName ?? '';
      String ci = state.ci ?? '';
      String historia = state.lastName ?? '';
      String password = state.password ?? '';
      String passwordConfirmacion = state.passwordConfirm ?? '';

      emit(PatientRegister());
      Future.delayed(const Duration(seconds: 3));
      final registerResult = await Repository.remote.register(
        name,
        lastName,
        ci,
        historia,
        password,
        passwordConfirmacion,
      );

      registerResult.fold((l) {
        emit(PatientFailure(message: l.message));
      }, (r) {
        emit(PatientRegistered());
      });
    });

    on<UploadPacienteGaitTestSubmitting>((event, emit) async {
      emit(PatientUploadingGaitFile());
      Future.delayed(const Duration(seconds: 3));

      final uploadMediaFileResult =
          await Repository.remote.uploadMediaFile(event.path);

      uploadMediaFileResult.fold((l) {
        emit(PatientGaitFailure(message: l.message));
      }, (r) {
        emit(PatientUploadGaitFileSuccess());
      });
    });

    on<UploadPacienteStanceTestSubmitting>((event, emit) async {
      emit(PatientUploadingStanceFile());
      Future.delayed(const Duration(seconds: 3));

      final uploadMediaFileResult =
          await Repository.remote.uploadMediaFile(event.path);

      uploadMediaFileResult.fold((l) {
        emit(PatientStanceFailure(message: l.message));
      }, (r) {
        emit(PatientUploadStanceFileSuccess());
      });
    });

    on<UploadPacienteSpeechTestSubmitting>((event, emit) async {
      emit(PatientUploadingSpeechFile());
      Future.delayed(const Duration(seconds: 3));
      final uploadMediaFileResult =
          await Repository.remote.uploadMediaFile(event.path);

      uploadMediaFileResult.fold((l) {
        emit(PatientSpeechFailure(message: l.message));
      }, (r) {
        emit(PatientUploadSpeechFileSuccess());
      });
    });

    on<UploadPacienteFingerTestSubmitting>((event, emit) async {
      emit(PatientUploadingFingerFile());
      Future.delayed(const Duration(seconds: 3));

      final uploadMediaFileResult =
          await Repository.remote.uploadMediaFile(event.path);

      uploadMediaFileResult.fold((l) {
        emit(PatientFingerFailure(message: l.message));
      }, (r) {
        emit(PatientUploadFingerFileSuccess());
      });
    });

    on<UploadPacienteHandTestSubmitting>((event, emit) async {
      emit(PatientUploadingHandFile());
      Future.delayed(const Duration(seconds: 3));

      final uploadMediaFileResult =
          await Repository.remote.uploadMediaFile(event.path);

      uploadMediaFileResult.fold((l) {
        emit(PatientHandFailure(message: l.message));
      }, (r) {
        emit(PatientUploadHandFileSuccess());
      });
    });

    on<ChangeEmergencyNumbersEvent>((event, emit) async {
      emit(state.copyWith(emergencyNumbers: event.emergencyNumbers));
    });
  }
}
