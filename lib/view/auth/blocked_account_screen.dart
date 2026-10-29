import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/view/queries/no_auth_query_chat_screen.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class BlockedAccountScreen extends StatefulWidget {
  final int accountId;
  final String reason;

  const BlockedAccountScreen({
    super.key,
    required this.accountId,
    required this.reason,
  });

  @override
  State<BlockedAccountScreen> createState() => _BlockedAccountScreenState();
}

class _BlockedAccountScreenState extends State<BlockedAccountScreen> {
  @override
  void initState() {
    super.initState();
    _trackEvent('blockedAccountScreen');
  }

  void _trackEvent(String eventName) {
    sl<AnalyticsService>().trackEvent(
      eventName,
      eventProperties: {'accountId': widget.accountId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _trackEvent('blockedAccountBackButtonClick');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 42, bottom: 26),
                  child: SvgPicture.asset(
                    AssetConstants.logoHorizontal,
                    height: 32,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFECECEC)),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFFFFF0F0),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Account Temporarily Blocked',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF171A23),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.reason,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.45,
                          fontSize: 13,
                          color: Color(0xFF565B68),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, color: Color(0xFFEFEFEF)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 15,
                              color: Color(0xFF7E8492),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Your Account ID - ',
                              style: TextStyle(
                                fontSize: FontSize.M,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text: widget.accountId.toString(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Text(
                                      widget.accountId.toString(),
                                      style: const TextStyle(
                                        fontSize: FontSize.M,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF272B35),
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Icon(
                                      Icons.copy,
                                      size: 15,
                                      color: Colors.grey.shade700,
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
                ),
                Expanded(child: SizedBox()),
                CustomButton(
                  text: LocaleKeys.liveContactSupport.tr,
                  color: const Color(0xFFE46962),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  onTap: () {
                    _trackEvent('blockedAccountContactSupportClick');
                    Get.to(
                      () => NoAuthQueryChatScreen(accountId: widget.accountId),
                    );
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Our support team will assist you within 24 hours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: FontSize.S,
                    color: ApplicationColors.textGreyDark,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
