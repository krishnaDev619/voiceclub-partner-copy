import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class UpdateCustomNameUseCase implements UseCase<DataState<void>, Params> {
  final ChatRepository _chatRepository;

  UpdateCustomNameUseCase(this._chatRepository);

  @override
  Future<DataState<void>> call(Params params) async {
    return _chatRepository.updateCustomName(
      name: params.name,
      accountId: params.accountId,
    );
  }
}

class Params extends Equatable {
  final String name;
  final int accountId;

  const Params({required this.name, required this.accountId});

  @override
  List<Object> get props => [name, accountId];
}
