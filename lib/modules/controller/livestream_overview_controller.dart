// import 'package:get/get.dart';
// import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
// import 'package:voiceclub_partner/data/models/livestream/livestream_overview_response.dart';
// import 'package:voiceclub_partner/core/injection_container.dart';
// import 'package:voiceclub_partner/domain/usecases/livestream/get_livestream_overview.dart';

// class LivestreamOverviewController extends GetxController {
//   final overview = LivestreamOverviewResponseModel().obs;
//   final isLoading = false.obs;
//   final _getLivestreamOverviewUsecase = sl<GetLivestreamOverviewUsecase>();

//   @override
//   void onInit() {
//     fetchData();
//     super.onInit();
//   }

//   void fetchData() async {
//     try {
//       isLoading(true);
//       update();
//       final overviewResponseResponse =
//           await _getLivestreamOverviewUsecase.call(NoParams());
//       if (overviewResponseResponse.data != null &&
//           overviewResponseResponse.error == null) {
//         overview.value = overviewResponseResponse.data!;
//       }
//     } catch (_) {
//     } finally {
//       isLoading(false);
//       update();
//     }
//   }
// }
