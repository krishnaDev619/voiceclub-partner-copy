import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class LocationService {
  // Future<void> fetchAndSetLocation() async {
  //   String? city, state;
  //   try {
  //     var position = await _determinePosition();
  //     var response = await sl<GetAddressUseCase>().call(
  //       Params(
  //         latitude: position.latitude.toString(),
  //         longitude: position.longitude.toString(),
  //       ),
  //     );
  //     if (response.data != null) {
  //       city = response.data?.city;
  //       state = response.data?.state;

  //       if ((city?.isNotEmpty ?? false) || (state?.isNotEmpty ?? false)) {
  //         Get.find<DataController>()
  //             .updateLocation(city: city ?? "", state: state ?? "");
  //       }
  //     }
  //   } catch (_) {
  //   } finally {}
  // }

  // Fetch Latitude and Longitude in a formatted String
  Future<String> fetchLatLong() async {
    try {
      var position = await _determinePosition();
      return "${position.latitude}, ${position.longitude}";
    } catch (_) {
      return "";
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.dialog(
          AlertDialog(
            title: Text(LocaleKeys.locationServiceDisabled.tr),
            content: Text(LocaleKeys.pleaseAllowLocationService.tr),
            actions: [
              CustomButton(
                text: LocaleKeys.settings.tr,
                onTap: () async {
                  await Geolocator.openLocationSettings();
                },
              ),
            ],
          ),
        );
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          Get.dialog(
            AlertDialog(
              title: Text(LocaleKeys.locationPermissionDisabled.tr),
              content: Text(LocaleKeys.pleaseAllowLocationPermission.tr),
              actions: [
                CustomButton(
                  text: LocaleKeys.settings.tr,
                  onTap: () async {
                    await Geolocator.openAppSettings();
                  },
                ),
              ],
            ),
          );
        }
      }
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return Future.error(e);
    }
  }
}
