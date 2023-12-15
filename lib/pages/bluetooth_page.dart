import 'package:at_at_mobile/constants.dart';
import 'package:at_at_mobile/provider/bluetooth_state.dart';
import 'package:avatar_glow/avatar_glow.dart';
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

  Color get circleColor => Provider.of<MyBluetoothState>(context).isConnected ? Colors.greenAccent.shade400 : Colors.grey.shade100;

  @override
  void initState() {
    Provider.of<MyBluetoothState>(context, listen: false).refreshBluetoothState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color glowColor;
    if (Provider.of<MyBluetoothState>(context, listen: false).isBluetoothOn) {
      if (Provider.of<MyBluetoothState>(context, listen: false).isConnected) {
        glowColor = Colors.greenAccent.shade700;
      } else {
        glowColor = Colors.blue;
      }
    } else {
      glowColor = Colors.white;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 10, width: MediaQuery.of(context).size.width,),
        AvatarGlow(
          glowColor: glowColor,
          endRadius: 90,
          duration: const Duration(milliseconds: 4000),
          repeat: true,
          showTwoGlows: true,
          repeatPauseDuration: const Duration(milliseconds: 100),
          child: Material(
            elevation: 16.0,
            shape: const CircleBorder(),
            child: CircleAvatar(
              backgroundColor: circleColor,
              radius: 40.0,
              child: const Icon(Icons.bluetooth),
            ),
          ),
        ),
        
        // const Icon(Icons.bluetooth),  // TODO: zrobić super indicator z wykorzystaniem pluginu avatar_glow
        ListTile(
          title: const Text("Enable Bluetooth"),
          subtitle: Text(Provider.of<MyBluetoothState>(context).bluetoothState.stringValue),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 24, 0),
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
              showGeneralDialog(
                context: context,
                pageBuilder: (context, animation, secondaryAnimation) => const PairedDevicesPopUp(),
              );
            },
            icon: const Icon(Icons.search),
            label: const Text("Show paired devices")
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(device.name ?? 'Unnamed device'),
      subtitle: Text(device.address, textScaleFactor: 0.9,),
      onTap: () => Provider.of<MyBluetoothState>(context, listen: false).connectToDevice(context, device),
    );
  }
}

class PairedDevicesPopUp extends StatelessWidget {
  const PairedDevicesPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      actionsPadding: const EdgeInsets.only(bottom: 12),
      titlePadding: EdgeInsets.zero,
      title: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 8),
            child: Text("Paired devices"),
          ),
          Divider(height: 0, indent: 0, endIndent: 0,)
        ],
      ),
      actions: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Divider(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(fontSize: 14,),)
            )
          ],
        )
      ],
      content: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) =>
          PairedDeviceTile(device: Provider.of<MyBluetoothState>(context, listen: false).pairedDevices[index]),
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey[350],
          height: 0,
        ),
        itemCount: Provider.of<MyBluetoothState>(context).pairedDevices.length,
      ),
    );
  }
}