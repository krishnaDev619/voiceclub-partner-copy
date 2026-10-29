import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/config/support_question.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/domain/usecases/config/get_support_questions_config.dart';

class SupportScreen extends StatefulWidget {
  final List<SupportQuestionModel> questions;
  const SupportScreen({super.key, required this.questions});

  static Future<void> show() async {
    try {
      Get.context?.loaderOverlay.show();
      final response = await sl<GetSupportQuestionsConfigUsecase>().call(
        NoParams(),
      );
      Logger.logMessage("${response.data}");
      if (response.data != null) {
        final q = response.data?.questions ?? [];
        Get.to(() => SupportScreen(questions: q));
      }
    } catch (_) {
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _queryFocusNode = FocusNode();

  @override
  void dispose() {
    _queryController.dispose();
    _queryFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sl<AnalyticsService>().trackEvent(
      "supportScreen",
      eventProperties: {
        'questions': widget.questions.map((e) => e.toJson()).toList(),
      },
    );
    return Scaffold(
      backgroundColor: ApplicationColors.screenBackground,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              ...widget.questions.map(
                (question) => _buildQuestionTile(question),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTile(SupportQuestionModel question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 16),
          title: Text(
            question.question ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ApplicationColors.black,
            ),
          ),
          onExpansionChanged: (isExpanded) {
            sl<AnalyticsService>().trackEvent(
              "supportInteraction",
              eventProperties: {
                'action':
                    isExpanded ? 'question_expanded' : 'question_collapsed',
                'question': question.question ?? '',
              },
            );
          },
          children: [
            if (question.answer != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  question.answer!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ApplicationColors.textGreyDark,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ApplicationColors.screenBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: ApplicationColors.black,
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        LocaleKeys.liveHelpAndSupport.tr,
        style: const TextStyle(
          color: ApplicationColors.black,
          fontSize: FontSize.xXL,
          fontWeight: Weight.heavy,
        ),
      ),
      centerTitle: true,
    );
  }
}
