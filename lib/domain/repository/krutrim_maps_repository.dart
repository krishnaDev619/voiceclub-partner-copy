import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/krutrim_maps/address_model.dart';

abstract class KrutrimMapsRepository {
  Future<DataState<KrutrimMapsReverseGeocodingResponseModel>> getAddress({
    required String latitude,
    required String longitude,
  });
}
