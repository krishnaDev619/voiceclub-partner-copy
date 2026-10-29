import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/get_chat_groups_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetChatGroupsUsecase
    implements
        UseCase<DataState<GetChatGroupsResponseModel>, GetChatGroupsParams> {
  final ChatRepository _chatRepository;

  GetChatGroupsUsecase(this._chatRepository);

  @override
  Future<DataState<GetChatGroupsResponseModel>> call(
    GetChatGroupsParams params,
  ) {
    return _chatRepository.getChatGroups(
      category: params.category,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetChatGroupsParams extends Equatable {
  final String category;
  final int page;
  final int pageSize;

  const GetChatGroupsParams({
    required this.category,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object> get props => [category, page, pageSize];
}
