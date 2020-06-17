import 'package:flutter/material.dart';
import 'package:implulsnew/bt/medical_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatefulWidget {
  const Chart({
    Key key,
    @required List<MedicalData> chartData,
  })  : _chartData = chartData,
        super(key: key);

  final List<MedicalData> _chartData;

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      legend: Legend(isVisible: true),
//      zoomPanBehavior:
//          ZoomPanBehavior(enablePinching: true, enablePanning: true),
      primaryXAxis: DateTimeAxis(majorGridLines: MajorGridLines(width: 0)),
      series: <ChartSeries<MedicalData, DateTime>>[
        LineSeries<MedicalData, DateTime>(
          name: 'EKG',
          dataSource: widget._chartData,
          xValueMapper: (MedicalData medicalData, _) => medicalData.dateTime,
          yValueMapper: (MedicalData medicalData, _) =>
              medicalData.ekgPoint.toDouble(),
          animationDuration: 0,
          dataLabelSettings: DataLabelSettings(
              isVisible: false, labelAlignment: ChartDataLabelAlignment.top),
        ),
      ],
    );
  }
}
