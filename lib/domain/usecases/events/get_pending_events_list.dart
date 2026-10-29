import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/events/get_pending_events_list_response.dart';
import 'package:voiceclub_partner/domain/repository/events_repository.dart';

class GetPendingEventsListUseCase
    implements UseCase<DataState<GetPendingEventsListResponseModel>, NoParams> {
  final EventsRepository _eventsRepository;

  GetPendingEventsListUseCase(this._eventsRepository);

  @override
  Future<DataState<GetPendingEventsListResponseModel>> call(NoParams params) {
    return _eventsRepository.getPendingEventsList();
  }
}
