import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:implulsnew/bt/device/characteristic/characteristic_tile.dart';
import 'package:implulsnew/bt/device/descriptor_tile.dart';
import 'package:implulsnew/bt/device/service_tile.dart';

List<int> writeToDeviceBytes() {
  var writeInput = '111, 110';
  return writeInput.split(',').map(int.tryParse).toList();
}

class DeviceScreen extends StatelessWidget {
  DeviceScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(device.name),
          actions: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) {
                VoidCallback onPressed;
                String text;
                switch (snapshot.data) {
                  case BluetoothDeviceState.connected:
                    onPressed = () => device.disconnect();
                    text = 'DISCONNECT';
                    break;
                  case BluetoothDeviceState.disconnected:
                    onPressed = () => device.connect();
                    text = 'CONNECT';
                    break;
                  default:
                    onPressed = null;
                    text = snapshot.data.toString().substring(21).toUpperCase();
                    break;
                }
                return FlatButton(
                    onPressed: onPressed,
                    child: Text(
                      text,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .button
                          .copyWith(color: Colors.white),
                    ));
              },
            )
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}. Push right icon to refresh services'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) {
                    return IndexedStack(
                      index: snapshot.data ? 1 : 0,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () => device.discoverServices(),
                        ),
                        IconButton(
                          icon: SizedBox(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.grey),
                            ),
                            width: 18.0,
                            height: 18.0,
                          ),
                          onPressed: null,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            StreamBuilder<int>(
              stream: device.mtu,
              initialData: 0,
              builder: (c, snapshot) => ListTile(
                title: Text('MTU Size'),
                subtitle: Text('${snapshot.data} bytes'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => device.requestMtu(223),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (c, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: _buildServiceTiles(snapshot.data),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        )),
      ),
    );
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (service) => ServiceTile(
            service: service,
            characteristicTiles: service.characteristics
                .map(
                  (characteristic) => CharacteristicTile(
                    characteristic: characteristic,
                    onWritePressed: () async {
                      await characteristic.write(writeToDeviceBytes(),
                          withoutResponse: true);
                      print(characteristic.write(writeToDeviceBytes()));
                      print(writeToDeviceBytes());
                    },
                    onNotificationPressed: () async {
                      await characteristic
                          .setNotifyValue(!characteristic.isNotifying);
                    },
                    descriptorTiles: characteristic.descriptors
                        .map(
                          (descriptor) => DescriptorTile(
                            descriptor: descriptor,
                            onWritePressed: () =>
                                descriptor.write(writeToDeviceBytes()),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }
}
