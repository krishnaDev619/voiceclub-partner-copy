import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/string_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/utils/blocked_account_id_parser.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart'
    as onboarding_di;
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart'
    as onboarding_analytics;
import 'package:voiceclub_partner/features/onboarding/domain/usecases/auth/register.dart';
import 'package:voiceclub_partner/view/auth/blocked_account_screen.dart';
import 'package:voiceclub_partner/view/auth/otp_screen.dart';
import 'package:voiceclub_partner/view/auth/widgets/cancel_alert.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class IndianPhoneInputFormatter extends TextInputFormatter {
  static final RegExp _validPattern = RegExp(r'^\d{10}$');

  /// Returns a canonical 10-digit Indian mobile number extracted from [raw],
  /// or `null` if [raw] cannot be normalized to a valid number.
  ///
  /// Handles all common formats:
  /// - `9876543210`
  /// - `+919876543210` / `+91 98765 43210` / `+91-98765-43210`
  /// - `91 9876543210`
  /// - `09876543210`
  /// - numbers with parentheses, spaces, hyphens
  static String? normalize(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return null;
    final mobile = digits.substring(digits.length - 10);
    return _validPattern.hasMatch(mobile) ? mobile : null;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Field is being cleared — allow empty value.
    if (digits.isEmpty) return TextEditingValue.empty;

    // Within 10 digits: mid-typing in progress, store the raw digits as-is.
    if (digits.length <= 10) {
      return TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }

    // More than 10 digits: normalize() is the single authority on what to do.
    // It strips the country-code prefix and validates the result.  If it
    // returns a canonical number we accept it; otherwise we reject the change.
    // This is deliberately agnostic about *how* the extra digits arrived
    // (paste, autofill, incremental keyboard suggestion — it doesn't matter).
    final normalized = normalize(newValue.text);
    if (normalized != null) {
      return TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }

    return oldValue;
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneNo = TextEditingController();
  final _registerUsecase = sl<RegisterUsecase>();
  bool filled = false;
  bool agree = true;

  @override
  void initState() {
    sl<AnalyticsService>().trackEvent("loginScreen");
    super.initState();
    phoneNo.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    if (!mounted) return;
    final isValid = IndianPhoneInputFormatter.normalize(phoneNo.text) != null;
    if (filled != isValid) {
      setState(() => filled = isValid);
    }
    if (isValid) {
      // Tell the OS the autofill form is complete so it can store the value.

      TextInput.finishAutofillContext();
      FocusScope.of(context).unfocus();
    }
  }

  void _sendOTP() async {
    if (filled && agree) {
      final phoneNumber = IndianPhoneInputFormatter.normalize(phoneNo.text);
      if (phoneNumber == null) return;

      Get.context?.loaderOverlay.show();
      try {
        sl<AnalyticsService>().trackEvent(
          "loginNumberAdded",
          eventProperties: {
            "phoneNumber": "+91$phoneNumber",
            "loginType": "OTP",
          },
        );
        final gaid =
            await onboarding_di
                .sl<onboarding_analytics.AnalyticsService>()
                .getGAID();
        final response = await _registerUsecase.call(
          RegisterParams(phoneNumber: phoneNumber, gaid: gaid),
        );

        if (response.data != null && response.error == null) {
          Get.to(() => OTPScreen(phoneNo: phoneNumber));
        } else if (response.error?.response?.statusCode == 406) {
          final accountId = BlockedAccountIdParser.fromMessage(
            response.errorMessage,
          );
          if (int.tryParse(accountId ?? "") == null) return;
          Get.to(
            () => BlockedAccountScreen(
              accountId: int.tryParse(accountId ?? '0') ?? 0,
              reason: response.errorMessage,
            ),
          );
        } else {
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Error,
            title: LocaleKeys.somethingWentWrong.tr,
            subtitle: response.errorMessage,
          );
        }
      } catch (e) {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.errorTitle.tr,
          subtitle: e.toString(),
        );
      } finally {
        Get.context?.loaderOverlay.hide();
      }
    }
  }

  @override
  void dispose() {
    phoneNo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          bool? result = await Get.dialog(
            CancelAlertDialog(
              title: "VoiceClub",
              subtitle: LocaleKeys.liveAreYouSureYouWant3.tr,
            ),
          );
          if (result ?? false) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        extendBody: false,
        extendBodyBehindAppBar: false,
        backgroundColor: StringConstants.isDev ? Colors.yellow : Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            reverse: true,
            child: KeyboardVisibilityBuilder(
              builder: (_, visible) {
                return SizedBox(
                  height:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.bottom -
                      MediaQuery.of(context).padding.top -
                      (visible ? MediaQuery.of(context).viewInsets.bottom : 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 48.0),
                        child: SvgPicture.asset(
                          AssetConstants.logoHorizontal,
                          height: 36.0,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Login or Signup",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: FontSize.xL,
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(
                              vertical: 24.0,
                              horizontal: 12.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2.0,
                                color: const Color(0xFFA9A9A9),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text(
                                    '🇮🇳 +91',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: AutofillGroup(
                                    child: TextField(
                                      keyboardType: TextInputType.phone,
                                      autofillHints: const [
                                        AutofillHints.telephoneNumberDevice,
                                      ],
                                      maxLength: 10,
                                      onChanged: (value) {
                                        if (value.length == 10) {
                                          TextInput.finishAutofillContext();
                                          setState(() {
                                            filled = true;
                                            FocusScope.of(context).unfocus();
                                          });
                                        } else {
                                          setState(() {
                                            filled = false;
                                          });
                                        }
                                      },
                                      inputFormatters: [
                                        IndianPhoneInputFormatter(),
                                      ],
                                      controller: phoneNo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),

                                      decoration: InputDecoration(
                                        counterText: "",
                                        contentPadding: EdgeInsets.all(0.0),
                                        hintStyle: TextStyle(
                                          color: Colors.black12,
                                        ),
                                        fillColor: Colors.white,
                                        border: InputBorder.none,
                                        hintText:
                                            LocaleKeys.liveEnterYourNumber.tr,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 24.0,
                                  width: 24.0,
                                  child: Checkbox(
                                    visualDensity: VisualDensity.compact,
                                    value: agree,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          agree = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text:
                                          "By entering your number, you are agreeing to our ",
                                      style: const TextStyle(
                                        color: Color(0xFF727272),
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              LocaleKeys.termsAndConditions.tr,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer:
                                              TapGestureRecognizer()
                                                ..onTap = () {
                                                  launchUrl(
                                                    Uri.parse(
                                                      URLConstants
                                                          .termsAndRefundsUrl,
                                                    ),
                                                  );
                                                },
                                        ),
                                        TextSpan(text: LocaleKeys.liveAnd.tr),
                                        TextSpan(
                                          text: LocaleKeys.privacyPolicy.tr,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer:
                                              TapGestureRecognizer()
                                                ..onTap = () {
                                                  launchUrl(
                                                    Uri.parse(
                                                      URLConstants
                                                          .privacyPolicyUrl,
                                                    ),
                                                  );
                                                },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Opacity(
                        opacity: (filled && agree) ? 1 : 0.6,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CustomButton(
                            onTap: () async {
                              _sendOTP();
                            },
                            text: LocaleKeys.continueLabel.tr,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
