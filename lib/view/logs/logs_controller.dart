import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/data/models/get_logs_grouped_response.dart';
import 'package:voiceclub_partner/data/models/log.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_logs_grouped.dart';

class LogsController extends GetxController {
  final logs = <LogModel>{}.obs;
  final logsResponse = GetLogsGroupedResponseModel().obs;
  final isLoading = false.obs; // Loading state variable
  final isInit = false.obs; // Loading state variable
  final selectedOverviewFilter = OverviewFilter.Today.obs;
  final selectedLogType = LogType.Missed.obs;
  int _totalPages = 1;

  @override
  void onInit() {
    fetchLogs(logType: LogType.Missed, page: 1, limit: 30);
    super.onInit();
  }

  Future<void> fetchLogs({
    LogType? logType,
    int page = 1,
    int limit = 30,
    OverviewFilter? overviewFilter,
  }) async {
    if (logType != null) {
      selectedLogType.value = logType;
    }
    if (overviewFilter != null) {
      selectedOverviewFilter.value = overviewFilter;
    }
    if (page == 1) {
      _clearLogs();
      isLoading.value = true; // Set isLoading to true only when page is 1.
    }
    if (page <= _totalPages) {
      try {
        // Logger.logMessage(
        //   "FETCH LOGS called with:\nLOG TYPE: ${selectedLogType.value.name}\nPERIOD: ${selectedOverviewFilter.value.stringValue}\nPAGE: $page",
        //   name: "LogsController",
        // );
        await sl<GetLogsGroupedUsecase>()
            .call(
              Params(
                overviewFilter: selectedOverviewFilter.value,
                logType: selectedLogType.value,
                page: page,
                pageSize: 30,
              ),
            )
            .then((response) {
              logsResponse.value = response.data!;
              isInit.value = true;
              logs.addAll(logsResponse.value.logs ?? []);
              _totalPages = response.data?.totalPages ?? _totalPages;
            });
      } catch (_) {
      } finally {
        if (page == 1) {
          isLoading.value = false; // Set isLoading to false when page is not 1.
        }
      }
    }
  }

  void updateLogFilter({LogType? logType, OverviewFilter? overviewFilter}) {
    if (logType != null) {
      selectedLogType.value = logType;
    }
    if (overviewFilter != null) {
      selectedOverviewFilter.value = overviewFilter;
    }
  }

  void _clearLogs() {
    logs.clear();
    _totalPages = 1;
  }
}
