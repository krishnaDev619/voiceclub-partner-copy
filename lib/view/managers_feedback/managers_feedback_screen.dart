import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/managers_feedback/manager_feedback_model.dart';
import 'package:voiceclub_partner/modules/controller/managers_feedback_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/managers_feedback/widgets/managers_feedback_card.dart';
import 'package:voiceclub_partner/view/managers_feedback/widgets/no_feedback_widget.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ManagersFeedbackScreen extends StatefulWidget {
  const ManagersFeedbackScreen({super.key});

  @override
  State<ManagersFeedbackScreen> createState() => _ManagersFeedbackScreenState();
}

class _ManagersFeedbackScreenState extends State<ManagersFeedbackScreen> {
  final userController = Get.find<UserController>();
  final managersFeedbackController = Get.find<ManagersFeedbackController>();
  List<ManagerFeedbackModel> managersFeedbackList = [];

  @override
  void initState() {
    super.initState();
    _getManagersFeedback();
    sl<AnalyticsService>().trackEvent("managerFeedbackScreen");
  }

  Future<void> _getManagersFeedback() async {
    await managersFeedbackController.getManagersFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: LocaleKeys.liveManagerSFeedback.tr,
        titleFontSize: FontSize.xL,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          managersFeedbackList =
              managersFeedbackController.managersFeedbackList;

          return managersFeedbackController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () => _getManagersFeedback(),
                    triggerMode: RefreshIndicatorTriggerMode.anywhere,
                    child:
                        managersFeedbackList.isEmpty
                            ? NoFeedbackWidget()
                            : ListView.builder(
                              itemCount: managersFeedbackList.length,
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                left: 16.0,
                                right: 16.0,
                              ),
                              itemBuilder: (context, index) {
                                final managerFeedback =
                                    managersFeedbackList[index];

                                return ManagersFeedbackCard(
                                  managerFeedback: managerFeedback,
                                  onCompletion: () {
                                    managersFeedbackController
                                        .enableIUnderstandButton(
                                          managerFeedback.id ?? 0,
                                        );
                                  },
                                  onIUnderstandClick: () {
                                    managersFeedbackController
                                        .updateManagersFeedbackStatus(
                                          managerFeedback.id ?? 0,
                                        );
                                  },
                                );
                              },
                            ),
                  ),
                ],
              );
        }),
      ),
    );
  }
}
