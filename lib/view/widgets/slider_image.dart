import 'package:carousel_slider/carousel_slider.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

class SliderImage extends StatefulWidget {
  final List<String> bannerImage;
  const SliderImage({super.key, required this.bannerImage});

  @override
  State<SliderImage> createState() => _SliderImageState();
}

class _SliderImageState extends State<SliderImage> {
  int _current = 0;
  final _controller = CarouselSliderController();
  @override
  Widget build(BuildContext context) {
    return widget.bannerImage.isEmpty
        ? const SizedBox.shrink()
        : Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.09,
              width: MediaQuery.of(context).size.width,
              child: CarouselSlider(
                items:
                    widget.bannerImage.map((e) {
                      return Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color(0xffFFECEC),
                          image: DecorationImage(
                            // fit: BoxFit.,
                            image: FastCachedImageProvider(e),
                          ),
                        ),
                        height: MediaQuery.of(context).size.height * 0.09,
                      );
                    }).toList(),
                carouselController: _controller,
                options: CarouselOptions(
                  autoPlay: true,
                  // enlargeCenterPage: true,
                  // aspectRatio: 1.6,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 1,
              // left: MediaQuery.of(context).size.width / 2,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:
                      widget.bannerImage.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _controller.animateToPage(entry.key),
                          child: Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 4.0,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness ==
                                          Brightness.dark
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
            ),
          ],
        );
  }
}
