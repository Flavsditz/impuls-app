import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:implulsnew/bt/discovery/bluetooth_off_screen.dart';
import 'package:implulsnew/bt/discovery/find_devices_screen.dart';

class BluetoothDiscovery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
      stream: FlutterBlue.instance.state,
      initialData: BluetoothState.unknown,
      builder: (c, snapshot) {
        final state = snapshot.data;
        if (state == BluetoothState.on) {
          return FindDevicesScreen();
        }
        return BluetoothOffScreen(state: state);
      },
    );
  }
}
