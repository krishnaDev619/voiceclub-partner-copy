import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/metrics/probation_cutoff.dart';
import 'package:voiceclub_partner/data/models/metrics/probation_stat.dart';
import 'package:voiceclub_partner/view/metrics/widgets/metrics_data_table.dart';

class MetricsDataSource extends DataGridSource {
  final List<ProbationStat> stats;
  final ProbationCutoff cutoff;
  final List<String> columns;
  final PartnerCurrentStatus stage;
  late List<DataGridRow> _dataGridRows;

  MetricsDataSource({
    required this.stats,
    required this.columns,
    required this.cutoff,
    required this.stage,
  }) {
    _dataGridRows = _buildDataGridRows();
  }

  double _calculateAverage(List<num?> values) {
    final validValues = values.where((e) => e != null).cast<num>().toList();
    return validValues.isNotEmpty
        ? validValues.reduce((a, b) => a + b) / validValues.length
        : 0.0;
  }

  List<DataGridRow> _buildDataGridRows() {
    return [
      if (stage != PartnerCurrentStatus.PROBATION)
        DataGridRow(
          cells: [
            DataGridCell<String>(
              columnName: metricColumnName,
              value:
                  'Avg Call Duration New${cutoff.avgCallDurationNew != null ? "\n(${cutoff.avgCallDurationNew?.toStringAsFixed(1)} min)" : ""}',
            ),
            ...stats.map(
              (e) => DataGridCell<DataCellModel>(
                columnName: e.date!,
                value: DataCellModel(
                  displayValue:
                      e.avgCallDurationNew != null
                          ? e.avgCallDurationNew!.toStringAsFixed(1)
                          : "-",
                  value: e.avgCallDurationNew,
                  cutoff: cutoff.avgCallDurationNew,
                ),
              ),
            ),
            DataGridCell<DataCellModel>(
              columnName: averageColumnName,
              value: DataCellModel(
                displayValue: _calculateAverage(
                  stats.map((e) => e.avgCallDurationNew).toList(),
                ).toStringAsFixed(1),
                value: _calculateAverage(
                  stats.map((e) => e.avgCallDurationNew).toList(),
                ),
                cutoff: cutoff.avgCallDurationNew,
              ),
            ),
          ],
        ),
      if (stage != PartnerCurrentStatus.PROBATION)
        DataGridRow(
          cells: [
            DataGridCell<String>(
              columnName: metricColumnName,
              value:
                  'Avg Call Duration Old${cutoff.avgCallDurationOld != null ? "\n(${cutoff.avgCallDurationOld?.toStringAsFixed(1)} min)" : ""}',
            ),
            ...stats.map(
              (e) => DataGridCell<DataCellModel>(
                columnName: e.date!,
                value: DataCellModel(
                  displayValue:
                      e.avgCallDurationOld != null
                          ? e.avgCallDurationOld!.toStringAsFixed(1)
                          : "-",
                  value: e.avgCallDurationOld,
                  cutoff: cutoff.avgCallDurationOld,
                ),
              ),
            ),
            DataGridCell<DataCellModel>(
              columnName: averageColumnName,
              value: DataCellModel(
                displayValue: _calculateAverage(
                  stats.map((e) => e.avgCallDurationNew).toList(),
                ).toStringAsFixed(1),
                value: _calculateAverage(
                  stats.map((e) => e.avgCallDurationNew).toList(),
                ),
                cutoff: cutoff.avgCallDurationNew,
              ),
            ),
          ],
        ),
      DataGridRow(
        cells: [
          DataGridCell<String>(
            columnName: metricColumnName,
            value:
                'App Online Duration${cutoff.appOnlineDuration != null ? "\n(${cutoff.appOnlineDuration?.toStringAsFixed(0)} hrs)" : ""}',
          ),
          ...stats.map(
            (e) => DataGridCell<DataCellModel>(
              columnName: e.date!,
              value: DataCellModel(
                displayValue:
                    e.appOnlineDuration != null
                        ? e.appOnlineDuration!.toStringAsFixed(0)
                        : "-",
                value: e.appOnlineDuration,
                cutoff: cutoff.appOnlineDuration,
              ),
            ),
          ),
          DataGridCell<DataCellModel>(
            columnName: averageColumnName,
            value: DataCellModel(
              displayValue: _calculateAverage(
                stats.map((e) => e.appOnlineDuration).toList(),
              ).toStringAsFixed(0),
              value: _calculateAverage(
                stats.map((e) => e.appOnlineDuration).toList(),
              ),
              cutoff: cutoff.appOnlineDuration,
            ),
          ),
        ],
      ),
      if (stage != PartnerCurrentStatus.LIVE)
        DataGridRow(
          cells: [
            DataGridCell<String>(
              columnName: metricColumnName,
              value:
                  'New User Audio${cutoff.callToAudio != null ? "\n(${cutoff.callToAudio?.toStringAsFixed(0)}%)" : ""}',
            ),
            ...stats.map(
              (e) => DataGridCell<DataCellModel>(
                columnName: e.date!,
                value: DataCellModel(
                  displayValue:
                      e.callToAudio != null
                          ? e.callToAudio!.toStringAsFixed(0)
                          : "-",
                  value: e.callToAudio,
                  cutoff: cutoff.callToAudio,
                ),
              ),
            ),
            DataGridCell<DataCellModel>(
              columnName: averageColumnName,
              value: DataCellModel(
                displayValue: _calculateAverage(
                  stats.map((e) => e.callToAudio).toList(),
                ).toStringAsFixed(0),
                value: _calculateAverage(
                  stats.map((e) => e.callToAudio).toList(),
                ),
                cutoff: cutoff.callToAudio,
              ),
            ),
          ],
        ),
      DataGridRow(
        cells: [
          DataGridCell<String>(
            columnName: metricColumnName,
            value:
                'Chat Sent${cutoff.totalChatSent != null ? "\n(${cutoff.totalChatSent?.toStringAsFixed(0)})" : ""}',
          ),
          ...stats.map(
            (e) => DataGridCell<DataCellModel>(
              columnName: e.date!,
              value: DataCellModel(
                displayValue:
                    e.totalChatSent != null
                        ? e.totalChatSent!.toStringAsFixed(0)
                        : "-",
                value: e.totalChatSent,
                cutoff: cutoff.totalChatSent,
              ),
            ),
          ),
          DataGridCell<DataCellModel>(
            columnName: averageColumnName,
            value: DataCellModel(
              displayValue: _calculateAverage(
                stats.map((e) => e.totalChatSent).toList(),
              ).toStringAsFixed(0),
              value: _calculateAverage(
                stats.map((e) => e.totalChatSent).toList(),
              ),
              cutoff: cutoff.totalChatSent,
            ),
          ),
        ],
      ),
      DataGridRow(
        cells: [
          DataGridCell<String>(
            columnName: metricColumnName,
            value:
                'Chat Received${cutoff.totalChatReceived != null ? "\n(${cutoff.totalChatReceived?.toStringAsFixed(0)})" : ""}',
          ),
          ...stats.map(
            (e) => DataGridCell<DataCellModel>(
              columnName: e.date!,
              value: DataCellModel(
                displayValue:
                    e.totalChatReceived != null
                        ? e.totalChatReceived!.toStringAsFixed(0)
                        : "-",
                value: e.totalChatReceived,
                cutoff: cutoff.totalChatReceived,
              ),
            ),
          ),
          DataGridCell<DataCellModel>(
            columnName: averageColumnName,
            value: DataCellModel(
              displayValue: _calculateAverage(
                stats.map((e) => e.totalChatReceived).toList(),
              ).toStringAsFixed(0),
              value: _calculateAverage(
                stats.map((e) => e.totalChatReceived).toList(),
              ),
              cutoff: cutoff.totalChatReceived,
            ),
          ),
        ],
      ),
    ];
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataGridCell) {
            bool isMetric = dataGridCell.columnName == metricColumnName;
            return MetricCellDataWidget(
              isMetric: isMetric,
              dataGridCell: dataGridCell,
            );
          }).toList(),
    );
  }
}

class DataCellModel {
  final String? displayValue;
  final num? value;
  final num? cutoff;

  DataCellModel({this.displayValue, this.value, this.cutoff});
}

class MetricCellDataWidget extends StatelessWidget {
  final bool isMetric;
  final DataGridCell<dynamic> dataGridCell;

  const MetricCellDataWidget({
    super.key,
    required this.isMetric,
    required this.dataGridCell,
  });

  @override
  Widget build(BuildContext context) {
    if (isMetric) {
      return Container(
        width: 100.0,
        height: 60.0,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(
          left: isMetric ? 8.0 : 0.0,
          top: 2.0,
          bottom: 2.0,
        ),
        child: Text(
          dataGridCell.value.toString(),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.mulish().fontFamily,
            fontSize: FontSize.M,
          ),
          maxLines: 3,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      final DataCellModel dataCellModel = dataGridCell.value as DataCellModel;
      return Container(
        width: 100.0,
        height: 60.0,
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          left: isMetric ? 8.0 : 0.0,
          top: 2.0,
          bottom: 2.0,
        ),
        child: Text(
          dataCellModel.displayValue ?? "-",
          style: TextStyle(
            color:
                dataCellModel.displayValue != "-"
                    ? ((dataCellModel.value ?? 0) >=
                            (dataCellModel.cutoff ?? 0))
                        ? Colors.green
                        : Colors.red
                    : Colors.grey,
            fontWeight: FontWeight.normal,
            fontFamily: GoogleFonts.mulish().fontFamily,
            fontSize: FontSize.L,
          ),
          maxLines: 3,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
  }
}
