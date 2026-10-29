import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class UpdateLocationUseCase implements UseCase<DataState, Params> {
  final AccountRepository _supplyAccountRepository;

  UpdateLocationUseCase(this._supplyAccountRepository);

  @override
  Future<DataState> call(Params params) {
    return _supplyAccountRepository.updateLocation(
      city: params.city,
      state: params.state,
    );
  }
}

class Params extends Equatable {
  final String city;
  final String state;

  const Params({required this.city, required this.state});

  @override
  List<Object> get props => [city, state];
}
