import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/get_chat_filter_options_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetChatFilterOptionsUsecase
    implements
        UseCase<
          DataState<GetChatFilterOptionsResponseModel>,
          GetChatFilterOptionsParams
        > {
  final ChatRepository _chatRepository;

  GetChatFilterOptionsUsecase(this._chatRepository);

  @override
  Future<DataState<GetChatFilterOptionsResponseModel>> call(
    GetChatFilterOptionsParams params,
  ) {
    return _chatRepository.getSupplyChatFilterOptions(
      category: params.categoryCode.name,
    );
  }
}

class GetChatFilterOptionsParams extends Equatable {
  final CategoryCode categoryCode;

  const GetChatFilterOptionsParams({required this.categoryCode});

  @override
  List<Object> get props => [categoryCode];
}
