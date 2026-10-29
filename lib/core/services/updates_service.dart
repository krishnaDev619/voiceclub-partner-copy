import 'package:shared_preferences/shared_preferences.dart';

class UpdatesService {
  Future<void> setLastViewedTime() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      "lastVisitedTime",
      DateTime.now().toString(),
    );
  }

  Future<String> getLastViewedTime() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("lastVisitedTime") ?? "";
  }
}
