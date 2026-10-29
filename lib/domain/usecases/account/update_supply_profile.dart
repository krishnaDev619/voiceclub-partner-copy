import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class UpdateSupplyProfileUseCase
    implements UseCase<DataState, UpdateSupplyProfileParams> {
  final AccountRepository _supplyAccountRepository;

  UpdateSupplyProfileUseCase(this._supplyAccountRepository);

  @override
  Future<DataState> call(UpdateSupplyProfileParams params) {
    return _supplyAccountRepository.updateSupplyProfile(
      name: params.name,
      avatarUrl: params.avatarUrl,
    );
  }
}

class UpdateSupplyProfileParams extends Equatable {
  final String name;
  final String avatarUrl;

  const UpdateSupplyProfileParams({
    required this.name,
    required this.avatarUrl,
  });

  @override
  List<Object> get props => [name, avatarUrl];
}
