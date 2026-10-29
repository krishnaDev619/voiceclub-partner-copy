import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/wallet/get_payout_breakdown.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';

class GetPayoutBreakdownUseCase
    implements UseCase<DataState<GetPayoutBreakdownResponse>, Params> {
  final WalletRepository _walletRepository;

  GetPayoutBreakdownUseCase(this._walletRepository);

  @override
  Future<DataState<GetPayoutBreakdownResponse>> call(Params params) {
    return _walletRepository.getPayoutBreakdown(id: params.id);
  }
}

class Params extends Equatable {
  final int id;

  const Params({required this.id});

  @override
  List<Object> get props => [id];
}
