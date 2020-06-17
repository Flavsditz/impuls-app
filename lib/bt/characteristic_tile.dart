import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:implulsnew/bt/Bluetooth_screen.dart';
import 'package:implulsnew/bt/chart.dart';
import 'package:implulsnew/bt/descriptor_tile.dart';
import 'package:implulsnew/bt/medical_data.dart';
import 'package:implulsnew/bt/scroll_list.dart';
import 'package:implulsnew/styles/button.dart';

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;
  final VoidCallback onNotificationPressed;

  const CharacteristicTile({Key key,
    this.characteristic,
    this.descriptorTiles,
    this.onReadPressed,
    this.onWritePressed,
    this.onNotificationPressed})
      : super(key: key);

  @override
  _CharacteristicTileState createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  final List<MedicalData> _chartData = [
    MedicalData(DateTime.now(), 0),
  ];
  final _listData = [];

//  final isolates = IsolateHandler();
//  int counter = 0;
//
//  void main() {
//    // Start the isolate at the `entryPoint` function.
//    isolates.spawn<int>(entryPoint,
//        name: "counter",
//        // Executed every time data is received from the spawned isolate.
//        onReceive: setCounter,
//        // Executed once when spawned isolate is ready for communication.
//        onInitialized: () => isolates.send(counter, to: "counter")
//    );
//  }
//
//// Set new count and display current count.
//  void setCounter(int count) {
//    counter = count;
//    print("Counter is now $counter");
//
//    // We will no longer be needing the isolate, let's dispose of it.
//    isolates.kill("counter");
//  }
//
//// This function happens in the isolate.
//  void entryPoint(Map<String, dynamic> context) {
//    // Calling initialize from the entry point with the context is
//    // required if communication is desired. It returns a messenger which
//    // allows listening and sending information to the main isolate.
//    final messenger = HandledIsolate.initialize(context);
//
//    // Triggered every time data is received from the main isolate.
//    messenger.listen((count) {
//      // Add one to the count and send the new value back to the main
//      // isolate.
//      messenger.send(++count);
//    });
//  }

  @override
  Widget build(BuildContext context) {
    widget.characteristic.value.listen((event) {})

    return Center(
      child: StreamBuilder<List<int>>(
        stream: widget.characteristic.value,
        initialData: widget.characteristic.lastValue,
        builder: (c, snapshot) {
          var _btData = snapshot.data;

          byteConversion(_btData);

          return buildColumn(context, snapshot);
        },
      ),
    );
  }

  void byteConversion(List<int> _btData) {
    print(_btData);
    if (_btData.length == 2) {
      if (_chartData.length > 300) {
        _chartData.removeAt(0);
      }
      ByteData bytedata1 =
      ByteData.sublistView(Uint8List.fromList(_btData.reversed.toList()));
      print(bytedata1);
      int _ekgPoint = bytedata1.getInt16(0, Endian.big);
      print(_ekgPoint);

      _chartData.add(MedicalData(DateTime.now(), _ekgPoint));
    } else if (_btData.length == 4) {
      ByteData bytedata2 =
      ByteData.sublistView(Uint8List.fromList(_btData.reversed.toList()));
      print(bytedata2);
      if (widget.characteristic.serviceUuid.toString() ==
          '00b3b02e-928b-11e9-bc42-526af7764f64') {
        double _ibiPoint = bytedata2.getFloat32(0, Endian.big);
        print(_ibiPoint);
        _listData.add(_ibiPoint);
      } else {
        int _countDown = bytedata2.getUint32(0, Endian.big);
        print(_countDown);
        _listData.add(_countDown);
      }
    }
    print(_chartData[0].dateTime);
  }

  Column buildColumn(BuildContext context, AsyncSnapshot<List<int>> snapshot) {
    return Column(
      children: <Widget>[
        ExpansionTile(
          title: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.characteristic.uuid
                    .toString()
                    .contains('526af7764f64')
                    ? 'EKG'
                    : ''),
                Text(widget.characteristic.uuid.toString().contains('df60bd72')
                    ? 'IBI'
                    : ''),
                Text('${widget.characteristic.uuid.toString()}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(
                        color: Theme
                            .of(context)
                            .textTheme
                            .caption
                            .color))
              ],
            ),
            subtitle: Text(snapshot.data.toString()),
            contentPadding: EdgeInsets.all(0.0),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 40,
              ),
              IconButton(
                icon: Icon(Icons.edit,
                    color: Theme
                        .of(context)
                        .iconTheme
                        .color
                        .withOpacity(0.5)),
                onPressed: widget.onWritePressed,
              ),
              Text('W'),
              SizedBox(
                width: 40,
              ),
              IconButton(
                icon: Icon(
                    widget.characteristic.isNotifying
                        ? Icons.sync_disabled
                        : Icons.sync,
                    color: Theme
                        .of(context)
                        .iconTheme
                        .color
                        .withOpacity(0.5)),
                onPressed: widget.onNotificationPressed,
              ),
              ButtonButton(
                onPressed: () async {
                  Text('pressed');
                  Text('$writeToDeviceBytes()');
                },
                child: Container(
                  width: 300,
                  color: Colors.indigo.shade50,
                  child: TextField(
                    onChanged: (text) {
                      writeInput = text;
                    },
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        labelText: "Choose Service, then W",
                        border: OutlineInputBorder()),
                  ),
                ),
              ),
            ],
          ),
          children: widget.descriptorTiles,
        ),
        (snapshot.data.length == 2)
            ? Chart(chartData: _chartData)
            : ScrollList(listData: _listData),
      ],
    );
  }
}
