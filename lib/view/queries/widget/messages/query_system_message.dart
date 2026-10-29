import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class QueryTicketAndStatusMessage extends StatelessWidget {
  final QuerySessionStatus? status;
  final String? ticketId;
  final double? topPadding;

  const QueryTicketAndStatusMessage({
    super.key,
    this.status,
    this.ticketId,
    this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    final hasTicketId = ticketId != null && ticketId!.isNotEmpty;
    const Color ticketColor = Color(0xFF343434);

    return Container(
      margin: EdgeInsets.only(
        bottom: 16.0,
        top: topPadding ?? 16.0,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: status?.secondaryColor,
            borderRadius: BorderRadius.circular(8.0),
            border:
                status != null ? Border.all(color: status!.primaryColor) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasTicketId) ...[
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: const Icon(
                    Icons.info_rounded,
                    color: ticketColor,
                    size: 14.0,
                  ),
                ),
                const SizedBox(width: 8.0),
              ],
              Flexible(
                child:
                    hasTicketId
                        ? Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: LocaleKeys.liveTicket.tr,
                                style: TextStyle(
                                  color: ticketColor,
                                  fontSize: 13.0,
                                ),
                              ),
                              TextSpan(
                                text: '#$ticketId',
                                style: const TextStyle(
                                  color: ticketColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: LocaleKeys.liveCreated.tr,
                                style: TextStyle(
                                  color: ticketColor,
                                  fontSize: 13.0,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        )
                        : Text(
                          status?.toQuerySessionStatusDescription() ?? "",
                          style: TextStyle(
                            color: status?.primaryColor,
                            fontSize: 13.0,
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

class SystemMessage extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? margin;

  const SystemMessage({super.key, required this.message, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: ApplicationColors.white,
            borderRadius: BorderRadius.circular(6.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyles.h3.copyWith(color: Color(0xFF989898)),
          ),
        ),
      ),
    );
  }
}
