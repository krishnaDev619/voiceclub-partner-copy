import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/managers_feedback/update_feedback_response.dart';
import 'package:voiceclub_partner/domain/repository/managers_feedback_repository.dart';

class UpdateManagersFeedbackStatusUseCase
    implements
        UseCase<
          DataState<UpdateFeedbackResponseModel>,
          UpdateManagersFeedbackParams
        > {
  final ManagersFeedbackRepository _managersFeedbackRepository;

  UpdateManagersFeedbackStatusUseCase(this._managersFeedbackRepository);

  @override
  Future<DataState<UpdateFeedbackResponseModel>> call(
    UpdateManagersFeedbackParams params,
  ) {
    return _managersFeedbackRepository.updateManagersFeedbackStatus(
      id: params.id,
      addressed: true,
    );
  }
}

class UpdateManagersFeedbackParams extends Equatable {
  final int id;

  const UpdateManagersFeedbackParams({required this.id});

  @override
  List<Object> get props => [id];
}
