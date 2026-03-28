import 'package:travel_planner/data/response/status.dart';

class ApiResponse<T> {
  Status? status;
  T? data;
  String? message;

  ApiResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  ApiResponse.initial() : status = Status.initial;

  ApiResponse.loading() : status = Status.loading;

  ApiResponse.success(this.data) : status = Status.success;

  ApiResponse.error(this.message) : status = Status.error;

  String toString() {
    return "Status: $status \n Data: $data \n Message: $message";
  }
}
