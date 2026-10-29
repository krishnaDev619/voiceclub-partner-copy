import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class PopularQuestionsWidget extends StatefulWidget {
  final List<String> questions;
  final String label;

  const PopularQuestionsWidget({
    super.key,
    required this.questions,
    required this.label,
  });

  @override
  State<PopularQuestionsWidget> createState() => _PopularQuestionsWidgetState();
}

class _PopularQuestionsWidgetState extends State<PopularQuestionsWidget> {
  int currentQuestionIndex = 0;
  final _controller = CarouselSliderController();

  void nextQuestion() {
    setState(() {
      currentQuestionIndex =
          (currentQuestionIndex + 1) % widget.questions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isNotEmpty) {
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 40.0,
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 32.0,
              bottom: 16.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              border: Border.all(color: Get.theme.primaryColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CarouselSlider(
                  items:
                      widget.questions
                          .map(
                            (q) => Text(
                              q,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: FontSize.L,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          )
                          .toList(),
                  carouselController: _controller,
                  options: CarouselOptions(
                    viewportFraction: 1.0,
                    height: 36.0,
                    autoPlay: widget.questions.length > 1 ? true : false,
                    // enlargeCenterPage: true,
                    // aspectRatio: 1.6,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentQuestionIndex = index;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                        widget.questions.map((q) {
                          return GestureDetector(
                            onTap:
                                () => _controller.animateToPage(
                                  widget.questions.indexOf(q),
                                ),
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
                                      alpha:
                                          currentQuestionIndex ==
                                                  widget.questions.indexOf(q)
                                              ? 0.9
                                              : 0.4,
                                    ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0.0, -12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: FittedBox(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: FontSize.M,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
