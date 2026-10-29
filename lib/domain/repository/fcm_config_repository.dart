import 'package:voiceclub_partner/core/resources/data_state.dart';

abstract class FCMConfigRepository {
  Future<DataState<void>> updateSupplyFCM({
    required String token,
    String? version,
    int? buildNumber,
  });
}
