import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  NetworkBloc() : super(const NetworkState(hasNetworkConnected: false)) {
    on<NetworkChangeEvent>((event, emit) {
      emit(state.copyWith(hasNetworkConnected: event.isNetworkConnected));
    });

    _checkNetworkState();
  }

  Future<void> _checkNetworkState() async {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        add(const NetworkChangeEvent(isNetworkConnected: true));
      } else {
        add(const NetworkChangeEvent(isNetworkConnected: false));
      }
    });
  }
}
