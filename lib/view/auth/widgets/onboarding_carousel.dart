import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final images = [
    AssetConstants.onboarding1,
    AssetConstants.onboarding2,
    AssetConstants.onboarding3,
    AssetConstants.onboarding4,
  ];
  int _current = 0;
  final _controller = CarouselSliderController();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.4;
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(
          height: height,
          width: width,
          child: CarouselSlider(
            items:
                images.map((e) {
                  return Image.asset(e);
                }).toList(),
            carouselController: _controller,
            options: CarouselOptions(
              autoPlay: true,
              viewportFraction: 1.0,
              aspectRatio: width / height,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 32.0),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:
                images.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.grey)
                            .withValues(
                              alpha: _current == entry.key ? 0.9 : 0.4,
                            ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
