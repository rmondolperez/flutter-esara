class ApiError {
  ApiError({
    required this.error,
    required this.status,
    required this.message,
    required this.errors,
    required this.timestamp,
  });
  late final bool error;
  late final int status;
  late final String message;
  late final Errors errors;
  late final String timestamp;

  ApiError.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    status = json['status'];
    message = json['message'];
    errors = Errors.fromJson(json['errors']);
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['error'] = error;
    _data['status'] = status;
    _data['message'] = message;
    _data['errors'] = errors.toJson();
    _data['timestamp'] = timestamp;
    return _data;
  }
}

class Errors {
  Errors({
    required this.unique,
  });
  late final String unique;

  Errors.fromJson(Map<String, dynamic> json) {
    unique = json['unique'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['unique'] = unique;
    return _data;
  }
}
