import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/account/get_meeting_schedule_response.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class GetMeetingScheduleUseCase
    implements UseCase<DataState<GetMeetingScheduleResponseModel>, NoParams> {
  final AccountRepository _supplyAccountRepository;

  GetMeetingScheduleUseCase(this._supplyAccountRepository);

  @override
  Future<DataState<GetMeetingScheduleResponseModel>> call(NoParams params) {
    return _supplyAccountRepository.getMeetingSchedule(page: 1, pageSize: 5);
  }
}
