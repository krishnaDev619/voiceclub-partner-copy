import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

String homeOverviewLabel(OverviewFilter filter) {
  switch (filter) {
    case OverviewFilter.Today:
      return LocaleKeys.homeToday.tr;
    case OverviewFilter.Yesterday:
      return LocaleKeys.homeYesterday.tr;
    case OverviewFilter.ThisWeek:
      return LocaleKeys.homeThisWeek.tr;
    case OverviewFilter.LastWeek:
      return LocaleKeys.homeLastWeek.tr;
    case OverviewFilter.ThisMonth:
      return LocaleKeys.homeThisMonth.tr;
    case OverviewFilter.LastMonth:
      return LocaleKeys.homeLastMonth.tr;
  }
}

String homePartnerStatusLabel(PartnerCurrentStatus status) {
  switch (status) {
    case PartnerCurrentStatus.LIVE:
      return LocaleKeys.homeStatusLive.tr;
    case PartnerCurrentStatus.NEW_LIVE:
      return LocaleKeys.homeStatusNewLive.tr;
    case PartnerCurrentStatus.PROBATION:
      return LocaleKeys.homeStatusProbation.tr;
    case PartnerCurrentStatus.ONBOARDED:
      return LocaleKeys.homeStatusOnboarded.tr;
    case PartnerCurrentStatus.FIRED:
      return LocaleKeys.homeStatusFired.tr;
    case PartnerCurrentStatus.NULL:
      return LocaleKeys.homeStatusNull.tr;
  }
}
