import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class ConfirmationPopup extends StatelessWidget {
  final String name;
  final int amount;
  const ConfirmationPopup({
    super.key,
    required this.name,
    required this.amount,
  });

  void _goBack() {
    Get.back<bool>(result: false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _goBack();
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
                child: GestureDetector(
                  onTap: () {
                    _goBack();
                  },
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 12.0,
              ),
              width: MediaQuery.of(context).size.width,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Are you sure you want to upgrade chat with $name at ₹$amount?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: FontSize.xL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () {
                      Get.back<bool>(result: true);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.027, 0.973],
                          colors: [Color(0xFFFEC56B), Color(0xFFFF9937)],
                          transform: GradientRotation(
                            86.73,
                          ), // Adjust the gradient rotation angle
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Upgrade Now",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.xL,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
