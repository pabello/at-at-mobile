import 'package:at_at_mobile/constants.dart';
import 'package:at_at_mobile/provider/bluetooth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';


class BluetoothPage extends StatefulWidget {
  const BluetoothPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  BluetoothConnection? get bluetoothConnection => Provider.of<MyBluetoothState>(context, listen:false).bluetoothConnection;
  bool get isConnected => bluetoothConnection?.isConnected ?? false;

  @override
  void initState() {
    Provider.of<MyBluetoothState>(context, listen: false).refreshBluetoothState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Icon(Icons.bluetooth),  // TODO: zrobić super indicator z wykorzystaniem pluginu avatar_glow
        ListTile(
          title: const Text("Enable Bluetooth"),
          subtitle: Text(Provider.of<MyBluetoothState>(context).bluetoothState.stringValue),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
                icon: const Icon(Icons.settings)
              ),
              Switch.adaptive(
                value: Provider.of<MyBluetoothState>(context).isBluetoothOn,
                onChanged: (bool value) =>
                    Provider.of<MyBluetoothState>(context, listen: false).requestBluetoothState(value),
              )
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "To connect a device, pair with it in the blueooth settings",
            textAlign: TextAlign.center,
            textScaleFactor: 0.85,
            style: TextStyle(color: Colors.grey),),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: bluetoothButtonsPadding),
          child: OutlinedButton.icon(
            onPressed: () {
              Provider.of<MyBluetoothState>(context, listen: false).updatePairedDevices();
            },
            icon: const Icon(Icons.search),
            label: const Text("Show paired devices")
          ),
        ),
        ListView(
          shrinkWrap: true,
          children: List.from(
            Provider.of<MyBluetoothState>(context).pairedDevices
            .map((device) => PairedDeviceTile(device: device))
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: bluetoothButtonsPadding),
          child: ElevatedButton(
            onPressed: isConnected ?
              () => Provider.of<MyBluetoothState>(context, listen: false).disconnectBluetoothDevice()
              : null,
            child: const Text('Disconnect bluetooth'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: bluetoothButtonsPadding),
          child: FilledButton.icon(
            onPressed: Provider.of<MyBluetoothState>(context).isConnected ? () async {
              if (Provider.of<MyBluetoothState>(context, listen: false).isLedOn) {
                Provider.of<MyBluetoothState>(context, listen: false).sendLedSignal();
                // await bluetoothConnection!.output.allSent.then((value) => log("Message sent. Receilved callback: $value"))
              } else {
                Provider.of<MyBluetoothState>(context, listen: false).sendLedSignal();
                // await bluetoothConnection!.output.allSent.then((value) => log("Message sent. Receilved callback: $value"))
              }
            } : null,
            icon: Provider.of<MyBluetoothState>(context, listen: true).isLedOn ? 
              const Icon(Icons.lightbulb) : const Icon(Icons.lightbulb_outline),
            label: Text("Power ${Provider.of<MyBluetoothState>(context, listen: true).isLedOn ? 
              "OFF" : "ON"} the LED")
          ),
        ),
      ],
    );
  }
}

class PairedDeviceTile extends StatelessWidget {
  const PairedDeviceTile({super.key, required this.device});

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(device.name ?? 'Unnamed device'),
      subtitle: Text(device.address, textScaleFactor: 0.9,),
      onTap: () => Provider.of<MyBluetoothState>(context, listen: false).connectToDevice(context, device),
    );
  }
}
