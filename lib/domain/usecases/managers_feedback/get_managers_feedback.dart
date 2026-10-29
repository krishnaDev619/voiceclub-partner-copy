import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/managers_feedback/get_managers_feedback_response.dart';
import 'package:voiceclub_partner/domain/repository/managers_feedback_repository.dart';

class GetManagersFeedbackUseCase
    implements UseCase<DataState<GetManagersFeedbackResponseModel>, Params> {
  final ManagersFeedbackRepository _managersFeedbackRepository;

  GetManagersFeedbackUseCase(this._managersFeedbackRepository);

  @override
  Future<DataState<GetManagersFeedbackResponseModel>> call(Params params) {
    return _managersFeedbackRepository.getManagersFeedback(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class Params extends Equatable {
  final int? page;
  final int? pageSize;

  const Params({this.page, this.pageSize});

  @override
  List<Object?> get props => [page, pageSize];
}
