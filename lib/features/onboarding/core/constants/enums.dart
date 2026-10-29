// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

enum UserType { PartnerOnboarding }

enum FaceVerificationState { Incomplete, Rejected, Accepted }

enum EarningPotential { Six, Eight, Ten }

enum Language {
  Hindi,
  Bengali,
  Tamil,
  Odia,
  Marathi,
  Bhojpuri,
  Telugu,
  Punjabi,
  Urdu,
  Kannada,
  Malayalam,
  Gujarati,
}

extension LanguageToString on String {
  Language toLanguage() {
    final lang = Language.values.firstWhereOrNull(
      (language) => language.name.toLowerCase() == toLowerCase(),
    );
    return lang ?? Language.Hindi;
  }
}

extension EarningPotentialString on EarningPotential {
  int getEarningHoursInDigit() {
    switch (this) {
      case EarningPotential.Six:
        return 6;
      case EarningPotential.Eight:
        return 8;
      case EarningPotential.Ten:
        return 10;
    }
  }
}

enum MaritalStatus { Married, Unmarried, Divorced }

extension MaritalStatusString on MaritalStatus {
  String get getMaritalStatusString {
    switch (this) {
      case MaritalStatus.Married:
        return LocaleKeys.married.tr;
      case MaritalStatus.Unmarried:
        return LocaleKeys.unmarried.tr;
      case MaritalStatus.Divorced:
        return LocaleKeys.divorced.tr;
    }
  }
}

enum Education { tenthPass, twelfthPass, Bachelor, Master }

enum Religion { Hindu, Muslim, Christian, Others }

extension EducationString on Education {
  String get getEducationString {
    switch (this) {
      case Education.tenthPass:
        return "10th ${LocaleKeys.pass.tr}";
      case Education.twelfthPass:
        return "12th ${LocaleKeys.pass.tr}";
      case Education.Bachelor:
        return LocaleKeys.bachelor.tr;
      case Education.Master:
        return LocaleKeys.master.tr;
    }
  }
}

enum ProfileStatus { PENDING, M2, RNR2, REJECTED, APPROVED, ACCOUNT_ONBOARDED }

extension ProfileStatusString on ProfileStatus {
  String get profileStatusToString {
    switch (this) {
      case ProfileStatus.PENDING:
        return "PENDING";
      case ProfileStatus.M2:
        return "M2";
      case ProfileStatus.RNR2:
        return "RNR2";
      case ProfileStatus.REJECTED:
        return "REJECTED";
      case ProfileStatus.APPROVED:
        return "APPROVED";
      case ProfileStatus.ACCOUNT_ONBOARDED:
        return "ACCOUNT_ONBOARDED";
    }
  }
}

extension ProfileStatusToEnum on String {
  ProfileStatus profileStatusToEnum() {
    switch (this) {
      case "PENDING":
        return ProfileStatus.PENDING;
      case "M2":
        return ProfileStatus.M2;
      case "RNR2":
        return ProfileStatus.RNR2;
      case "REJECTED":
        return ProfileStatus.REJECTED;
      case "APPROVED":
        return ProfileStatus.APPROVED;
      case "ACCOUNT_ONBOARDED":
        return ProfileStatus.ACCOUNT_ONBOARDED;
      default:
        return ProfileStatus.PENDING;
    }
  }
}

enum AppLanguage { Hindi, Tamil, Telugu }

extension AppLanguageTranslation on String {
  AppLanguage localeToAppLanguage() {
    switch (this) {
      case 'en_US':
        return AppLanguage.Hindi;
      case 'ta_IN':
        return AppLanguage.Tamil;
      case 'te':
        return AppLanguage.Telugu;
      default:
        return AppLanguage.Hindi;
    }
  }

  AppLanguage toAppLanguage() {
    switch (this) {
      case 'Hindi':
        return AppLanguage.Hindi;
      case 'Tamil':
        return AppLanguage.Tamil;
      case 'Telugu':
        return AppLanguage.Telugu;
      default:
        return AppLanguage.Hindi;
    }
  }
}

extension AppLanguageToString on AppLanguage {
  String get languageString {
    switch (this) {
      case AppLanguage.Hindi:
        return "हिन्दी";
      case AppLanguage.Tamil:
        return "தமிழ்";
      case AppLanguage.Telugu:
        return "తెలుగు";
    }
  }

  String get languageLogo {
    switch (this) {
      case AppLanguage.Hindi:
        return AssetConstants.hinLanguage;
      case AppLanguage.Tamil:
        return AssetConstants.taLanguage;
      case AppLanguage.Telugu:
        return AssetConstants.teLanguage;
    }
  }
}

enum YesNoAnswer { Yes, No }

extension YesNoAnswerBool on YesNoAnswer {
  bool toBool() {
    switch (this) {
      case YesNoAnswer.Yes:
        return true;
      case YesNoAnswer.No:
        return false;
    }
  }
}

enum OnboardingStep {
  Pending,
  // FaceVerification,
  // AgeGroupQuestion,
  NameQuestion,
  ChooseLanguageQuestion,
  MaritalStatusQuestion,
  EducationQuestion,
  ReligionQuestion,
  // AccountVerificationQuestion,
  // AudioVerification,
}

enum FeatureFlag { idto }
