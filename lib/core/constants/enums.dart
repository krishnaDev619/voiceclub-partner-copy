// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/onboarding/widgets/onbaording_status_chip.dart';
import 'package:voiceclub_partner/view/profile/widgets/status_chip.dart';

part 'enums.g.dart';

@HiveType(typeId: 8)
enum AccountType {
  @HiveField(0)
  DEMAND,
  @HiveField(1)
  SUPPLY,
}

extension AccountTypeToString on AccountType {
  String toAccountTypeString() {
    switch (this) {
      case AccountType.DEMAND:
        return 'DEMAND';
      case AccountType.SUPPLY:
        return 'SUPPLY';
    }
  }
}

extension AccountTypeToRole on String {
  AccountType toAccountType() {
    switch (this) {
      case 'DEMAND':
        return AccountType.DEMAND;
      case 'SUPPLY':
        return AccountType.SUPPLY;
      default:
        return AccountType.DEMAND;
    }
  }
}

enum CategoryOption { GOSSIP, ALL }

@HiveType(typeId: 1)
enum CategoryCode {
  @HiveField(0)
  GOSSIP,
}

extension Option on CategoryCode {
  CategoryOption get categoryOption {
    switch (this) {
      case CategoryCode.GOSSIP:
        return CategoryOption.GOSSIP;
    }
  }
}

extension OptionName on CategoryOption {
  String get categoryName {
    switch (this) {
      case CategoryOption.GOSSIP:
        return 'FriendsClub';
      case CategoryOption.ALL:
        return 'All';
    }
  }
}

extension CategoryIconPath on CategoryCode {
  String get categoryIconPath {
    switch (this) {
      case CategoryCode.GOSSIP:
        return AssetConstants.dailyGossip;
    }
  }
}

extension CategoryBannerPath on CategoryCode {
  String get categoryBannerPath {
    switch (this) {
      case CategoryCode.GOSSIP:
        return AssetConstants.gossipBanner;
    }
  }
}

extension CategoryName on CategoryCode {
  String get categoryName {
    switch (this) {
      case CategoryCode.GOSSIP:
        return 'FriendsClub';
    }
  }
}

extension CamelCaseCategoryName on CategoryCode {
  String get camelCaseCategoryName {
    switch (this) {
      case CategoryCode.GOSSIP:
        return 'fc';
    }
  }
}

extension ScreenName on CategoryCode {
  String get categoryScreenName {
    switch (this) {
      case CategoryCode.GOSSIP:
        return 'fcListingScreen';
    }
  }
}

extension StringToCategoryCode on String {
  CategoryCode toCategoryCode() {
    if (toLowerCase().contains('gossip')) {
      return CategoryCode.GOSSIP;
    } else {
      return CategoryCode.GOSSIP;
    }
  }
}

enum BlockReason { Offensive, Spam, Other }

enum OtherReason { personal, sexual, harassment }

enum Rating { Poor, Bad, Average, Good, Amazing }

extension RatingSvgAssetExtension on Rating {
  String get imageAssetPath {
    switch (this) {
      case Rating.Poor:
        return AssetConstants.poor;
      case Rating.Bad:
        return AssetConstants.bad;
      case Rating.Average:
        return AssetConstants.average;
      case Rating.Good:
        return AssetConstants.good;
      case Rating.Amazing:
        return AssetConstants.amazing;
    }
  }

  Widget get icon {
    final assetPath = imageAssetPath;
    return assetPath.isNotEmpty
        ? Image.asset(assetPath, height: 28.0, width: 28.0)
        : const SizedBox.shrink();
  }

  String get localizedName {
    switch (this) {
      case Rating.Poor:
        return LocaleKeys.liveRatingPoor.tr;
      case Rating.Bad:
        return LocaleKeys.liveRatingBad.tr;
      case Rating.Average:
        return LocaleKeys.liveRatingAverage.tr;
      case Rating.Good:
        return LocaleKeys.liveRatingGood.tr;
      case Rating.Amazing:
        return LocaleKeys.liveRatingAmazing.tr;
    }
  }
}

enum NotificationType { normal, audio }

enum LogType { Missed, Busy, Offline, Viewed }

enum OverviewFilter {
  Today,
  Yesterday,
  ThisWeek,
  LastWeek,
  ThisMonth,
  LastMonth,
  // ThisYear,
  // LastYear,
}

extension OverviewFilterString on OverviewFilter {
  String get stringValue {
    switch (this) {
      case OverviewFilter.Today:
        return 'Today';
      case OverviewFilter.Yesterday:
        return 'Yesterday';
      case OverviewFilter.ThisWeek:
        return 'This Week';
      case OverviewFilter.LastWeek:
        return 'Last Week';
      case OverviewFilter.ThisMonth:
        return 'This Month';
      case OverviewFilter.LastMonth:
        return 'Last Month';
      // case OverviewFilter.ThisYear:
      //   return 'This Year';
      // case OverviewFilter.LastYear:
      //   return 'Last Year';
    }
  }
}

@HiveType(typeId: 2)
enum ChatType {
  @HiveField(0)
  ChatTypeAudio,
  @HiveField(1)
  ChatTypeAudioNotification,
  @HiveField(2)
  ChatTypeNotification,
  @HiveField(3)
  ChatTypeText,
  @HiveField(4)
  ChatTypeGift,
  @HiveField(5)
  ChatTypeStoryReply,
  @HiveField(6)
  ChatTypeImage,
  @HiveField(7)
  ChatTypeVideo,
  @HiveField(8)
  ChatTypeMissedCall,
  @HiveField(9)
  ChatTypeCall,
  @HiveField(10)
  ChatTypeSticker,
  @HiveField(11)
  ChatTypeViewedCall,
  @HiveField(12)
  ChatTypePrivacyPack,
  @HiveField(13)
  ChatTypePostComment,
  @HiveField(14)
  ChatTypeGame,
  @HiveField(15)
  ChatTypeStoryComment,
  @HiveField(16)
  ChatTypeStoryReaction,
}

extension ChatTypeToString on ChatType {
  String toChatTypeString() {
    switch (this) {
      case ChatType.ChatTypeAudio:
        return 'AUDIO';
      case ChatType.ChatTypeAudioNotification:
        return 'AUDIO_NOTIFICATION';
      case ChatType.ChatTypeNotification:
        return 'NOTIFICATION';
      case ChatType.ChatTypeText:
        return 'TEXT';
      case ChatType.ChatTypeGift:
        return 'GIFT';
      case ChatType.ChatTypeStoryReply:
        return 'STORY_REPLY';
      case ChatType.ChatTypeImage:
        return 'IMAGE';
      case ChatType.ChatTypeVideo:
        return 'VIDEO';
      case ChatType.ChatTypeMissedCall:
        return 'MISSED_CALL';
      case ChatType.ChatTypeCall:
        return 'CALL';
      case ChatType.ChatTypeSticker:
        return 'STICKER';
      case ChatType.ChatTypeViewedCall:
        return 'VIEWED_CALL';
      case ChatType.ChatTypePrivacyPack:
        return 'PRIVACY_PACK';
      case ChatType.ChatTypePostComment:
        return 'COMMENT';
      case ChatType.ChatTypeGame:
        return 'GAME';
      case ChatType.ChatTypeStoryComment:
        return 'STORY_COMMENT';
      case ChatType.ChatTypeStoryReaction:
        return 'STORY_REACTION';
    }
  }
}

extension StringToChatType on String {
  ChatType toChatType() {
    switch (this) {
      case 'AUDIO':
        return ChatType.ChatTypeAudio;
      case 'AUDIO_NOTIFICATION':
        return ChatType.ChatTypeAudioNotification;
      case 'NOTIFICATION':
        return ChatType.ChatTypeNotification;
      case 'TEXT':
        return ChatType.ChatTypeText;
      case 'GIFT':
        return ChatType.ChatTypeGift;
      case 'STORY_REPLY':
        return ChatType.ChatTypeStoryReply;
      case 'IMAGE':
        return ChatType.ChatTypeImage;
      case 'VIDEO':
        return ChatType.ChatTypeVideo;
      case 'MISSED_CALL':
        return ChatType.ChatTypeMissedCall;
      case 'CALL':
        return ChatType.ChatTypeCall;
      case 'STICKER':
        return ChatType.ChatTypeSticker;
      case 'VIEWED_CALL':
        return ChatType.ChatTypeViewedCall;
      case 'PRIVACY_PACK':
        return ChatType.ChatTypePrivacyPack;
      case 'COMMENT':
        return ChatType.ChatTypePostComment;
      case 'GAME':
        return ChatType.ChatTypeGame;
      case 'STORY_COMMENT':
        return ChatType.ChatTypeStoryComment;
      case 'STORY_REACTION':
        return ChatType.ChatTypeStoryReaction;
      default:
        return ChatType.ChatTypeText;
    }
  }
}

@HiveType(typeId: 4)
enum ChatTier {
  @HiveField(0)
  PRO,
  @HiveField(1)
  PREMIUM,
}

extension ChatTierToString on ChatTier {
  String toChatTierString() {
    switch (this) {
      case ChatTier.PRO:
        return 'PRO';
      case ChatTier.PREMIUM:
        return 'PREMIUM';
    }
  }
}

extension StringToChatTier on String {
  ChatTier toChatTier() {
    switch (this) {
      case 'PRO':
        return ChatTier.PRO;
      case 'PREMIUM':
        return ChatTier.PREMIUM;
      default:
        return ChatTier.PRO;
    }
  }
}

enum CallState { STARTED, ACCEPTED, ENDED, REJECTED, MISSED }

extension StringToCallState on String {
  CallState toCallState() {
    switch (this) {
      case 'STARTED':
        return CallState.STARTED;
      case 'ACCEPTED':
        return CallState.ACCEPTED;
      case 'ENDED':
        return CallState.ENDED;
      case 'REJECTED':
        return CallState.REJECTED;
      case 'MISSED':
        return CallState.MISSED;
      default:
        return CallState.ENDED;
    }
  }
}

enum RingState { CALLING, RINGING }

extension StringToRingState on String {
  RingState toRingState() {
    switch (this) {
      case 'CALLING':
        return RingState.CALLING;
      case 'RINGING':
        return RingState.RINGING;
      default:
        return RingState.CALLING;
    }
  }
}

enum Language { en, hi }

enum Gender { Male, Female }

enum SupplyTier { Diamond, Gold, Silver }

extension StringToSupplyTier on String {
  SupplyTier toSupplyTier() {
    if (toLowerCase().contains(SupplyTier.Diamond.name.toLowerCase())) {
      return SupplyTier.Diamond;
    } else if (toLowerCase().contains(SupplyTier.Gold.name.toLowerCase())) {
      return SupplyTier.Gold;
    } else if (toLowerCase().contains(SupplyTier.Silver.name.toLowerCase())) {
      return SupplyTier.Silver;
    } else {
      return SupplyTier.Silver;
    }
  }
}

extension SupplyTierAssetExtension on SupplyTier {
  String get imageAssetPath {
    switch (this) {
      case SupplyTier.Diamond:
        return AssetConstants.diamondTier;
      case SupplyTier.Gold:
        return AssetConstants.goldTier;
      case SupplyTier.Silver:
        return AssetConstants.silverTier;
    }
  }
}

enum FreeCallStatus { ACCEPT, REJECT }

extension StringToFreeCallStatus on String {
  FreeCallStatus toFreeCallStatus() {
    if (toLowerCase().contains(FreeCallStatus.REJECT.name.toLowerCase())) {
      return FreeCallStatus.REJECT;
    } else {
      return FreeCallStatus.ACCEPT;
    }
  }
}

enum PaymentGateway { PHONEPE, JUSPAY }

extension StringToPaymentGateway on String {
  PaymentGateway toPaymentGateway() {
    if (toLowerCase().contains(PaymentGateway.JUSPAY.name.toLowerCase())) {
      return PaymentGateway.JUSPAY;
    } else {
      return PaymentGateway.PHONEPE;
    }
  }
}

enum ChatTabFilter { ALL, HIGH_PAY_WITH_COUNT_MULTIPLE, UNREAD_TO_REPLY }

extension ChatTabFilterName on ChatTabFilter {
  String get chatTabFilterName {
    switch (this) {
      case ChatTabFilter.ALL:
        return 'All';
      case ChatTabFilter.HIGH_PAY_WITH_COUNT_MULTIPLE:
        return 'Good User';
      case ChatTabFilter.UNREAD_TO_REPLY:
        return 'Reply';
    }
  }
}

enum ChatSessionStatus { REQUESTED, ONGOING, PAUSED, REJECTED, ENDED }

extension StringToChatSessionStatus on String {
  ChatSessionStatus toChatSessionStatus() {
    switch (this) {
      case 'REQUESTED':
        return ChatSessionStatus.REQUESTED;
      case 'ONGOING':
        return ChatSessionStatus.ONGOING;
      case 'PAUSED':
        return ChatSessionStatus.PAUSED;
      case 'REJECTED':
        return ChatSessionStatus.REJECTED;
      case 'ENDED':
        return ChatSessionStatus.ENDED;
      default:
        return ChatSessionStatus.ENDED;
    }
  }
}

enum TransactionType {
  TopUp,
  Call,
  Gift,
  Withdrawal,
  Referral,
  MissedCall,
  Subscription,
  Reward,
  Chat,
  Penalty,
  Game,
  Refund,
}

extension TransactionTypeExtension on TransactionType {
  String get value {
    switch (this) {
      case TransactionType.TopUp:
        return "TOP_UP";
      case TransactionType.Call:
        return "CALL";
      case TransactionType.Gift:
        return "GIFT";
      case TransactionType.Withdrawal:
        return "WITHDRAW";
      case TransactionType.Referral:
        return "REFERRAL";
      case TransactionType.MissedCall:
        return "MISSED_CALL";
      case TransactionType.Subscription:
        return "SUBSCRIPTION";
      case TransactionType.Reward:
        return "REWARD";
      case TransactionType.Chat:
        return "CHAT";
      case TransactionType.Penalty:
        return "PENALTY";
      case TransactionType.Game:
        return "GAME";
      case TransactionType.Refund:
        return "REFUND";
    }
  }
}

extension StringToTransactionTypeExtension on String {
  TransactionType toTransactionType() {
    switch (this) {
      case "TOP_UP":
        return TransactionType.TopUp;
      case "CALL":
        return TransactionType.Call;
      case "GIFT":
        return TransactionType.Gift;
      case "WITHDRAW":
        return TransactionType.Withdrawal;
      case "REFERRAL":
        return TransactionType.Referral;
      case "MISSED_CALL":
        return TransactionType.MissedCall;
      case "SUBSCRIPTION":
        return TransactionType.Subscription;
      case "REWARD":
        return TransactionType.Reward;
      case "CHAT":
        return TransactionType.Chat;
      case "PENALTY":
        return TransactionType.Penalty;
      case "GAME":
        return TransactionType.Game;
      case "REFUND":
        return TransactionType.Refund;
      default:
        return TransactionType.Call;
    }
  }
}

enum HoldStatus { Hold, Paid, Lapsed }

extension StringToHoldStatusExtension on String {
  HoldStatus toHoldStatus() {
    switch (this) {
      case "HOLD":
        return HoldStatus.Hold;
      case "PAID":
        return HoldStatus.Paid;
      case "LAPSED":
        return HoldStatus.Lapsed;
      default:
        return HoldStatus.Paid;
    }
  }
}

extension HoldStatusExtension on HoldStatus {
  String get value {
    switch (this) {
      case HoldStatus.Hold:
        return "HOLD";
      case HoldStatus.Paid:
        return "PAID";
      case HoldStatus.Lapsed:
        return "LAPSED";
    }
  }

  Color get earningColor {
    switch (this) {
      case HoldStatus.Hold:
        return Colors.amber;
      case HoldStatus.Paid:
        return Colors.green;
      case HoldStatus.Lapsed:
        return Colors.red;
    }
  }

  Color get labelColor {
    switch (this) {
      case HoldStatus.Hold:
        return Colors.amber;
      case HoldStatus.Paid:
        return Colors.black;
      case HoldStatus.Lapsed:
        return Colors.red;
    }
  }
}

enum SwitchType { Call, Chat }

enum DayOfWeek {
  Thursday,
  Friday,
  Saturday,
  Sunday,
  Monday,
  Tuesday,
  Wednesday,
}

extension IntToDayOfWeekExtension on int {
  DayOfWeek toDayOfWeek() {
    try {
      int value = this + 3;
      if (value > 6) {
        return DayOfWeek.values[value - 7];
      } else {
        return DayOfWeek.values[value];
      }
    } catch (_) {
      return DayOfWeek.Thursday;
    }
  }
}

extension DayOfWeekExtensions on DayOfWeek {
  int toWeekday() {
    int value = index - 3;
    if (value > 0) {
      return value;
    } else {
      return index + 4;
    }
  }

  String toStringValue() {
    return toString().split('.').last;
  }

  String get shortName {
    switch (this) {
      case DayOfWeek.Monday:
        return 'Mon';
      case DayOfWeek.Tuesday:
        return 'Tue';
      case DayOfWeek.Wednesday:
        return 'Wed';
      case DayOfWeek.Thursday:
        return 'Thu';
      case DayOfWeek.Friday:
        return 'Fri';
      case DayOfWeek.Saturday:
        return 'Sat';
      case DayOfWeek.Sunday:
        return 'Sun';
    }
  }

  // Generate a sorted list with today's day as the last element
  static List<DayOfWeek> getPreviousWeekSorted() {
    final today = DateTime.now().weekday.toDayOfWeek();
    final days = DayOfWeek.values.toList();

    // Find the index of today's day
    final todayIndex = days.indexOf(today);

    // Split the list into two parts: before and after today's index
    final beforeToday = days.sublist(0, todayIndex);
    final afterToday = days.sublist(todayIndex + 1);

    // Combine the lists with today as the last element
    return [today, ...afterToday, ...beforeToday].reversed.toList();
  }

  DateTime getCorrespondingDate() {
    DateTime today = DateTime.now();
    int todayWeekday = today.weekday;

    int daysDifference = todayWeekday - toWeekday();
    if (daysDifference <= 0) {
      daysDifference +=
          7; // Ensure the date is from the previous week, not including today
    }

    DateTime lastWeekDate = today.subtract(Duration(days: daysDifference));
    return DateTime(lastWeekDate.year, lastWeekDate.month, lastWeekDate.day);
  }
}

extension StringToDayOfWeekExtension on String {
  DayOfWeek toDayOfWeek() {
    return DayOfWeek.values.firstWhereOrNull(
          (e) => e.toString().split('.').last.toLowerCase() == toLowerCase(),
        ) ??
        DayOfWeek.Monday;
  }
}

enum RecordingAudioType { Main, Secondary }

extension RecordingAudioTypeToStringExtension on RecordingAudioType {
  String get type {
    switch (this) {
      case RecordingAudioType.Main:
        return "MAIN";
      case RecordingAudioType.Secondary:
        return "SECONDARY";
    }
  }

  String get title {
    switch (this) {
      case RecordingAudioType.Main:
        return "Profile Intro";
      case RecordingAudioType.Secondary:
        return "Profile Intro";
    }
  }
}

extension StringToRecordingAudioTypeExtension on String {
  RecordingAudioType toRecordingAudioType() {
    switch (toUpperCase()) {
      case 'MAIN':
        return RecordingAudioType.Main;
      case 'SECONDARY':
        return RecordingAudioType.Secondary;
      default:
        return RecordingAudioType.Main;
    }
  }
}

enum RecordingAudioStatus {
  Pending,
  Approved,
  Rejected,
  AiApproved,
  AiRejected,
}

extension GetStatusWidget on RecordingAudioStatus {
  Widget getStatusChip() {
    switch (this) {
      case RecordingAudioStatus.Pending:
        return OnboardingStatusChip(
          status: this,
          color: Colors.amber,
          icon: Icons.timelapse_rounded,
        );
      case RecordingAudioStatus.Approved:
        return OnboardingStatusChip(
          status: this,
          color: Colors.green,
          icon: Icons.check_circle_rounded,
        );
      case RecordingAudioStatus.Rejected:
        return OnboardingStatusChip(
          status: this,
          color: Colors.red,
          icon: Icons.cancel_rounded,
        );
      case RecordingAudioStatus.AiApproved:
        return OnboardingStatusChip(
          status: this,
          color: Colors.green,
          icon: Icons.check_circle_rounded,
        );
      case RecordingAudioStatus.AiRejected:
        return OnboardingStatusChip(
          status: this,
          color: Colors.red,
          icon: Icons.cancel_rounded,
        );
    }
  }

  String toLocalizedStatusLabel() {
    switch (this) {
      case RecordingAudioStatus.Pending:
        return LocaleKeys.audioStatusPending.tr;
      case RecordingAudioStatus.Approved:
        return LocaleKeys.audioStatusApproved.tr;
      case RecordingAudioStatus.Rejected:
        return LocaleKeys.audioStatusRejected.tr;
      case RecordingAudioStatus.AiApproved:
        return LocaleKeys.audioStatusAiApproved.tr;
      case RecordingAudioStatus.AiRejected:
        return LocaleKeys.audioStatusAiRejected.tr;
    }
  }

  Widget getStatusWidget(String? reason) {
    Color bgColor = Colors.red;
    String actionText = "";
    switch (this) {
      case RecordingAudioStatus.Pending:
        bgColor = Colors.amber;
        actionText = LocaleKeys.liveRecordingBeingReviewed.tr;
        break;
      case RecordingAudioStatus.Approved:
        bgColor = Colors.green;
        actionText = LocaleKeys.recordAgain.tr;
        break;
      case RecordingAudioStatus.Rejected:
        bgColor = Colors.red;
        actionText =
            reason?.isNotEmpty == true
                ? LocaleKeys.liveReasonWithValue.trParams({'reason': reason!})
                : LocaleKeys.liveSubmitAnotherRecording.tr;
        break;
      case RecordingAudioStatus.AiApproved:
        bgColor = Colors.green;
        actionText = LocaleKeys.recordAgain.tr;
        break;
      case RecordingAudioStatus.AiRejected:
        bgColor = Colors.red;
        actionText = LocaleKeys.liveSubmitAnotherRecording.tr;
        break;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusChip(
          text: toLocalizedStatusLabel().toUpperCase(),
          bgColor: bgColor,
        ),
        Text(
          actionText,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  ProfileAudioStatus toProfileAudioStatus() {
    switch (this) {
      case RecordingAudioStatus.Pending:
        return ProfileAudioStatus.Pending;
      case RecordingAudioStatus.Approved:
        return ProfileAudioStatus.Approved;
      case RecordingAudioStatus.Rejected:
        return ProfileAudioStatus.Rejected;
      case RecordingAudioStatus.AiApproved:
        return ProfileAudioStatus.Approved;
      case RecordingAudioStatus.AiRejected:
        return ProfileAudioStatus.Rejected;
    }
  }
}

extension StringToRecordingAudioStatusExtension on String {
  RecordingAudioStatus toRecordingAudioStatus() {
    switch (toUpperCase()) {
      case 'PENDING':
        return RecordingAudioStatus.Pending;
      case 'APPROVED':
        return RecordingAudioStatus.Approved;
      case 'REJECTED':
        return RecordingAudioStatus.Rejected;
      case 'AI_APPROVED':
        return RecordingAudioStatus.AiApproved;
      case 'AI_REJECTED':
        return RecordingAudioStatus.AiRejected;
      default:
        return RecordingAudioStatus.Pending;
    }
  }
}

extension RecordingAudioStatusToString on RecordingAudioStatus {
  String get toApiString {
    switch (this) {
      case RecordingAudioStatus.Pending:
        return 'PENDING';
      case RecordingAudioStatus.Approved:
        return 'APPROVED';
      case RecordingAudioStatus.Rejected:
        return 'REJECTED';
      case RecordingAudioStatus.AiApproved:
        return 'AI_APPROVED';
      case RecordingAudioStatus.AiRejected:
        return 'AI_REJECTED';
    }
  }
}

enum EventType { CALL, CHAT }

extension StringToEventType on String {
  EventType? toEventType() {
    switch (toUpperCase()) {
      case 'CALL':
        return EventType.CALL;
      case 'CHAT':
        return EventType.CHAT;
      default:
        return null;
    }
  }
}

extension EventName on EventType {
  String get eventName {
    switch (this) {
      case EventType.CALL:
        return 'callSuccessPartner';
      case EventType.CHAT:
        return 'chatReceivedPartner';
    }
  }
}

enum PerformanceSegment { Current, Last, Previous }

enum PerformanceSegmentNew { Current, Last }

enum PerformanceCriteria { LevelCriteria, CriteriaEarnings }

enum SlotBookingDay { D0, D1, D2, D3 }

extension SlotBookingDayExtensions on SlotBookingDay {
  String get weekdayString {
    final now = DateTime.now();
    final targetDate = now.add(Duration(days: index));
    return DateFormat.EEEE().format(targetDate);
  }

  String get dateString {
    final now = DateTime.now();
    final targetDate = now.add(Duration(days: index));
    return DateFormat('dd MMM').format(targetDate);
  }

  List<SlotBookingDay> get tabs => SlotBookingDay.values.sublist(1);
}

enum DemandUserType { NewUser, OldUser }

extension UserString on DemandUserType {
  String get userString {
    switch (this) {
      case DemandUserType.NewUser:
        return "New User";
      case DemandUserType.OldUser:
        return "Old User";
    }
  }
}

extension DemandUserTypeToString on DemandUserType {
  String get code {
    switch (this) {
      case DemandUserType.NewUser:
        return "NEW";
      case DemandUserType.OldUser:
        return "OLD";
    }
  }
}

enum ConversionStatus { Pending, Completed }

extension ConversionStatusString on ConversionStatus {
  String get status {
    switch (this) {
      case ConversionStatus.Pending:
        return "Non Converted";
      case ConversionStatus.Completed:
        return "Converted";
    }
  }
}

enum DurationEarnings {
  ZeroTo1Min,
  OneTo10Min,
  ElevenTo20Min,
  TwentyOneTo40Min,
  FortyOneTo60Min,
  Above60Min,
}

extension DurationEarningsExtension on DurationEarnings {
  String get duration {
    switch (this) {
      case DurationEarnings.ZeroTo1Min:
        return "0 - 1 min";
      case DurationEarnings.OneTo10Min:
        return "1 - 10 min";
      case DurationEarnings.ElevenTo20Min:
        return "11 - 20 min";
      case DurationEarnings.TwentyOneTo40Min:
        return "21 - 40 min";
      case DurationEarnings.FortyOneTo60Min:
        return "41 - 60 min";
      case DurationEarnings.Above60Min:
        return "Above 60 min";
    }
  }

  int get earningsPercentage {
    switch (this) {
      case DurationEarnings.ZeroTo1Min:
        return 0;
      case DurationEarnings.OneTo10Min:
        return 25;
      case DurationEarnings.ElevenTo20Min:
        return 30;
      case DurationEarnings.TwentyOneTo40Min:
        return 40;
      case DurationEarnings.FortyOneTo60Min:
        return 45;
      case DurationEarnings.Above60Min:
        return 50;
    }
  }
}

extension ObfuscateString on String {
  String get obfuscateString {
    if (length < 8) {
      // If the account number is too short to obfuscate properly, return it as is
      return this;
    }

    // Number of characters to show at the start and end
    int showStart = 4;
    int showEnd = 4;

    // Calculate the number of asterisks to add
    int numAsterisks = length - showStart - showEnd;

    // Create the obfuscated string
    String obfuscated =
        substring(0, showStart) +
        '*' * numAsterisks +
        substring(length - showEnd);

    return obfuscated;
  }
}

enum NewUpdateType { TEXT, IMAGE, VIDEO, AUDIO }

extension ConvertNewUpdateType on String {
  NewUpdateType toNewUpdateType() {
    switch (this) {
      case "TEXT":
        return NewUpdateType.TEXT;
      case "IMAGE":
        return NewUpdateType.IMAGE;
      case "VIDEO":
        return NewUpdateType.VIDEO;
      case "AUDIO":
        return NewUpdateType.AUDIO;
      default:
        return NewUpdateType.TEXT;
    }
  }
}

enum TransactionCategory {
  ALL,
  CALL,
  CHAT,
  PENALTY,
  REWARD,
  WITHDRAW,
  GIFT,
  REFUND,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get displayName {
    switch (this) {
      case TransactionCategory.ALL:
        return "All";
      case TransactionCategory.CALL:
        return "Call";
      case TransactionCategory.CHAT:
        return "Chat";
      case TransactionCategory.PENALTY:
        return "Penalty";
      case TransactionCategory.REWARD:
        return "Reward";
      case TransactionCategory.WITHDRAW:
        return "Payout";
      case TransactionCategory.GIFT:
        return "Gift";
      case TransactionCategory.REFUND:
        return "Refunds";
    }
  }
}

enum MaritalStatus { Married, Unmarried, Divorced, Relationship }

extension ConvertToMaritalStatus on String {
  MaritalStatus toMaritalStatus() {
    switch (this) {
      case "Married":
        return MaritalStatus.Married;
      case "Unmarried":
        return MaritalStatus.Unmarried;
      case "Divorced":
        return MaritalStatus.Divorced;
      case "Relationship":
        return MaritalStatus.Relationship;
      default:
        return MaritalStatus.Unmarried;
    }
  }
}

enum Profession {
  Teacher,
  Farmer,
  PoliceOfficer,
  Driver,
  AutoDriver,
  BusDriver,
  Nurse,
  Pharmacist,
  GymTrainer,
  Mechanic,
  FactoryWorker,
  DeliveryRider,
  Barber,
  SalesEmployee,
  ShopManager,
  OfficeClerk,
  ConstructionWorker,
  Tailor,
  Shopkeeper,
  SecurityGuard,
  Plumber,
  RailwayEmployee,
  BusConductor,
  MobileRepairWorker,
  Carpenter,
  Electrician,
  Other,
}

extension ProfessionExtension on Profession {
  static Profession fromString(String name) {
    switch (name) {
      case 'Teacher':
        return Profession.Teacher;
      case 'Farmer':
        return Profession.Farmer;
      case 'PoliceOfficer':
      case 'Police Officer':
        return Profession.PoliceOfficer;
      case 'Driver':
        return Profession.Driver;
      case 'AutoDriver':
      case 'Auto Driver':
        return Profession.AutoDriver;
      case 'BusDriver':
      case 'Bus Driver':
        return Profession.BusDriver;
      case 'Nurse':
        return Profession.Nurse;
      case 'Pharmacist':
        return Profession.Pharmacist;
      case 'GymTrainer':
      case 'Gym Trainer':
        return Profession.GymTrainer;
      case 'Mechanic':
        return Profession.Mechanic;
      case 'FactoryWorker':
      case 'Factory Worker':
        return Profession.FactoryWorker;
      case 'DeliveryRider':
      case 'Delivery Rider':
        return Profession.DeliveryRider;
      case 'Barber':
        return Profession.Barber;
      case 'SalesEmployee':
      case 'Sales Employee':
        return Profession.SalesEmployee;
      case 'ShopManager':
      case 'Shop Manager':
        return Profession.ShopManager;
      case 'OfficeClerk':
      case 'Office Clerk':
        return Profession.OfficeClerk;
      case 'ConstructionWorker':
      case 'Construction Worker':
        return Profession.ConstructionWorker;
      case 'Tailor':
        return Profession.Tailor;
      case 'Shopkeeper':
        return Profession.Shopkeeper;
      case 'SecurityGuard':
      case 'Security Guard':
        return Profession.SecurityGuard;
      case 'Plumber':
        return Profession.Plumber;
      case 'RailwayEmployee':
      case 'Railway Employee':
        return Profession.RailwayEmployee;
      case 'BusConductor':
      case 'Bus Conductor':
        return Profession.BusConductor;
      case 'MobileRepairWorker':
      case 'Mobile Repair Worker':
        return Profession.MobileRepairWorker;
      case 'Carpenter':
        return Profession.Carpenter;
      case 'Electrician':
        return Profession.Electrician;
      case 'Other':
        return Profession.Other;
      default:
        return Profession.Other;
    }
  }

  String toDisplayName() {
    switch (this) {
      case Profession.PoliceOfficer:
        return 'Police Officer';
      case Profession.AutoDriver:
        return 'Auto Driver';
      case Profession.BusDriver:
        return 'Bus Driver';
      case Profession.GymTrainer:
        return 'Gym Trainer';
      case Profession.FactoryWorker:
        return 'Factory Worker';
      case Profession.DeliveryRider:
        return 'Delivery Rider';
      case Profession.SalesEmployee:
        return 'Sales Employee';
      case Profession.ShopManager:
        return 'Shop Manager';
      case Profession.OfficeClerk:
        return 'Office Clerk';
      case Profession.ConstructionWorker:
        return 'Construction Worker';
      case Profession.SecurityGuard:
        return 'Security Guard';
      case Profession.RailwayEmployee:
        return 'Railway Employee';
      case Profession.BusConductor:
        return 'Bus Conductor';
      case Profession.MobileRepairWorker:
        return 'Mobile Repair Worker';
      default:
        return name.replaceAllMapped(
          RegExp(r'(?<!^)([A-Z])'),
          (Match m) => ' ${m[1]}',
        );
    }
  }
}

enum HungCallType { ONLINE, OFFLINE, BUSY }

extension HungCallTypeString on String {
  HungCallType toHungCallType() {
    switch (toUpperCase()) {
      case 'ONLINE':
        return HungCallType.ONLINE;
      case 'OFFLINE':
        return HungCallType.OFFLINE;
      case 'Busy':
        return HungCallType.BUSY;
      default:
        return HungCallType.ONLINE;
    }
  }
}

enum PartnerCurrentStatus { LIVE, NEW_LIVE, PROBATION, ONBOARDED, FIRED, NULL }

enum IntroAudioCollectionStep { probation, newLive, off }

extension IntroAudioCollectionStepApi on IntroAudioCollectionStep {
  String get apiValue {
    switch (this) {
      case IntroAudioCollectionStep.probation:
        return 'PROBATION';
      case IntroAudioCollectionStep.newLive:
        return 'NEW_LIVE';
      case IntroAudioCollectionStep.off:
        return 'OFF';
    }
  }
}

extension StringToIntroAudioCollectionStep on String? {
  /// Null and unknown values resolve to [IntroAudioCollectionStep.probation].
  IntroAudioCollectionStep toIntroAudioCollectionStep() {
    switch (this?.toUpperCase().trim()) {
      case 'NEW_LIVE':
        return IntroAudioCollectionStep.newLive;
      case 'OFF':
        return IntroAudioCollectionStep.off;
      case 'PROBATION':
      default:
        return IntroAudioCollectionStep.probation;
    }
  }
}

extension StringToPartnerCurrentStatus on String {
  PartnerCurrentStatus toPartnerCurrentStatus() {
    switch (toUpperCase().trim()) {
      case 'LIVE':
        return PartnerCurrentStatus.LIVE;
      case 'NEW_LIVE':
        return PartnerCurrentStatus.NEW_LIVE;
      case 'PROBATION':
        return PartnerCurrentStatus.PROBATION;
      case 'ONBOARDED':
        return PartnerCurrentStatus.ONBOARDED;
      case 'FIRED':
        return PartnerCurrentStatus.FIRED;
      default:
        return PartnerCurrentStatus.NULL;
    }
  }
}

extension PartnerCurrentStatusExtension on PartnerCurrentStatus {
  String toDisplayName() {
    switch (this) {
      case PartnerCurrentStatus.LIVE:
        return "Live";
      case PartnerCurrentStatus.NEW_LIVE:
        return "New Live";
      case PartnerCurrentStatus.PROBATION:
        return "Probation";
      case PartnerCurrentStatus.ONBOARDED:
        return "Onboarded";
      case PartnerCurrentStatus.FIRED:
        return "Fired";
      case PartnerCurrentStatus.NULL:
        return "Null";
    }
  }
}

enum RewardsType { Reward, Penalty, Pending }

enum ProfileAudioStatus { Pending, Rejected, Approved, NotUploaded }

extension GetStatusWidgetProfile on ProfileAudioStatus {
  Widget getStatusChip() {
    switch (this) {
      case ProfileAudioStatus.Pending:
        return OnboardingStatusChip(
          status: toRecordAudioStatus() ?? RecordingAudioStatus.Pending,
          color: Colors.amber,
          icon: Icons.timelapse_rounded,
        );
      case ProfileAudioStatus.Approved:
        return OnboardingStatusChip(
          status: toRecordAudioStatus() ?? RecordingAudioStatus.Pending,
          color: Colors.green,
          icon: Icons.check_circle_rounded,
        );
      case ProfileAudioStatus.Rejected:
        return OnboardingStatusChip(
          status: toRecordAudioStatus() ?? RecordingAudioStatus.Pending,
          color: Colors.red,
          icon: Icons.cancel_rounded,
        );
      case ProfileAudioStatus.NotUploaded:
        return const SizedBox.shrink();
    }
  }

  RecordingAudioStatus? toRecordAudioStatus() {
    switch (this) {
      case ProfileAudioStatus.Pending:
        return RecordingAudioStatus.Pending;
      case ProfileAudioStatus.Approved:
        return RecordingAudioStatus.Approved;
      case ProfileAudioStatus.Rejected:
        return RecordingAudioStatus.Rejected;
      case ProfileAudioStatus.NotUploaded:
        return null;
    }
  }
}

enum ProfileAudioType { Primary, Secondary }

enum SnackBarType { Success, Warning, Error }

enum RewardType { LEADERBOARD, CUTOFF }

extension RewardTypeExtension on String {
  RewardType toRewardType() {
    switch (this) {
      case "CUTOFF":
        return RewardType.CUTOFF;
      case "LEADERBOARD":
        return RewardType.LEADERBOARD;
      default:
        return RewardType.LEADERBOARD;
    }
  }

  Color toColor() {
    final colorValue = int.parse(
      "0xFF"
      "$this",
    );
    final color = Color(colorValue);
    return color;
  }

  DateTime? toDateTime() {
    final date = DateTime.tryParse(this);
    return date;
  }
}

enum SendBroadcastType { SELECTED }

enum BottomBarTabType { HOME, LOGS, CHATS, SOCIAL, LEARNING }

enum QuerySenderType { SUPPPLY, BOT, KAM, SYSTEM }

extension QuerySenderTypeToString on QuerySenderType {
  String querySenderTypeToString() {
    switch (this) {
      case QuerySenderType.SUPPPLY:
        return 'SUPPLY';
      case QuerySenderType.BOT:
        return 'BOT';
      case QuerySenderType.KAM:
        return 'KAM';
      case QuerySenderType.SYSTEM:
        return 'SYSTEM';
    }
  }
}

extension StringToSenderType on String {
  QuerySenderType toSenderType() {
    switch (toUpperCase()) {
      case 'SUPPLY':
        return QuerySenderType.SUPPPLY;
      case 'BOT':
        return QuerySenderType.BOT;
      case 'KAM':
        return QuerySenderType.KAM;
      case 'SYSTEM':
        return QuerySenderType.SYSTEM;
      default:
        return QuerySenderType.BOT;
    }
  }
}

enum QueryMessageType { TEXT, AUDIO, IMAGE, VIDEO }

extension StringToQueryMessageType on String {
  QueryMessageType toQueryMessage() {
    switch (toUpperCase()) {
      case 'TEXT':
        return QueryMessageType.TEXT;
      case 'AUDIO':
        return QueryMessageType.AUDIO;
      case 'IMAGE':
        return QueryMessageType.IMAGE;
      case 'VIDEO':
        return QueryMessageType.VIDEO;
      default:
        return QueryMessageType.TEXT;
    }
  }
}

extension QueryMessageTypeToString on QueryMessageType {
  String toQueryMessageTypeString() {
    switch (this) {
      case QueryMessageType.TEXT:
        return 'TEXT';
      case QueryMessageType.AUDIO:
        return 'AUDIO';
      case QueryMessageType.IMAGE:
        return 'IMAGE';
      case QueryMessageType.VIDEO:
        return 'VIDEO';
    }
  }
}

enum QuerySessionStatus { ONGOING, PENDING, RESOLVED, REJECTED }

extension StringToQuerySessionStatus on String {
  QuerySessionStatus toQuerySessionStatus() {
    switch (toUpperCase()) {
      case 'ONGOING':
        return QuerySessionStatus.ONGOING;
      case 'PENDING':
        return QuerySessionStatus.PENDING;
      case 'RESOLVED':
        return QuerySessionStatus.RESOLVED;
      case 'REJECTED':
        return QuerySessionStatus.REJECTED;
      default:
        return QuerySessionStatus.PENDING;
    }
  }
}

extension QuerySessionStatusName on QuerySessionStatus {
  String toQuerySessionStatusName() {
    switch (this) {
      case QuerySessionStatus.ONGOING:
        return LocaleKeys.liveQueryOngoing.tr;
      case QuerySessionStatus.PENDING:
        return LocaleKeys.liveQueryPending.tr;
      case QuerySessionStatus.RESOLVED:
        return LocaleKeys.liveQueryResolved.tr;
      case QuerySessionStatus.REJECTED:
        return LocaleKeys.liveQueryRejected.tr;
    }
  }
}

extension QuerySessionStatusDescription on QuerySessionStatus {
  String toQuerySessionStatusDescription() {
    switch (this) {
      case QuerySessionStatus.ONGOING:
        return "";
      case QuerySessionStatus.PENDING:
        return LocaleKeys.liveQueryPendingState.tr;
      case QuerySessionStatus.RESOLVED:
        return LocaleKeys.liveQueryWasResolved.tr;
      case QuerySessionStatus.REJECTED:
        return LocaleKeys.liveQueryWasRejected.tr;
    }
  }
}

extension QuerySessionStatusColor on QuerySessionStatus {
  Color get primaryColor {
    switch (this) {
      case QuerySessionStatus.ONGOING:
        return const Color(0xFF979797);
      case QuerySessionStatus.PENDING:
        return const Color(0xFFD3A71D);
      case QuerySessionStatus.RESOLVED:
        return const Color(0xFF4AA611);
      case QuerySessionStatus.REJECTED:
        return Color(0xFFEB4646);
    }
  }

  Color get secondaryColor {
    switch (this) {
      case QuerySessionStatus.ONGOING:
        return const Color(0xFFFFFFFF);
      case QuerySessionStatus.PENDING:
        return const Color(0xFFFFF6DD);
      case QuerySessionStatus.RESOLVED:
        return Color(0xFFF3FFEC);
      case QuerySessionStatus.REJECTED:
        return Color(0xFFFDECEC);
    }
  }
}

enum QueryCategory {
  GENERAL_QUERIES,
  TECH_RELATED_ISSUES,
  FEATURE_SPECIFIC_ISSUES,
  PAYOUT_RELATED_ISSUES,
  MEETING_RELATED_ISSUES,
  PROBATION_JOURNEY,
}

extension StringToQueryCategory on String {
  QueryCategory toQueryCategory() {
    switch (toUpperCase()) {
      case 'GENERAL_QUERIES':
        return QueryCategory.GENERAL_QUERIES;
      case 'TECH_RELATED_ISSUES':
        return QueryCategory.TECH_RELATED_ISSUES;
      case 'FEATURE_SPECIFIC_ISSUES':
        return QueryCategory.FEATURE_SPECIFIC_ISSUES;
      case 'PAYOUT_RELATED_ISSUES':
        return QueryCategory.PAYOUT_RELATED_ISSUES;
      case 'MEETING_RELATED_ISSUES':
        return QueryCategory.MEETING_RELATED_ISSUES;
      case 'PROBATION_JOURNEY':
        return QueryCategory.PROBATION_JOURNEY;
      default:
        return QueryCategory.GENERAL_QUERIES;
    }
  }
}

extension QueryCategoryToString on QueryCategory {
  String toQueryCategoryString() {
    switch (this) {
      case QueryCategory.GENERAL_QUERIES:
        return 'GENERAL_QUERIES';
      case QueryCategory.TECH_RELATED_ISSUES:
        return 'TECH_RELATED_ISSUES';
      case QueryCategory.FEATURE_SPECIFIC_ISSUES:
        return 'FEATURE_SPECIFIC_ISSUES';
      case QueryCategory.PAYOUT_RELATED_ISSUES:
        return 'PAYOUT_RELATED_ISSUES';
      case QueryCategory.MEETING_RELATED_ISSUES:
        return 'MEETING_RELATED_ISSUES';
      case QueryCategory.PROBATION_JOURNEY:
        return 'PROBATION_JOURNEY';
    }
  }
}

// STAGES

enum TutorialStage { S1, S2, S3, S4, S5, S6, S7, DONE }

extension StringToTutorialStage on String {
  TutorialStage toTutorialStage() {
    switch (toUpperCase().trim()) {
      case 'S1':
        return TutorialStage.S1;
      case 'S2':
        return TutorialStage.S2;
      case 'S3':
        return TutorialStage.S3;
      case 'S4':
        return TutorialStage.S4;
      case 'S5':
        return TutorialStage.S5;
      case 'S6':
        return TutorialStage.S6;
      case 'S7':
        return TutorialStage.S7;
      case 'DONE':
        return TutorialStage.DONE;
      default:
        return TutorialStage.S1;
    }
  }
}

extension TutorialStageToString on TutorialStage {
  String toStageString() {
    switch (this) {
      case TutorialStage.S1:
        return 'Stage 1';
      case TutorialStage.S2:
        return 'Stage 2';
      case TutorialStage.S3:
        return 'Stage 3';
      case TutorialStage.S4:
        return 'Stage 4';
      case TutorialStage.S5:
        return 'Stage 5';
      case TutorialStage.S6:
        return 'Stage 6';
      case TutorialStage.S7:
        return 'Stage 7';
      case TutorialStage.DONE:
        return 'Done';
    }
  }
}

extension TutorialStageComparison on TutorialStage {
  /// Compares the current `TutorialStage` with another.
  /// Returns:
  /// - `-1` if this stage is lower than the other stage
  /// - `0` if both stages are equal
  /// - `1` if this stage is higher than the other stage
  int compareTo(TutorialStage other) {
    return index.compareTo(other.index);
  }

  /// Determines if the current stage is less than the other stage.
  bool isLessThan(TutorialStage other) {
    if (this == TutorialStage.DONE || other == TutorialStage.DONE) {
      return false; // DONE is never less than any other stage.
    }
    return index < other.index;
  }

  /// Determines if the current stage is greater than the other stage.
  bool isGreaterThan(TutorialStage other) {
    return index > other.index;
  }

  /// Determines if the current stage is equal to the other stage.
  bool isEqualTo(TutorialStage other) {
    return index == other.index;
  }
}

// Enum for Quiz Type
enum TutorialQuizType { MCQ, DEMO, NONE }

extension QuizTypeExtension on TutorialQuizType {
  static TutorialQuizType fromString(String? type) {
    switch (type?.toUpperCase()) {
      case 'MCQ':
        return TutorialQuizType.MCQ;
      case 'DEMO':
        return TutorialQuizType.DEMO;
      default:
        return TutorialQuizType.NONE;
    }
  }
}

enum TutorialDemoFeature {
  // S1
  ACTIVITY_STATUS,
  CHAT_NEW_USER,
  LOGS_LAST_MONTH,
  LOGS_BUSY,
  TRANSACTIONS_CALL,
  TRANSACTIONS_CALL_DETAILS,
  TRANSACTIONS_PAYOUT,
  NOTIFICATION,
  // S2
  TRANSACTIONS_ONLINE_DURATION_PENALTY,
  TRANSACTIONS_CHAT,
  CHAT_LISTING_REPLY,
  METRICS,
  // S3
  DAILY_REWARD_CRITERIA,
  DAILY_REWARD_REVERSE_CALL,
  TRANSACTIONS_REWARD,
  // S4
  CHAT_BLOCK,
  CHAT_THEME,
  CHAT_UNBLOCK,
  CHAT_NOTIFICATION,
  CHAT_STICKERS,
  // S6
  CHAT_NOTES,
  CHAT_REVERSE_CALL,
  // S7
  BROADCAST_MID_USER,
  // EMPTY
  EMPTY,
}

extension TutorialDemoFeatureExtension on TutorialDemoFeature {
  static TutorialDemoFeature fromString(String? type) {
    switch (type?.toUpperCase().trim()) {
      case 'ACTIVITY_STATUS':
        return TutorialDemoFeature.ACTIVITY_STATUS;
      case 'CHAT_NEW_USER':
        return TutorialDemoFeature.CHAT_NEW_USER;
      case 'LOGS_LAST_MONTH':
        return TutorialDemoFeature.LOGS_LAST_MONTH;
      case 'LOGS_BUSY':
        return TutorialDemoFeature.LOGS_BUSY;
      case 'TRANSACTIONS_CALL':
        return TutorialDemoFeature.TRANSACTIONS_CALL;
      case 'TRANSACTIONS_CALL_DETAILS':
        return TutorialDemoFeature.TRANSACTIONS_CALL_DETAILS;
      case 'TRANSACTIONS_PAYOUT':
        return TutorialDemoFeature.TRANSACTIONS_PAYOUT;
      case 'NOTIFICATION':
        return TutorialDemoFeature.NOTIFICATION;
      case 'TRANSACTIONS_CHAT':
        return TutorialDemoFeature.TRANSACTIONS_CHAT;
      case 'CHAT_LISTING_REPLY':
        return TutorialDemoFeature.CHAT_LISTING_REPLY;
      case 'METRICS':
        return TutorialDemoFeature.METRICS;
      case 'DAILY_REWARD_CRITERIA':
        return TutorialDemoFeature.DAILY_REWARD_CRITERIA;
      case 'DAILY_REWARD_REVERSE_CALL':
        return TutorialDemoFeature.DAILY_REWARD_REVERSE_CALL;
      case 'TRANSACTIONS_REWARD':
        return TutorialDemoFeature.TRANSACTIONS_REWARD;
      case 'TRANSACTIONS_ONLINE_DURATION_PENALTY':
        return TutorialDemoFeature.TRANSACTIONS_ONLINE_DURATION_PENALTY;
      case 'CHAT_BLOCK':
        return TutorialDemoFeature.CHAT_BLOCK;
      case 'CHAT_THEME':
        return TutorialDemoFeature.CHAT_THEME;
      case 'CHAT_UNBLOCK':
        return TutorialDemoFeature.CHAT_UNBLOCK;
      case 'CHAT_NOTIFICATION':
        return TutorialDemoFeature.CHAT_NOTIFICATION;
      case 'CHAT_STICKERS':
        return TutorialDemoFeature.CHAT_STICKERS;
      case 'CHAT_NOTES':
        return TutorialDemoFeature.CHAT_NOTES;
      case 'CHAT_REVERSE_CALL':
        return TutorialDemoFeature.CHAT_REVERSE_CALL;
      case 'BROADCAST_MID_USER':
        return TutorialDemoFeature.BROADCAST_MID_USER;
      default:
        return TutorialDemoFeature.EMPTY;
    }
  }
}

enum PayoutItemType { PENALTY, REWARD }

extension StringToPayoutItemType on String {
  PayoutItemType toPayoutItem() {
    switch (this) {
      case 'REWARD':
        return PayoutItemType.REWARD;
      case 'PENALTY':
        return PayoutItemType.PENALTY;
      default:
        return PayoutItemType.REWARD;
    }
  }
}

enum PayoutItemSign { MINUS, PLUS }

extension StringToPayoutItemSign on String {
  PayoutItemSign toPayoutItemSign() {
    switch (this) {
      case 'MINUS':
        return PayoutItemSign.MINUS;
      case 'PLUS':
        return PayoutItemSign.PLUS;
      default:
        return PayoutItemSign.MINUS;
    }
  }
}

enum AnswerState { Correct, Incorrect }

enum YearlyRewardGift {
  earphones(
    title: "Earphones",
    targetEarnings: 50000,
    imagePath: AssetConstants.earphones,
  ),
  smartWatch(
    title: "Smart Watch",
    targetEarnings: 200000,
    imagePath: AssetConstants.smartwatch,
  ),
  cashBonus5000(
    title: "₹5,000 Cash Bonus",
    targetEarnings: 300000,
    imagePath: AssetConstants.cash1,
  ),
  cashBonus10000(
    title: "₹10,000 Cash Bonus",
    targetEarnings: 500000,
    imagePath: AssetConstants.cash2,
  ),
  cashBonus15000(
    title: "₹15,000 Cash Bonus",
    targetEarnings: 800000,
    imagePath: AssetConstants.cash3,
  ),
  airpods(
    title: "Airpods",
    targetEarnings: 1000000,
    imagePath: AssetConstants.airpods,
  ),
  smartPhone(
    title: "Smart Phone",
    targetEarnings: 1500000,
    imagePath: AssetConstants.phone,
  );

  final String title;
  final int targetEarnings;
  final String imagePath;

  const YearlyRewardGift({
    required this.title,
    required this.targetEarnings,
    required this.imagePath,
  });
}

enum LifetimeRewardGift {
  cashBonus30000(1, '₹30,000 Cash Bonus', 1500000, AssetConstants.amount1),
  gold5Gram(2, '5 Gram Gold', 2500000, AssetConstants.gold1),
  gold10Gram(3, '10 Gram Gold', 3500000, AssetConstants.gold2),
  cashBonus150000(4, '₹1,50,000 Cash Bonus', 5000000, AssetConstants.amount2);

  final int id;
  final String title;
  final int targetEarnings;
  final String imagePath;

  const LifetimeRewardGift(
    this.id,
    this.title,
    this.targetEarnings,
    this.imagePath,
  );
}

enum JoiningBonus {
  secondPayout(2, '10% Bonus', '2nd Payout', AssetConstants.secondPayout),
  thirdPayout(3, '10% Bonus', '3rd Payout', AssetConstants.thirdPayout),
  fourthPayout(4, '10% Bonus', '4th Payout', AssetConstants.fourthPayout),
  certificate(
    5,
    'Unlock Certificate',
    'Professional Listener Certificate',
    AssetConstants.certificate,
  );

  final int payoutNumber;
  final String bonusTitle;
  final String description;
  final String imagePath;

  const JoiningBonus(
    this.payoutNumber,
    this.bonusTitle,
    this.description,
    this.imagePath,
  );

  bool isUnlocked(int currentPayoutCount) {
    return currentPayoutCount >= payoutNumber;
  }

  bool isCurrentTarget(int currentPayoutCount) {
    return currentPayoutCount == payoutNumber - 1;
  }
}

enum MetricsCutoffTag { RED, YELLOW, GREEN }

extension MetricsCutoffTagConversion on String {
  MetricsCutoffTag toMetricsCutoffTag() {
    switch (this) {
      case "RED":
        return MetricsCutoffTag.RED;
      case "YELLOW":
        return MetricsCutoffTag.YELLOW;
      case "GREEN":
        return MetricsCutoffTag.GREEN;
      default:
        return MetricsCutoffTag.RED;
    }
  }
}

extension MetricsCutoff on MetricsCutoffTag {
  Color get getColorFromTag {
    switch (this) {
      case MetricsCutoffTag.RED:
        return const Color(0xFFE46962);
      case MetricsCutoffTag.YELLOW:
        return const Color(0xFFFAB431);
      case MetricsCutoffTag.GREEN:
        return const Color(0xFF188538);
    }
  }
}

extension WorkingHours on DateTime {
  bool get isWorkingHour {
    final now = this;
    final currentDay = now.weekday; // Monday = 1, Sunday = 7

    // Check if it's a weekday (Monday to Friday)
    if (currentDay >= 1 && currentDay <= 5) {
      final currentTime = TimeOfDay.fromDateTime(now);
      const workStartTime = TimeOfDay(hour: 10, minute: 0); // 10:00 AM
      const workEndTime = TimeOfDay(hour: 19, minute: 0); // 7:00 PM

      // Convert to minutes for easier comparison
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final startMinutes = workStartTime.hour * 60 + workStartTime.minute;
      final endMinutes = workEndTime.hour * 60 + workEndTime.minute;

      // Check if current time is between start and end time
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    }

    return false;
  }
}

enum GiftType { CASH, GIFT }

extension StringToGiftType on String {
  GiftType toGiftType() {
    switch (this) {
      case 'CASH':
        return GiftType.CASH;
      case 'GIFT':
        return GiftType.GIFT;
      default:
        return GiftType.CASH;
    }
  }
}

enum GiftClaimStatus { PENDING, APPROVED }

extension StringToGiftClaimStatus on String {
  GiftClaimStatus toGiftClaimStatus() {
    switch (this) {
      case 'PENDING':
        return GiftClaimStatus.PENDING;
      case 'APPROVED':
        return GiftClaimStatus.APPROVED;
      default:
        return GiftClaimStatus.PENDING;
    }
  }
}

/// Enum defining different log severity levels
enum LogSeverity {
  ERROR, // Critical errors that need immediate attention
  WARNING, // Potential issues that should be monitored
  INFO, // Important information about app state/flow
  DEBUG, // Detailed information for debugging
}

enum KYCStatus { needsReview, approved, rejected }

extension ColorToHex on Color {
  String toHex() {
    return '#${(toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

enum PostMediaType { TEXT, IMAGE, AUDIO, VIDEO }

extension StringToPostMediaType on String {
  PostMediaType toPostMediaType() {
    switch (toUpperCase().trim()) {
      case 'TEXT':
        return PostMediaType.TEXT;
      case 'IMAGE':
        return PostMediaType.IMAGE;
      case 'AUDIO':
        return PostMediaType.AUDIO;
      case 'VIDEO':
        return PostMediaType.VIDEO;
      default:
        return PostMediaType.TEXT;
    }
  }
}

enum CommentType { TEXT, AUDIO, STICKER }

extension StringToCommentType on String {
  CommentType toCommentType() {
    switch (toUpperCase().trim()) {
      case 'TEXT':
        return CommentType.TEXT;
      case 'AUDIO':
        return CommentType.AUDIO;
      case 'STICKER':
        return CommentType.STICKER;
      default:
        return CommentType.TEXT;
    }
  }
}

enum ReactionType { LIKE, LOVE, HAHA, HEART, CLAP, CRY }

extension StringToReactionType on String {
  ReactionType toReactionType() {
    switch (toUpperCase().trim()) {
      case 'LIKE':
        return ReactionType.LIKE;
      case 'LOVE':
        return ReactionType.LOVE;
      case 'HAHA':
        return ReactionType.HAHA;
      case 'HEART':
        return ReactionType.HEART;
      case 'CLAP':
        return ReactionType.CLAP;
      case 'CRY':
        return ReactionType.CRY;
      default:
        return ReactionType.LIKE;
    }
  }
}

extension ReactionTypeEmoji on ReactionType {
  String get emoji {
    switch (this) {
      case ReactionType.LIKE:
        return '👍';
      case ReactionType.LOVE:
        return '😍';
      case ReactionType.HAHA:
        return '😂';
      case ReactionType.HEART:
        return '❤️';
      case ReactionType.CLAP:
        return '👏';
      case ReactionType.CRY:
        return '😢';
    }
  }

  String get toApiString {
    return name.capitalizeFirst ?? name;
  }
}

enum PostModerationStatus { PENDING, ACCEPTED, REJECTED }

extension StringToPostModerationStatus on String {
  PostModerationStatus toPostModerationStatus() {
    switch (toUpperCase().trim()) {
      case 'PENDING':
        return PostModerationStatus.PENDING;
      case 'ACCEPTED':
        return PostModerationStatus.ACCEPTED;
      case 'REJECTED':
        return PostModerationStatus.REJECTED;
      default:
        return PostModerationStatus.PENDING;
    }
  }
}

enum IndianState {
  AndhraPradesh,
  ArunachalPradesh,
  Assam,
  Bihar,
  Chhattisgarh,
  Goa,
  Gujarat,
  Haryana,
  HimachalPradesh,
  Jharkhand,
  Karnataka,
  Kerala,
  MadhyaPradesh,
  Maharashtra,
  Manipur,
  Meghalaya,
  Mizoram,
  Nagaland,
  Odisha,
  Punjab,
  Rajasthan,
  Sikkim,
  TamilNadu,
  Telangana,
  Tripura,
  UttarPradesh,
  Uttarakhand,
  WestBengal,
  AndamanAndNicobar,
  Chandigarh,
  DadraAndNagarHaveli,
  DamanAndDiu,
  Delhi,
  Lakshadweep,
  Puducherry,
}

enum OnboardingStep { PROFILE_AUDIO }

enum SurveyType { MCQ, CHECKBOX, SHORT }

extension StringToSurveyType on String {
  SurveyType toSurveyType() {
    switch (trim().toUpperCase()) {
      case 'MCQ':
        return SurveyType.MCQ;
      case 'CHECKBOX':
        return SurveyType.CHECKBOX;
      case 'SHORT':
        return SurveyType.SHORT;
      default:
        return SurveyType.MCQ;
    }
  }
}

enum IntroAudioDecision { APPROVED, REJECTED }

extension StringToIntroAudioDecision on String {
  IntroAudioDecision toIntroAudioDecision() {
    switch (toUpperCase().trim()) {
      case 'APPROVED':
        return IntroAudioDecision.APPROVED;
      case 'REJECTED':
        return IntroAudioDecision.REJECTED;
      default:
        return IntroAudioDecision.APPROVED;
    }
  }
}

enum EditStatus { PENDING, STARTED, SUCCESS, RETRY, FAILURE }

extension StringToEditStatus on String {
  EditStatus toEditStatus() {
    switch (toUpperCase().trim()) {
      case 'PENDING':
        return EditStatus.PENDING;
      case 'STARTED':
        return EditStatus.STARTED;
      case 'SUCCESS':
        return EditStatus.SUCCESS;
      case 'RETRY':
        return EditStatus.RETRY;
      case 'FAILURE':
        return EditStatus.FAILURE;
      default:
        return EditStatus.PENDING;
    }
  }
}

enum StoryType { IMAGE }

extension StringToStoryType on String {
  StoryType toStoryType() {
    switch (toUpperCase().trim()) {
      case 'IMAGE':
        return StoryType.IMAGE;
      default:
        return StoryType.IMAGE;
    }
  }
}

enum KycTransactionType { ESIGN, FULL_KYC }

extension StringToKycTransactionType on String {
  KycTransactionType toKycTransactionType() {
    switch (toUpperCase().trim()) {
      case 'ESIGN':
        return KycTransactionType.ESIGN;
      case 'FULL_KYC':
        return KycTransactionType.FULL_KYC;
      default:
        return KycTransactionType.ESIGN;
    }
  }
}

enum EsignType { VPA, BANK }

extension StringToEsignType on String {
  EsignType toEsignType() {
    switch (toUpperCase().trim()) {
      case 'VPA':
        return EsignType.VPA;
      case 'BANK':
        return EsignType.BANK;
      default:
        return EsignType.VPA;
    }
  }
}

enum FeatureFlag {
  linearonescorevariant,
  gooduserchattab,
  partnerdailychatreceivedcutoffreward,
  separatechatrewardvariants,
  newkycflow,
  stickers,
  sampleaudio,
  surveypartner,
  penaltywithdrawalexperiment,
  xappkey,
}
