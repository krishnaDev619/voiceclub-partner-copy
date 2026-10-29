import 'package:voiceclub_partner/data/data_sources/remote/feature/feature_firebase_service.dart';
import 'package:voiceclub_partner/domain/repository/feature_repository.dart';

class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureFirebaseService _featureFirebaseService;

  FeatureRepositoryImpl(this._featureFirebaseService);

  @override
  Future<DateTime?> getLastSeenTime({required String accountId}) {
    return _featureFirebaseService.getLastSeenTime(accountId: accountId);
  }

  @override
  Future<void> updateLastSeenTime({required String accountId}) {
    return _featureFirebaseService.updateLastSeenTime(accountId: accountId);
  }

  @override
  Future<bool> hasSeenWhatsAppGroup({required String accountId}) {
    return _featureFirebaseService.hasSeenWhatsAppGroup(accountId: accountId);
  }

  @override
  Future<void> markWhatsAppGroupAsSeen({required String accountId}) async {
    return _featureFirebaseService.markWhatsAppGroupAsSeen(
      accountId: accountId,
    );
  }
}
