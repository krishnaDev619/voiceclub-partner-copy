import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';

class SubscriptionCarousel extends StatefulWidget {
  const SubscriptionCarousel({super.key});

  @override
  State<SubscriptionCarousel> createState() => _SubscriptionCarouselState();
}

class _SubscriptionCarouselState extends State<SubscriptionCarousel> {
  final images = [
    AssetConstants.audioSubGraphic,
    AssetConstants.textSubGraphic,
  ];
  int _current = 0;
  final _controller = CarouselSliderController();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.3;
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
              viewportFraction: 0.8,
              aspectRatio: width / height,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16.0),
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
