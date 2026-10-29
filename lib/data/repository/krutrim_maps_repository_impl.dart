import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/krutrim_maps/krutrim_maps_api_service.dart';
import 'package:voiceclub_partner/data/models/krutrim_maps/address_model.dart';
import 'package:voiceclub_partner/domain/repository/krutrim_maps_repository.dart';

class KrutrimMapsRepositoryImpl extends KrutrimMapsRepository {
  final KrutrimMapsApiService _krutrimMapsApiService;

  KrutrimMapsRepositoryImpl(this._krutrimMapsApiService);

  @override
  Future<DataState<KrutrimMapsReverseGeocodingResponseModel>> getAddress({
    required String latitude,
    required String longitude,
  }) async {
    try {
      final response = await _krutrimMapsApiService.getAddress(
        latitude: latitude,
        longitude: longitude,
      );
      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
