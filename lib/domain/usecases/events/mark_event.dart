import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/events_repository.dart';

class MarkEventUseCase implements UseCase<DataState, Params> {
  final EventsRepository _eventsRepository;

  MarkEventUseCase(this._eventsRepository);

  @override
  Future<DataState> call(Params params) {
    return _eventsRepository.markEvent(eventId: params.eventId);
  }
}

class Params extends Equatable {
  final int eventId;

  const Params({required this.eventId});

  @override
  List<Object> get props => [eventId];
}
