import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

String liveChatTabLabel(ChatTabFilter filter) {
  switch (filter) {
    case ChatTabFilter.ALL:
      return LocaleKeys.demoAll.tr;
    case ChatTabFilter.HIGH_PAY_WITH_COUNT_MULTIPLE:
      return LocaleKeys.demoGoodUser.tr;
    case ChatTabFilter.UNREAD_TO_REPLY:
      return LocaleKeys.demoReply.tr;
  }
}

String liveLogLabel(LogType type) {
  switch (type) {
    case LogType.Missed:
      return LocaleKeys.demoMissed.tr;
    case LogType.Busy:
      return LocaleKeys.demoBusyLog.tr;
    case LogType.Offline:
      return LocaleKeys.demoOffline.tr;
    case LogType.Viewed:
      return LocaleKeys.demoViewed.tr;
  }
}

String liveTransactionLabel(TransactionCategory category) {
  switch (category) {
    case TransactionCategory.ALL:
      return LocaleKeys.demoAll.tr;
    case TransactionCategory.CALL:
      return LocaleKeys.demoCall.tr;
    case TransactionCategory.CHAT:
      return LocaleKeys.demoChat.tr;
    case TransactionCategory.PENALTY:
      return LocaleKeys.demoPenalty.tr;
    case TransactionCategory.REWARD:
      return LocaleKeys.demoReward.tr;
    case TransactionCategory.WITHDRAW:
      return LocaleKeys.demoPayout.tr;
    case TransactionCategory.GIFT:
      return LocaleKeys.demoGift.tr;
    case TransactionCategory.REFUND:
      return LocaleKeys.demoRefunds.tr;
  }
}

String liveMaritalLabel(MaritalStatus status) {
  switch (status) {
    case MaritalStatus.Married:
      return LocaleKeys.demoMarried.tr;
    case MaritalStatus.Unmarried:
      return LocaleKeys.demoUnmarried.tr;
    case MaritalStatus.Divorced:
      return LocaleKeys.demoDivorced.tr;
    case MaritalStatus.Relationship:
      return LocaleKeys.demoInRelationship.tr;
  }
}

String liveProfessionLabel(Profession profession) {
  switch (profession) {
    case Profession.Teacher:
      return LocaleKeys.demoTeacher.tr;
    case Profession.Farmer:
      return LocaleKeys.demoFarmer.tr;
    case Profession.PoliceOfficer:
      return LocaleKeys.demoPoliceOfficer.tr;
    case Profession.Driver:
      return LocaleKeys.demoDriver.tr;
    case Profession.AutoDriver:
      return LocaleKeys.demoAutoDriver.tr;
    case Profession.BusDriver:
      return LocaleKeys.demoBusDriver.tr;
    case Profession.Nurse:
      return LocaleKeys.demoNurse.tr;
    case Profession.Pharmacist:
      return LocaleKeys.demoPharmacist.tr;
    case Profession.GymTrainer:
      return LocaleKeys.demoGymTrainer.tr;
    case Profession.Mechanic:
      return LocaleKeys.demoMechanic.tr;
    case Profession.FactoryWorker:
      return LocaleKeys.demoFactoryWorker.tr;
    case Profession.DeliveryRider:
      return LocaleKeys.demoDeliveryRider.tr;
    case Profession.Barber:
      return LocaleKeys.demoBarber.tr;
    case Profession.SalesEmployee:
      return LocaleKeys.demoSalesEmployee.tr;
    case Profession.ShopManager:
      return LocaleKeys.demoShopManager.tr;
    case Profession.OfficeClerk:
      return LocaleKeys.demoOfficeClerk.tr;
    case Profession.ConstructionWorker:
      return LocaleKeys.demoConstructionWorker.tr;
    case Profession.Tailor:
      return LocaleKeys.demoTailor.tr;
    case Profession.Shopkeeper:
      return LocaleKeys.demoShopkeeper.tr;
    case Profession.SecurityGuard:
      return LocaleKeys.demoSecurityGuard.tr;
    case Profession.Plumber:
      return LocaleKeys.demoPlumber.tr;
    case Profession.RailwayEmployee:
      return LocaleKeys.demoRailwayEmployee.tr;
    case Profession.BusConductor:
      return LocaleKeys.demoBusConductor.tr;
    case Profession.MobileRepairWorker:
      return LocaleKeys.demoMobileRepair.tr;
    case Profession.Carpenter:
      return LocaleKeys.demoCarpenter.tr;
    case Profession.Electrician:
      return LocaleKeys.demoElectrician.tr;
    case Profession.Other:
      return LocaleKeys.demoOther.tr;
  }
}
