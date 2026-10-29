import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/social/get_post_by_id_response.dart';
import 'package:voiceclub_partner/domain/usecases/social/get_post_by_id.dart';

class ViewPostController extends GetxController {
  final String postId;

  ViewPostController({required this.postId});
  final _getPostByIdUsecase = sl<GetPostByIdUsecase>();

  final Rx<DataState<GetPostByIdResponseModel>?> _postState =
      Rx<DataState<GetPostByIdResponseModel>?>(null);
  DataState<GetPostByIdResponseModel>? get postState => _postState.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxString _error = ''.obs;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    fetchPost();
  }

  Future<void> fetchPost() async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final result = await _getPostByIdUsecase(GetPostParams(postId: postId));
      _postState.value = result;

      if (result is DataFailed) {
        _error.value = 'Failed to load post';
      }
    } catch (e) {
      _error.value = 'An unexpected error occurred';
    } finally {
      _isLoading.value = false;
    }
  }
}
