import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';

class ShareablePayoutWidget extends StatelessWidget {
  final double amount;
  final String title;

  const ShareablePayoutWidget({
    super.key,
    required this.amount,
    this.title = 'First Payout Completed!',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // VoiceClub Logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(AssetConstants.logoHorizontal, height: 60),
              ],
            ),
            SizedBox(height: 10.0),

            Image.asset(
              AssetConstants.confettiSuccess,
              fit: BoxFit.contain,
              width: double.infinity,
              height: 150.0,
            ),

            SizedBox(height: 10.0),

            // Amount
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
