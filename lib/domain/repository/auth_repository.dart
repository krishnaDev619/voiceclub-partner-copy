import 'package:voiceclub_partner/core/resources/data_state.dart';

abstract class AuthRepository {
  Future<DataState<void>> logout();
}
