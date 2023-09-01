part of 'network_bloc.dart';

@immutable
abstract class NetworkEvent extends Equatable {
  const NetworkEvent();

  @override
  List<Object> get props => [];
}

class NetworkChangeEvent extends NetworkEvent {
  final bool isNetworkConnected;

  const NetworkChangeEvent({required this.isNetworkConnected});
}
