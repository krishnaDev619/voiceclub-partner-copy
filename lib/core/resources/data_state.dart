import 'package:dio/dio.dart';

abstract class DataState<T> {
  final T? data;
  final DioException? error;

  String get errorMessage {
    try {
      if (error?.response?.data != null &&
          error?.response?.data is Map &&
          error?.response?.data.containsKey('message')) {
        final message = error?.response?.data['message'];
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {}
    return "Something went wrong";
  }

  String get errorDetail {
    try {
      if (error?.response?.data != null &&
          error?.response?.data is Map &&
          error?.response?.data.containsKey('detail')) {
        final detail = error?.response?.data['detail'];
        if (detail != null && detail.toString().isNotEmpty) {
          return detail.toString();
        }
      }
    } catch (_) {}
    return "Please try again";
  }

  const DataState({this.data, this.error});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(DioException error) : super(error: error);
}
