import 'package:esara/application/core/data/remote/remote_datasource.dart';

import 'local/secure_storage/local_secure_storage.dart';

class Repository {
  static RemoteDataSource get remote => RemoteDataSource();
  static LocalSecureStorage get localStorage => LocalSecureStorage();
}
