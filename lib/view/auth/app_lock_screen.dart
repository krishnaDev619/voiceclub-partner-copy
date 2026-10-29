import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class AppLockScreen extends StatelessWidget {
  final VoidCallback onUnlock;

  const AppLockScreen({super.key, required this.onUnlock});

  Future<void> _authenticate() async {
    final LocalAuthentication auth = LocalAuthentication();

    try {
      final isAuthenticated = await auth.authenticate(
        localizedReason: 'Unlock to access the app',
      );

      if (isAuthenticated) {
        onUnlock();
      } else {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.liveFailedToAuthenticate.tr,
          subtitle: LocaleKeys.pleaseTryAgain.tr,
        );
      }
    } catch (e) {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.liveFailedToAuthenticate.tr,
        subtitle: LocaleKeys.pleaseTryAgain.tr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.95),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Unlock the App',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(LocaleKeys.liveAuthenticate.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
