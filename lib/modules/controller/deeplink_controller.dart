import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/routes.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/deeplink_language.dart';
import 'package:voiceclub_partner/core/services/events_service.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/view/landing/landing_controller.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';

class DeeplinkController extends GetxController {
  DeeplinkController();

  final deeplink = Uri().obs;

  Future<void> updateDeeplink(
    Uri link, {
    String source = 'appLinks',
    bool? isDeferred,
    String? passthrough,
  }) async {
    // Handle link.voiceclub.app deepLinks
    final trackingProperties = <String, dynamic>{
      'deeplink': link.toString(),
      'source': source,
      if (isDeferred != null) 'isDeferred': isDeferred,
      if (passthrough?.isNotEmpty ?? false) 'passthrough': passthrough,
    };
    sl<AnalyticsService>().trackEvent(
      'receivedDeeplink',
      eventProperties: trackingProperties,
    );
    if ("link.voiceclub.app" == link.host) {
      deeplink.value = link;
    } else if ("voiceclub" == link.scheme) {
      deeplink.value = link;
    } else if ("voiceclub.go.link" == link.host) {
      deeplink.value = link;
    } else if ("vcpartner" == link.scheme) {
      deeplink.value = link;
      await EventsService.saveUtmData(link);
    }
    if (deeplink.value == link) {
      sl<AnalyticsService>().trackEvent(
        'acceptedDeeplink',
        eventProperties: trackingProperties,
      );
      await DeeplinkLanguage.capture(
        link,
        source: source,
        isDeferred: isDeferred,
      );
    }
    update();
  }

  void handleDeeplink(bool isInit) async {
    try {
      if (!sl<CallController>().isOnCall) {
        sl<AnalyticsService>().trackEvent(
          'handleDeeplink',
          eventProperties: {'deeplink': deeplink.value.toString()},
        );
        String screenPath = deeplink.value.path;
        final params = deeplink.value.queryParameters;
        bool isOnSameChatAsNotification =
            (screenPath == '/chat' &&
                params.containsKey('groupId') &&
                Get.isRegistered<ChatMessagesController>(
                  tag: params['groupId'],
                ));
        if (!isInit) {
          Get.find<ExploreController>().pauseAllPlayers();
          if (!isOnSameChatAsNotification) {
            Get.until((route) => route.isFirst);
          }
        }
        switch (screenPath) {
          case '/chat':
            if (!isOnSameChatAsNotification) {
              Get.find<LandingController>().changeTab(BottomBarTabType.CHATS);
              if (params.containsKey('accountId')) {
                int accountId = int.tryParse(params['accountId'] ?? '0') ?? 0;
                if (accountId != 0) {
                  if (Get.isRegistered<ChatOverviewController>()) {
                    Get.find<ChatOverviewController>()
                        .navigateToChatScreenUsingAccountId(
                          peerAccountId: accountId,
                          isNew: false,
                          screenName: "Notification",
                        );
                  }
                }
              }
            }
          default:
            if (RouteGenerator.allRoutes.contains(screenPath)) {
              Get.toNamed(
                screenPath,
                arguments: deeplink.value.queryParameters,
              );
            }
        }
      }
    } catch (_) {
    } finally {
      clearDeeplink();
    }
  }

  void clearDeeplink() {
    deeplink.value = Uri();
    update();
  }
}
