import 'package:carousel_slider/carousel_slider.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> banners;
  const ImageCarousel({super.key, required this.banners});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _current = 0;
  final _controller = CarouselSliderController();
  @override
  Widget build(BuildContext context) {
    return widget.banners.isEmpty
        ? const SizedBox.shrink()
        : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width,
                  child: CarouselSlider(
                    items:
                        widget.banners.map((e) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: const Color(0xffFFECEC),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FastCachedImageProvider(e),
                              ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.3,
                          );
                        }).toList(),
                    carouselController: _controller,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.3,
                      viewportFraction: 1.0,
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
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                    widget.banners.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _controller.animateToPage(entry.key),
                        child: Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(
                            vertical: 0.0,
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
          ],
        );
  }
}
