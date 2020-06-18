import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:implulsnew/chart/chart.dart';
import 'package:implulsnew/chart/medical_data.dart';

class EkgChartScreen extends StatefulWidget {
  final BluetoothCharacteristic ekgCharacteristic;

  const EkgChartScreen(this.ekgCharacteristic);

  @override
  _EkgChartScreenState createState() => _EkgChartScreenState();
}

class _EkgChartScreenState extends State<EkgChartScreen> {
  final List<MedicalData> _chartData = [
    MedicalData(DateTime.now(), 0),
  ];

  final List<int> _checker = [];

  bool isNotifying = false;
  Timer _timer;

  @override
  void initState() {
    isNotifying = widget.ekgCharacteristic.isNotifying;

    widget.ekgCharacteristic.value.listen((event) {
      int ekgPoint = byteConversion(event);
      if (ekgPoint != null) {
        MedicalData medicalData = MedicalData(DateTime.now(), ekgPoint);

        if (medicalData != null) {
          _chartData.add(medicalData);
        }
      }
    });

    _startTimer();

    super.initState();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      print("Size of list: ${_chartData.length}");
      setState(() {});
    });
  }

  int byteConversion(List<int> _btData) {
    if (_btData.length == 2) {
      if (_chartData.length > 300) {
        _chartData.removeAt(0);
      }
      ByteData byteData =
          ByteData.sublistView(Uint8List.fromList(_btData.reversed.toList()));
      int ekgPoint = byteData.getInt16(0, Endian.big);

//      if (ekgPoint == -305) {
//        //Beginning of List
//        print("CHECKER LIST: $_checker");
//        _checker.clear();
//      }
//      _checker.add(ekgPoint);

      return ekgPoint;
    } else if (_btData.length == 4) {
      // What is this case?
//      ByteData bytedata =
//          ByteData.sublistView(Uint8List.fromList(_btData.reversed.toList()));
//      print(bytedata);
//      if (widget.characteristic.serviceUuid.toString() ==
//          '00b3b02e-928b-11e9-bc42-526af7764f64') {
//        double _ibiPoint = bytedata.getFloat32(0, Endian.big);
//        print(_ibiPoint);
//        _listData.add(_ibiPoint);
//      } else {
//        int _countDown = bytedata.getUint32(0, Endian.big);
//        print(_countDown);
//        _listData.add(_countDown);
//      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("EKG"),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                FlatButton(
                  child:
                      Text(isNotifying ? "Unsubscribe" : "Subscribe to Stream"),
                  onPressed: () {
                    if (widget.ekgCharacteristic.isNotifying) {
                      _timer.cancel();
                      setState(() {
                        isNotifying = false;
                      });
                    } else {
                      _startTimer();
                      setState(() {
                        isNotifying = true;
                      });
                    }
                    widget.ekgCharacteristic
                        .setNotifyValue(!widget.ekgCharacteristic.isNotifying);
                  },
                ),
                Container(
                  child: Chart(
                    chartData: _chartData,
                  ),
                ),
              ],
            ),
          )),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
