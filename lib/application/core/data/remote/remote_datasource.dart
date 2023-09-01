import 'package:dartz/dartz.dart';
import 'package:esara/application/core/data/remote/api_client.dart';

class RemoteDataSource {
  final _apiClient = ApiClient();

  Future<Either<ApiFailure, bool>> register(
    String name,
    String lastName,
    String ci,
    String noHistoriaClinica,
    String password,
    String passwordConfirmacion,
  ) {
    return _apiClient.register(
      name,
      lastName,
      ci,
      noHistoriaClinica,
      password,
      passwordConfirmacion,
    );
  }

  Future<Either<ApiFailure, bool>> login(
    String ci,
    String password,
  ) {
    return _apiClient.login(ci, password);
  }

  Future<Either<ApiFailure, bool>> uploadMediaFile(
    String path,
  ) {
    return _apiClient.uploadMediaFile(path);
  }
}
