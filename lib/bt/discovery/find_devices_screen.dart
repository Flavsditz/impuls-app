import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:implulsnew/bt/device/device_screen.dart';
import 'package:implulsnew/bt/discovery/scan_result_tile.dart';

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices List'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              buildListOfPairedDevices(context),
              buildListOfDiscoveredDevices(context),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (ctx, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }

  StreamBuilder<List<BluetoothDevice>> buildListOfPairedDevices(
      BuildContext context) {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: Stream.periodic(Duration(seconds: 3))
          .asyncMap((_) => FlutterBlue.instance.connectedDevices),
      initialData: [],
      builder: (ctx, snapshot) => Column(
        children: snapshot.data
            .map((device) => ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.id.toString()),
                  trailing: StreamBuilder<BluetoothDeviceState>(
                    stream: device.state,
                    initialData: BluetoothDeviceState.disconnected,
                    builder: (ctx, snapshot) {
                      if (snapshot.data == BluetoothDeviceState.connected) {
                        return RaisedButton(
                          child: Text('OPEN'),
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DeviceScreen(device: device))),
                        );
                      }
                      return Text(snapshot.data.toString());
                    },
                  ),
                ))
            .toList(),
      ),
    );
  }

  StreamBuilder<List<ScanResult>> buildListOfDiscoveredDevices(
      BuildContext context) {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBlue.instance.scanResults,
      initialData: [],
      builder: (ctx, snapshot) => Column(
        children: snapshot.data
            .map(
              (result) => ScanResultTile(
                result: result,
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  result.device.connect();
                  return DeviceScreen(device: result.device);
                })),
              ),
            )
            .toList(),
      ),
    );
  }
}
