abstract class FeatureRepository {
  Future<void> updateLastSeenTime({required String accountId});

  Future<DateTime?> getLastSeenTime({required String accountId});

  Future<bool> hasSeenWhatsAppGroup({required String accountId});

  Future<void> markWhatsAppGroupAsSeen({required String accountId});
}
