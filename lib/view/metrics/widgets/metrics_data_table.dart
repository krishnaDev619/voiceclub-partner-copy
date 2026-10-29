import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/metrics/probation_cutoff.dart';
import 'package:voiceclub_partner/data/models/metrics/probation_stat.dart';
import 'package:voiceclub_partner/view/metrics/widgets/metrics_data_source.dart';

const metricColumnName = 'Metrics';
const averageColumnName = 'Avg.';

class MetricsDataTable extends StatelessWidget {
  final List<ProbationStat> stats;
  final ProbationCutoff cutoff;
  final PartnerCurrentStatus stage;

  const MetricsDataTable({
    super.key,
    required this.stats,
    required this.cutoff,
    required this.stage,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> columns = [
      metricColumnName,
      ...stats.map((e) => e.date!),
      averageColumnName,
    ];

    final MetricsDataSource metricsDataSource = MetricsDataSource(
      stats: stats,
      columns: columns,
      cutoff: cutoff,
      stage: stage,
    );

    return Container(
      margin: const EdgeInsets.only(top: 12.0),
      clipBehavior: Clip.hardEdge,
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2.0),
        // borderRadius: BorderRadius.circular(16.0),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(16.0),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.0)],
      ),
      child: SfDataGridTheme(
        data: SfDataGridThemeData(
          frozenPaneLineWidth: 0.5,
          frozenPaneLineColor: Colors.black12,
        ),
        child: SfDataGrid(
          source: metricsDataSource,
          rowHeight: 60.0,
          headerGridLinesVisibility: GridLinesVisibility.horizontal,
          verticalScrollPhysics: const NeverScrollableScrollPhysics(),
          shrinkWrapRows: true,
          gridLinesVisibility: GridLinesVisibility.horizontal,
          frozenColumnsCount: 1,
          columns:
              columns.map((column) {
                bool isMetric = column == metricColumnName;
                return GridColumn(
                  width: isMetric ? 100.0 : 64.0,
                  columnName: column,
                  allowEditing: false,
                  allowFiltering: false,
                  allowSorting: false,
                  columnWidthMode: ColumnWidthMode.fitByColumnName,
                  label: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    width: isMetric ? 100.0 : 64.0,
                    child: FittedBox(
                      alignment: Alignment.center,
                      child: Text(
                        isMetric
                            ? column
                            : column == averageColumnName
                            ? averageColumnName
                            : DateFormat(
                              'dd MMM',
                            ).format(DateTime.parse(column)),
                        style: TextStyle(
                          color:
                              column == averageColumnName
                                  ? Colors.green
                                  : Colors.black,
                          fontFamily: GoogleFonts.mulish().fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }).toList(),
          columnWidthMode: ColumnWidthMode.fitByColumnName,
        ),
      ),
    );
  }
}
