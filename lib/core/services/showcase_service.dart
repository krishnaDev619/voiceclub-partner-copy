import 'package:showcaseview/showcaseview.dart';

class ShowcaseService {
  static void dismissShowCase() {
    try {
      final showcaseView = ShowcaseView.get();
      if (showcaseView.isShowcaseRunning) {
        showcaseView.dismiss();
      }
    } catch (_) {}
  }
}
