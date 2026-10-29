import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pinput/pinput.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/session_router.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/auth/register.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/auth/verify_otp.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNo;

  const OTPScreen({super.key, required this.phoneNo});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _verifyOtpUseCase = sl<VerifyOTPUseCase>();
  final _registerUsecase = sl<RegisterUsecase>();
  final TextEditingController smsCode = TextEditingController();
  bool filled = false;

  @override
  void initState() {
    sl<AnalyticsService>().trackEvent("otpScreen");
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _verifyLogin() async {
    if (!filled) return;

    Get.context?.loaderOverlay.show();
    try {
      final phone = widget.phoneNo.replaceAll('-', '');
      final response = await _verifyOtpUseCase.call(
        VerifyOtpParams(phoneNo: phone, otp: smsCode.text),
      );

      if (response.data != null &&
          response.data?.accessToken?.isNotEmpty == true &&
          response.error == null) {
        sl<AnalyticsService>().trackEvent(
          "otpVerified",
          eventProperties: {"loginType": "OTP"},
        );
        await SessionRouter.onOtpVerified(
          phoneNo: phone,
          accessToken: response.data!.accessToken!,
        );
      } else {
        throw Exception(response.errorMessage);
      }
    } catch (e) {
      smsCode.clear();
      Get.context?.loaderOverlay.hide();
      sl<AnalyticsService>().trackEvent(
        "otpFailed",
        eventProperties: {"reason": e.toString(), "type": "OTP"},
      );

      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.liveOtpVerificationFailed.tr,
        subtitle: e.toString(),
      );
    }
  }

  void _resendOTP() async {
    Get.context?.loaderOverlay.show();
    try {
      smsCode.clear();
      sl<AnalyticsService>().trackEvent(
        "resentOTP",
        eventProperties: {"phoneNumber": "+91${widget.phoneNo}"},
      );
      final response = await _registerUsecase.call(
        RegisterParams(phoneNumber: widget.phoneNo.replaceAll('-', '')),
      );

      if (response.data != null && response.error == null) {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Success,
          title: LocaleKeys.liveSent.tr,
          subtitle: LocaleKeys.liveResentOtp.trParams({
            'phone': widget.phoneNo,
          }),
        );
      } else {
        throw Exception(response.errorMessage);
      }
    } catch (e) {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.errorTitle.tr,
        subtitle: LocaleKeys.liveSomethingWentWrongPleaseTry2.tr,
      );
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  @override
  void dispose() {
    smsCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 2)),
      ),
    );

    var submittedPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Get.theme.primaryColor, width: 2),
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewInsets.bottom,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 42.0, bottom: 42.0),
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 16.0, top: 2.0),
                          child: Icon(Icons.arrow_back_ios, size: 20.0),
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "OTP Verification",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.xXXL,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      text: LocaleKeys.verificationCodeSent.tr,
                      children: [
                        TextSpan(
                          text: "+91 ${widget.phoneNo}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: Pinput(
                      length: 6,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Get.theme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      cursor: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: VerticalDivider(
                          thickness: 2,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                      submittedPinTheme: submittedPinTheme,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: smsCode,
                      onChanged: (value) {
                        if (value.length == 6) {
                          setState(() {
                            filled = true;
                          });
                          sl<AnalyticsService>().trackEvent("otpAdded");
                          _verifyLogin();
                        } else {
                          setState(() {
                            filled = false;
                          });
                        }
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(LocaleKeys.liveDidnTReceiveOtp.tr),
                            GestureDetector(
                              onTap: () async {
                                _resendOTP();
                              },
                              child: Text(
                                "\nResend",
                                style: TextStyle(
                                  color: Get.theme.primaryColor,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(LocaleKeys.or.tr),
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Text(
                            'Change Number',
                            style: TextStyle(
                              color: Get.theme.primaryColor,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Opacity(
                opacity: filled ? 1 : 0.6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomButton(
                    onTap: () async {
                      _verifyLogin();
                    },
                    text: LocaleKeys.liveGetStarted.tr,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
