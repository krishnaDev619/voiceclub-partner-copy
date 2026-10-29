import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/events/get_event_data_response.dart';
import 'package:voiceclub_partner/domain/repository/events_repository.dart';

class GetEventDataUseCase
    implements UseCase<DataState<GetEventDataResponseModel>, Params> {
  final EventsRepository _eventsRepository;

  GetEventDataUseCase(this._eventsRepository);

  @override
  Future<DataState<GetEventDataResponseModel>> call(Params params) {
    return _eventsRepository.getEventData(
      event: params.event,
      propertyId: params.propertyId,
    );
  }
}

class Params extends Equatable {
  final String event;
  final String propertyId;

  const Params({required this.event, required this.propertyId});

  @override
  List<Object> get props => [event, propertyId];
}
