import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/get_chat_groups_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetFilteredChatGroupsUsecase
    implements
        UseCase<
          DataState<GetChatGroupsResponseModel>,
          GetFilteredChatGroupsParams
        > {
  final ChatRepository _chatRepository;

  GetFilteredChatGroupsUsecase(this._chatRepository);

  @override
  Future<DataState<GetChatGroupsResponseModel>> call(
    GetFilteredChatGroupsParams params,
  ) {
    return _chatRepository.getFilteredChatGroups(
      code: params.code,
      page: params.page,
      pageSize: params.pageSize,
      isCount: params.isCount,
    );
  }
}

class GetFilteredChatGroupsParams extends Equatable {
  final String code;
  final int page;
  final int pageSize;
  final bool isCount;

  const GetFilteredChatGroupsParams({
    required this.code,
    required this.page,
    required this.pageSize,
    required this.isCount,
  });

  @override
  List<Object> get props => [code];
}
