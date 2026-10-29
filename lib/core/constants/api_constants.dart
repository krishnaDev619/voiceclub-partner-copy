import 'package:voiceclub_partner/core/constants/string_constants.dart';

class APIConstants {
  // ==========================================
  // Base URL
  // ==========================================
  static String get baseProdURL => StringConstants.baseProdURL;

  static const String generateProfileImageBaseURL =
      "https://zw4cfsooxi74lnc4vxzrmll7km0awuif.lambda-url.ap-south-1.on.aws";

  // auth
  static const String logoutRoute = "/secure/logout";

  // config
  static const String getAppConfigStatusRoute =
      "/un/secure/config/supply/status";
  static const String getCategoryFilterOptionsRoute =
      "/un/secure/config/filter/{category}";
  static const String updateFCMRoute = "/girl/secure/config";
  static const String getLanguagesRoute = "/un/secure/config/languages";
  static const String getUiLanguagesRoute = "/un/secure/localization/languages";
  static const String getSupportQuestionsConfigRoute =
      "/girl/secure/config/support";
  static const String getIntroAudioSettingsRoute =
      "/supply/config/intro-audio/settings";

  // calls
  static const String getCurrentCallRoute =
      "/secure/v2/current/calls/{channelId}";
  static const String placeCallRoute = "/secure/v2/logs/demand/add";
  static const String endCallRoute = "/secure/v2/current/call/end";
  static const String acceptCallRoute =
      "/girl/secure/v2/current/call/accept/{channelId}";
  static const String endCallSupplyRoute = "/secure/v2/current/call/end";
  static const String setRingSupplyRoute =
      "/girl/secure/v2/current/call/ring/{channelId}";
  static const String pingCallRoute = "/call/v2/current/call/ping/{channelId}";
  static const String getCallDetailsRoute = "/call/details/{channelId}";
  static const String getReverseCallingStatsRoute =
      "/secure/call/reverse/stats/{accountId}";
  static const String getHungCallRoute = "/call/hung";
  static const String endHungCallRoute = "/call/hung/end/{channelId}";

  // call logs
  static const String fetchCallLogsForPairRoute = "/secure/logs/pair/{userId}";
  static const String fetchLogRecordingUrlRoute =
      "/secure/logs/recording/{filename}";

  // blocking
  static const String blockUserRoute = "/block";
  static const String getBlockedUsersRoute = "/block/all";
  static const String reportUserRoute = "/report";

  // rating
  static const String addRatingRoute = "/rating";
  static const String getAllRatingsRoute = "/rating/all";

  // chat
  static const String getChatGroupsRoute = "/chat/groups/{category}";
  static const String sendChatMessageRoute = "/chat";
  static const String uploadChatAttachmentRoute =
      "/file/chat/upload/{extension}";
  static const String getChatAttachmentUrlRoute = "/file/chat/url";
  static const String fetchChatFeaturesUnlockCriteriaRoute = "/chat/features";
  static const String fetchUnseenCountRoute = "/chat/unseen/count";
  static const String getChatGroupByAccountIdRoute =
      "/chat/group/account/{accountId}";
  static const String sendBroadcastMessageRoute = "/chat/broadcast";
  static const String getSupplyChatFilterOptionsRoute =
      "/supply/chat/filter/options/{category}";
  static const String getFilteredChatGroupsRoute = "/chat/groups/filter";
  static const String sendAudioGreetingRoute = "/chat/audio/greet";
  static const String getChatGroupByIdRoute = "/chat/group/{groupId}";
  static const String getPendingAudiosRoute = "/chat/pending/audio";
  static const String updateCustomNameRoute = "/chat/custom_name";
  static const String getActiveUsersRoute = "/chat/users/active";
  static const String getCallRecordingRoute = "/call/recording/{callId}";
  static const String addChatNoteRoute = "/chat/note/add/{accountId}";
  static const String getChatNoteRoute = "/chat/note/get/{accountId}";

  // wallet
  static const String fetchSupplyTransactionsRoute =
      "/girl/secure/wallet/{category}";
  static const String getWalletDetailsRoute = "/girl/secure/wallet/detail";
  static const String getOverviewRoute =
      "/girl/secure/wallet/overview/{period}";
  static const String getTransactionDetailsRoute = "/wallet/transaction/{id}";
  static const String getPayoutBreakdownRoute =
      "/wallet/transaction/{id}/breakdown";
  static const String getMilestoneEarningsRoute = "/wallet/earning_milestone";
  static const String getCoinBalanceRoute = "/girl/secure/coins/wallet/detail";
  static const String getCoinTransactionsRoute =
      "/girl/secure/coins/transactions";
  static const String getPayoutCountRoute = "/wallet/payout_count";
  static const String getRecentPayoutRoute =
      "/wallet/transaction/recent/payout";
  static const String withdrawPayoutRoute = "/wallet/payout";

  // account
  static const String getSupplyProfileRoute = "/girl/secure/profile";
  static const String updateStatusRoute = "/girl/secure/profile/status";
  static const String updateRecordingRoute =
      "/girl/secure/profile/recording/update";
  static const String getAccountPreferenceRoute =
      "/girl/secure/profile/preference";
  static const String updateAccountPreferenceRoute =
      "/girl/secure/profile/preference";
  static const String getCurrentOnlineDurationRoute =
      "/girl/secure/profile/online_duration";
  static const String getAudioStatusRoute =
      "/girl/secure/profile/recording/status";
  static const String getCriteriaUserRoute =
      "/supply/profile/performance/{cutoffFlag}";
  static const String updateLanguageRoute =
      "/girl/secure/profile/language/update";
  static const String updateNotificationPreferenceRoute =
      "/supply/profile/notification/{preference}";
  static const String updateKYCRoute = "/supply/profile/kyc";
  static const String getKYCRoute = "/supply/profile/kyc";
  static const String updateLocationRoute = "/supply/profile/location";
  static const String getReverseCallsRoute = "/supply/profile/reverse_call";
  static const String updateOnboardingStageRoute =
      "/supply/profile/stage/probation/update";
  static const String markOnboardingStageCourseCompletedRoute =
      "/supply/profile/course/completed";

  static const String updateSupplyProfileRoute = "/supply/profile";
  static const String getOnboardingSelfieRoute = "/onboarding/profile/image";
  static const String getMeetingScheduleRoute = "/supply/meeting/schedule/list";
  static const String markOnboardingCompletedRoute =
      "/supply/profile/onboarding/complete";
  static const String getRewardsStatsRoute =
      "/girl/secure/profile/reward/stats/v2";
  static const String updateESignRoute = "/onboarding/profile/esign";
  static const String onboardingDetailsRoute = "/onboarding/details";

  // notifications
  static const String addNotificationRoute = "/girl/secure/notify";
  static const String testNotificationRoute = "/girl/secure/profile/fcm/test";

  // files
  static const String uploadFileRoute = "/girl/secure/file/upload";
  static const String getSignedFileUrlRoute = "/file/{fileName}";

  // stories
  static const String uploadStoryAudioFileRoute = "/file/story/upload";
  static const String uploadOtherFileTypesRoute =
      "/file/story/upload/{extension}";
  static const String uploadStoryRoute = "/story/upload";
  static const String getMyStoryRoute = "/story/get";
  static const String deleteStoryRoute = "/story/{storyId}";

  // tier
  static const String getWeeklyOnlineDurationRoute =
      "/account/weekly/online_duration";

  // logs
  static const String getLogsGroupedRoute =
      "/girl/secure/logs/grouped/{type}/{period}";

  // Events
  static const String getPendingEventsListRoute = "/event/pending";
  static const String getEventDataRoute = "/event/data";
  static const String markEventRoute = "/event/mark/{id}";

  // Gifts
  static const String canReceiveGiftsRoute = "/gift/is_enabled";
  static const String getGiftsRoute = "/reward/gifts";
  static const String claimGiftRoute = "/reward/gift/claim";

  // Hyperverge
  static const String getKYCOutputRoute = "/onboarding/hyper_verge/output";
  static const String getKycTransactionIdRoute = "/onboarding/kyc/transaction";
  static const String markKYCFailedRoute =
      "/onboarding/profile/kyc/failed/{transaction_id}";

  // KYC File
  static const String uploadKycFileRoute =
      "/onboarding/partner/upload/{extension}";
  static const String getKycFileUrlRoute =
      "/onboarding/partner/file/{filename}";

  // Probation
  static const String markProbationCourseCompletedRoute =
      "/supply/probation/tutorial";
  static const String getProbationDetailsRoute = "/supply/probation/details";
  static const String getMetricsScoreRoute = "/supply/profile/scores";

  // Multi Rewards
  static const String activeRewardsRoute = "/reward";
  static const String rewardsLeaderboardRoute =
      "/reward/{rewardId}/leaderboard";
  static const String rewardsCutoffRoute = "/reward/{rewardId}/cutoff";
  static const String rewardsConfigRoute = "/un/secure/config/rewards";

  // Query
  static const String startQueryBotSessionRoute = "/help/sessions/start";
  static const String sendQueryBotMessageRoute = "/help/message";
  static const String endQueryBotSessionRoute = "/help/sessions/end";
  static const String listQuerySessionsRoute = "/help/sessions";
  static const String getQuerySessionRoute = "/help/sessions/{id}";
  static const String getUnseenKamQueryChatMessageCountRoute =
      "/help/sessions/message-count";
  static const String getDailyQueryRaisedCountRoute = "/help/sessions/quota";

  //No Auth Query
  static const String startNoAuthQueryBotSessionRoute =
      "/help/no-auth/sessions/start";
  static const String sendNoAuthQueryBotMessageRoute = "/help/no-auth/message";
  static const String endNoAuthQueryBotSessionRoute =
      "/help/no-auth/sessions/end";

  // Agreement
  static const String updateSignDocumentRoute = "/onboarding/sign_document";
  static const String updateAiCallCountRoute = "/help/update/ai-call/records";

  // social
  static const String createPostRoute = "/asgard/log/post/create";
  static const String getPostByIdRoute = "/asgard/log/post/{postId}";
  static const String listPostsRoute = "/asgard/log/posts";
  static const String listMyPostsRoute = "/asgard/log/posts/myposts";
  static const String listMyUserPostsRoute = "/asgard/log/my_demand/posts";
  static const String createCommentRoute = "/asgard/log/post/comment/create";
  static const String listCommentsRoute = "/asgard/log/post/comments/{postId}";
  static const String createReplyRoute = "/asgard/log/post/reply/create";
  static const String listRepliesRoute =
      "/asgard/log/post/replies/{postId}/{commentId}";
  static const String likePostRoute = "/asgard/log/posts/{postId}/like";
  static const String unlikePostRoute = "/asgard/log/posts/{postId}/like";
  static const String reactPostRoute =
      "/asgard/log/posts/{postId}/react/{reactionType}";
  static const String unReactPostRoute = "/asgard/log/posts/{postId}/react";
  static const String likeCommentRoute =
      "/asgard/log/posts/{postId}/comments/{commentId}/like";
  static const String unlikeCommentRoute =
      "/asgard/log/posts/{postId}/comments/{commentId}/like";
  static const String likeReplyRoute =
      "/asgard/log/posts/{postId}/comments/{commentId}/replies/{replyId}/like";
  static const String unlikeReplyRoute =
      "/asgard/log/posts/{postId}/comments/{commentId}/replies/{replyId}/like";
  static const String getPostReactionsRoute =
      "/asgard/log/posts/{postId}/reactions";
  static const String getPendingPostStatusRoute =
      "/asgard/log/pending/post/{postId}";
  static const String deleteCommentRoute =
      "/asgard/log/post/comment/{postId}/{commentId}";
  static const String getAllReactionsRoute =
      "/asgard/log/posts/reactions/{postId}";

  // unsplash
  static const String unsplashSearchPhotosRoute =
      '/proxy/unsplash/search/photos';

  // Krutrim Maps
  static const String krutrimMapsReverseGeocodingRoute =
      "/proxy/krutrim-maps/reverse-geocode";

  // OpenAI API
  static const String analyzeAudioRoute = '/proxy/openai/analyze-audio';

  // CleanVoice API
  static const String cleanVoiceUploadRoute = "/proxy/cleanvoice/upload";
  static const String cleanVoiceEditsRoute = "/proxy/cleanvoice/edits";
  static const String cleanVoiceEditsByIdRoute = "/proxy/cleanvoice/edits/{id}";

  // Spotlight
  static const String getAvailableSpotlightSlotsRoute =
      "/asgard/log/spotlight/available";
  static const String bookSlotRoute = "/asgard/log/spotlight/book";
  static const String createStoryRoute = "/asgard/log/stories/create";
  static const String getActiveStoriesRoute = "/asgard/log/stories";
  static const String markStoryAsSeenRoute = "/asgard/log/stories/seen";
  static const String createStoryCommentRoute =
      "/asgard/log/stories/{storyId}/comments";
  static const String addStoryReactionRoute =
      "/asgard/log/stories/{storyId}/react";
  static const String getStoryCommentsRoute =
      "/asgard/log/stories/{storyId}/comments";
  static const String getStoryReactionsRoute =
      "/asgard/log/stories/{storyId}/reactions";
  static const String getStoryViewsRoute =
      "/asgard/log/stories/{storyId}/seen/users";
  static const String getStoryByIdRoute = "/asgard/log/stories/{storyId}";

  // Managers Feedback
  static const String getManagersFeedbackRoute = "/supply/feedbacks";
  static const String updateManagersFeedbackStatusRoute =
      "/supply/feedback/{id}";
}
