import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';

/// Converts a Retrofit [HttpResponse] to [DataState].
/// Returns [DataSuccess] when status code is 200, otherwise [DataFailed] with a [DioException].
DataState<T> toDataState<T>(HttpResponse<T> response) {
  if (response.response.statusCode == 200) {
    return DataSuccess(response.data);
  }
  return DataFailed(
    DioException(
      error: response.response.statusCode,
      message: response.response.statusMessage,
      response: response.response,
      requestOptions: response.response.requestOptions,
    ),
  );
}
