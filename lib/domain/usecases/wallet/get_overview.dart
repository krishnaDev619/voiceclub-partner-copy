import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/wallet/get_overview_response.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';

class GetOverviewUsecase
    implements UseCase<DataState<GetOverviewResponseModel>, Params> {
  final WalletRepository _walletRepository;
  GetOverviewUsecase(this._walletRepository);

  @override
  Future<DataState<GetOverviewResponseModel>> call(Params params) {
    return _walletRepository.getOverview(
      period: params.overviewFilter.stringValue,
    );
  }
}

class Params extends Equatable {
  final OverviewFilter overviewFilter;
  const Params({required this.overviewFilter});

  @override
  List<Object> get props => [overviewFilter];
}
