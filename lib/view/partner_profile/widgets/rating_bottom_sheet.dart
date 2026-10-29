import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/rating_service.dart';
import 'package:voiceclub_partner/domain/usecases/rating/add_rating.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class RatingBottomSheet extends StatefulWidget {
  const RatingBottomSheet({
    super.key,
    required this.name,
    required this.avatar,
    required this.callDuration,
    required this.accountId,
    required this.category,
  });

  final String name, avatar, callDuration, category;
  final int accountId;

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  Rating? selectedRating;

  @override
  void initState() {
    super.initState();
  }

  void changeSelectedRating(Rating newSelection) {
    setState(() {
      selectedRating = newSelection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: false,
        child: SizedBox(
          height: 350.0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Stack(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -130),
                          child: Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Get.theme.primaryColor,
                                  backgroundImage: FastCachedImageProvider(
                                    widget.avatar,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 42.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                  horizontal: 6.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${LocaleKeys.liveCallDuration.tr}: ',
                                      style: const TextStyle(fontSize: 12.0),
                                    ),
                                    Text(
                                      widget.callDuration,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Text(
                                  LocaleKeys.liveRateYourExperience.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  for (final rating in Rating.values)
                                    Expanded(
                                      child: RatingOptionButton(
                                        rating: rating,
                                        selected: rating == selectedRating,
                                        callback: changeSelectedRating,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ), // Show check icon
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                GestureDetector(
                  onTap: () async {
                    if (selectedRating != null) {
                      int rating = selectedRating!.index + 1;
                      final addRatingUseCase = sl<AddRatingUsecase>();
                      await addRatingUseCase.call(
                        Params(accountId: widget.accountId, rating: rating),
                      );

                      RatingService.addRatedAccountId(widget.accountId);

                      sl<AnalyticsService>().trackEvent(
                        'rateDemand',
                        eventProperties: {
                          'demandName': widget.name,
                          'demandAccountId': widget.accountId,
                          'rating': rating,
                          'categoryName': widget.category,
                        },
                      );

                      Get.back();
                      AlertService.showSnackBar(
                        snackBarType: SnackBarType.Success,
                        title: LocaleKeys.liveSuccess.tr,
                        subtitle: LocaleKeys.liveThankYouRating.trParams({
                          'name': widget.name,
                        }),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color:
                          selectedRating != null
                              ? Get.theme.primaryColor
                              : ApplicationColors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            LocaleKeys.liveSubmit.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RatingOptionButton extends StatelessWidget {
  const RatingOptionButton({
    super.key,
    required this.rating,
    required this.callback,
    required this.selected,
  });

  final Rating rating;
  final bool selected;
  final Function(Rating) callback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        callback(rating);
      },
      child: Opacity(
        opacity: selected ? 1.0 : 0.3,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            border:
                selected
                    ? Border.all(color: Get.theme.primaryColor, width: 0.5)
                    : null,
            color: selected ? const Color(0xFFF5F5F5) : null,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Column(
            children: [
              rating.icon,
              const SizedBox(height: 4.0),
              Text(
                rating.localizedName,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
