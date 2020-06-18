import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:implulsnew/bt/device/descriptor_tile.dart';
import 'package:implulsnew/chart/ekg_chart_screen.dart';

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;
  final VoidCallback onNotificationPressed;

  const CharacteristicTile(
      {Key key,
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
  final _listData = [];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: buildColumn(context),
    );
//    return Center(
//      child: StreamBuilder<List<int>>(
//        stream: widget.characteristic.value,
//        initialData: widget.characteristic.lastValue,
//        builder: (c, snapshot) {
//          var _btData = snapshot.data;
//
////          byteConversion(_btData);
//
//          return buildColumn(context, snapshot);
//        },
//      ),
//    );
  }

  Column buildColumn(BuildContext context) {
    var charUUID = widget.characteristic.uuid.toString();
    var isEKG = charUUID.contains('526af7764f64');

    return Column(
      children: <Widget>[
        ExpansionTile(
          title: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(isEKG ? 'EKG' : ''),
                Text(charUUID.contains('df60bd72') ? 'IBI' : ''),
                Text(
                  '$charUUID',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(
                      color: Theme
                          .of(context)
                          .textTheme
                          .caption
                          .color),
                ),
                isEKG
                    ? FlatButton(
                  child: Text("GOTO Chart"),
                  onPressed: () =>
                      Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  EkgChartScreen(widget.characteristic))),
                )
                    : SizedBox(),
              ],
            ),
            contentPadding: EdgeInsets.all(0.0),
          ),
//          trailing: Row(
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              SizedBox(
//                width: 40,
//              ),
//              IconButton(
//                icon: Icon(Icons.edit,
//                    color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
//                onPressed: widget.onWritePressed,
//              ),
//              Text('W'),
//              SizedBox(
//                width: 40,
//              ),
//              IconButton(
//                icon: Icon(
//                    widget.characteristic.isNotifying
//                        ? Icons.sync_disabled
//                        : Icons.sync,
//                    color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
//                onPressed: widget.onNotificationPressed,
//              ),
//              ButtonButton(
//                onPressed: () async {
//                  Text('pressed');
//                  Text('$writeToDeviceBytes()');
//                },
//                child: Container(
//                  width: 300,
//                  color: Colors.indigo.shade50,
//                  child: TextField(
//                    onChanged: (text) {
////                      writeInput = text;
//                    },
//                    textAlign: TextAlign.center,
//                    style: TextStyle(color: Colors.black),
//                    decoration: InputDecoration(
//                        labelText: "Choose Service, then W",
//                        border: OutlineInputBorder()),
//                  ),
//                ),
//              ),
//            ],
//          ),
//          children: widget.descriptorTiles,
        ),
      ],
    );
  }
}
