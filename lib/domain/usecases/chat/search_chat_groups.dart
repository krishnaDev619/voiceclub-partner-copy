import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/get_chat_groups_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class SearchChatGroupsUsecase
    implements
        UseCase<DataState<GetChatGroupsResponseModel>, SearchChatGroupsParams> {
  final ChatRepository _chatRepository;

  SearchChatGroupsUsecase(this._chatRepository);

  @override
  Future<DataState<GetChatGroupsResponseModel>> call(
    SearchChatGroupsParams params,
  ) {
    return _chatRepository.getChatGroups(
      category: params.category,
      searchQuery: params.searchQuery,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class SearchChatGroupsParams extends Equatable {
  final String category, searchQuery;
  final int page, pageSize;

  const SearchChatGroupsParams({
    required this.category,
    required this.searchQuery,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object> get props => [category, searchQuery, page, pageSize];
}
