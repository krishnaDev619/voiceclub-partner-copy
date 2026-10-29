import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/krutrim_maps/address_model.dart';
import 'package:voiceclub_partner/domain/repository/krutrim_maps_repository.dart';

class GetAddressUseCase
    implements
        UseCase<DataState<KrutrimMapsReverseGeocodingResponseModel>, Params> {
  final KrutrimMapsRepository _krutrimMapsRepository;

  GetAddressUseCase(this._krutrimMapsRepository);

  @override
  Future<DataState<KrutrimMapsReverseGeocodingResponseModel>> call(
    Params params,
  ) {
    return _krutrimMapsRepository.getAddress(
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class Params extends Equatable {
  final String latitude;
  final String longitude;

  const Params({required this.latitude, required this.longitude});

  @override
  List<Object> get props => [latitude, longitude];
}
