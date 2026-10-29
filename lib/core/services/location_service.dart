import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_location.dart'
    as update_location;
import 'package:voiceclub_partner/domain/usecases/krutrim_maps/get_address.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class LocationService {
  final String _locationKey = "location";

  // Cached location data
  Position? _cachedPosition;
  String? _cachedCity;
  String? _cachedState;
  bool _isInitialized = false;

  // Initialize location service at splash screen
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      _cachedPosition = await _determinePosition();
      if (_cachedPosition != null) {
        var response = await sl<GetAddressUseCase>().call(
          Params(
            latitude: _cachedPosition!.latitude.toString(),
            longitude: _cachedPosition!.longitude.toString(),
          ),
        );
        if (response.data != null) {
          _cachedCity = response.data?.city;
          _cachedState = response.data?.state;
          await _setUpdateLocation();
        }
      }
    } catch (e) {
      Logger.logMessage(
        "Error initializing location service: $e",
        name: "LocationService",
      );
    }
  }

  Future<bool> _isLocationUpdated() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_locationKey) ?? false;
  }

  Future<void> _setUpdateLocation() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(_locationKey, true);
  }

  Future<void> fetchAndSetLocation() async {
    String? city, state;
    try {
      var position = await _determinePosition();
      if (position == null) {
        return;
      }
      var response = await sl<GetAddressUseCase>().call(
        Params(
          latitude: position.latitude.toString(),
          longitude: position.longitude.toString(),
        ),
      );
      if (response.data != null) {
        city = response.data?.city;
        state = response.data?.state;

        _updateLocation(city: city ?? "", state: state ?? "");
        _setUpdateLocation();
      }
    } catch (_) {
    } finally {}
  }

  // Fetch Latitude and Longitude in a formatted String
  Future<String> fetchLatLong() async {
    if (_cachedPosition != null) {
      return "${_cachedPosition!.latitude}, ${_cachedPosition!.longitude}";
    }

    try {
      var position = await _determinePosition();
      if (position != null) {
        _cachedPosition = position;
        return "${position.latitude}, ${position.longitude}";
      }
      return "";
    } catch (_) {
      return "";
    }
  }

  Future<void> _updateLocation({
    required String city,
    required String state,
  }) async {
    try {
      var response = await sl<update_location.UpdateLocationUseCase>().call(
        update_location.Params(city: city, state: state),
      );
      if (response.data != null && response.error == null) {}
    } catch (_) {}
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.dialog(
          AlertDialog(
            title: const Text("Location Service Disabled"),
            content: const Text("Please allow location service"),
            actions: [
              CustomButton(
                text: "Settings",
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
              title: const Text("Location permission disabled"),
              content: const Text("Please allow location permission"),
              actions: [
                CustomButton(
                  text: "Settings",
                  onTap: () async {
                    await Geolocator.openAppSettings();
                  },
                ),
              ],
            ),
          );
          return null; // Return early if permission is not granted
        }
      }

      // Only call getCurrentPosition if permission is granted
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        return pos;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> checkAndUpdateLocation() async {
    bool isUpdated = await _isLocationUpdated();
    if (isUpdated) {
      await _updateLocation(city: _cachedCity ?? "", state: _cachedState ?? "");
    }
    if (isUpdated) {
      return;
    }
    await fetchAndSetLocation();
  }

  /// Fetches the user's current city with Delhi as default fallback
  ///
  /// Returns the city name as a string. If location services are disabled,
  /// permissions are denied, or any error occurs, returns "Delhi" as default.
  Future<String> fetchCity() async {
    // Return cached city if available
    if (_cachedCity != null) {
      return _cachedCity!;
    }

    try {
      // Get current position and fetch address
      final latLong = await fetchLatLong();
      if (latLong.isNotEmpty) {
        final position = latLong.split(", ");
        if (position.length == 2) {
          final response = await sl<GetAddressUseCase>().call(
            Params(latitude: position[0].trim(), longitude: position[1].trim()),
          );
          if (response.data != null && response.data?.city != null) {
            _cachedCity = response.data?.city; // Cache the city
            Logger.logMessage(
              "Successfully fetched city: ${response.data?.city}",
              name: "LocationService",
            );
            return response.data!.city!;
          }
        }
      }

      Logger.logMessage(
        "Failed to fetch city, using default: Delhi",
        name: "LocationService",
      );
      return "Delhi";
    } catch (e) {
      Logger.logMessage(
        "Error fetching city: $e, using default: Delhi",
        name: "LocationService",
      );
      return "Delhi";
    }
  }
}
