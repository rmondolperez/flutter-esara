part of 'network_bloc.dart';

@immutable
class NetworkState {
  final bool hasNetworkConnected;

  const NetworkState({
    required this.hasNetworkConnected,
  });

  bool get isAllNetwork => hasNetworkConnected;

  NetworkState copyWith({bool? hasNetworkConnected, bool? snackBarOpen}) {
    return NetworkState(
      hasNetworkConnected: hasNetworkConnected ?? this.hasNetworkConnected,
    );
  }
}
