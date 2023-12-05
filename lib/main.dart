import 'package:at_at_mobile/bluetooth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

void main() => runApp(
    ChangeNotifierProvider(
      create: (context) => MyBluetoothState(),
      child: const MyApp(),
    )
  );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Bluetooth Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothConnection? get bluetoothConnection => Provider.of<MyBluetoothState>(context, listen:false).bluetoothConnection;
  bool get isConnected => bluetoothConnection?.isConnected ?? false;

  @override
  void initState() {
    Provider.of<MyBluetoothState>(context, listen: false).refreshBluetoothState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          OutlinedButton.icon(
            onPressed: () {
              Provider.of<MyBluetoothState>(context, listen: false).updatePairedDevices();
            },
            icon: const Icon(Icons.search),
            label: const Text("Show paired devices")
          ),
          ListView(
            shrinkWrap: true,
            children: List.from(
              Provider.of<MyBluetoothState>(context).pairedDevices
              .map((device) => PairedDeviceTile(device: device))
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: isConnected ?
                () => Provider.of<MyBluetoothState>(context, listen: false).disconnectBluetoothDevice()
                : null,
              child: const Text('Disconnect bluetooth'),
            ),
          ),
          FilledButton.icon(
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
          )
        ],
      ),
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.title)),
//       body:
//         // mainAxisSize: MainAxisSize.min,
//         // children: [
//           // const Icon(Icons.bluetooth),
//           ListView(
//             children: [
//               // ListTile(
//               //   title: const Text("Enable Bluetooth"),
//               //   trailing: Row(
//               //     children: <Widget>[
//               //       IconButton(
//               //         onPressed: () {
//               //           FlutterBluetoothSerial.instance.openSettings();
//               //         },
//               //         icon: const Icon(Icons.settings)
//               //       ),
//               //       Switch.adaptive(
//               //         value: _bluetoothState.isEnabled,
//               //         onChanged: (bool value) {
//               //           future() async {
//               //             if (value) {
//               //               await FlutterBluetoothSerial.instance.requestEnable();
//               //             } else {
//               //               await FlutterBluetoothSerial.instance.requestDisable();
//               //             }
//               //           }
//               //           future().then((_) {
//               //             setState(() {});
//               //           });
//               //         },
//               //       )
//               //     ],
//               //   ),
//               // ),
//               SwitchListTile(
//                 title: const Text('Enable Bluetooth'),
//                 value: _bluetoothState.isEnabled,
//                 onChanged: (bool value) {
//                   future() async {
//                     if (value) {
//                       await FlutterBluetoothSerial.instance.requestEnable();
//                     } else {
//                       await FlutterBluetoothSerial.instance.requestDisable();
//                     }
//                   }
//                   future().then((_) {
//                     setState(() {});
//                   });
//                 },
//               ),
//               ListTile(
//                 title: const Text('Bluetooth status'),
//                 subtitle: Text(_bluetoothState.toString()),
//                 trailing: ElevatedButton(
//                   child: const Text('Settings'),
//                   onPressed: () {
//                     FlutterBluetoothSerial.instance.openSettings();
//                   },
//                 ),
//               ),
//             ],
//           ),
//     );
//   }
// }

// class _MyHomePageState extends State<MyHomePage> {
//   BluetoothManager bluetoothManager = BluetoothManager.instance;

//   bool isConnected = false;
//   BluetoothDevice? _device;
//   String tips = 'No device connected';
//   double _bluetoothSearchProgress = 0.0;
//   final Duration _bluetoothSearchDuration = const Duration(seconds: 10);

//   @override
//   void initState() {
//     super.initState();

//     const timerInterval = Duration(milliseconds: 100);

//     Timer(_bluetoothSearchDuration, () => setState(() {
//         _bluetoothSearchProgress += timerInterval.inMilliseconds / _bluetoothSearchDuration.inMilliseconds;
//       })
//     );
    
//     // Timer.periodic(timerInterval, (Timer timer) {
//     //   setState(() {
//     //     // Increment the progress value by the interval
//     //     _bluetoothSearchProgress += timerInterval.inMilliseconds / _bluetoothSearchDuration.inMilliseconds;

//     //     // If the progress reaches 1.0, reset it to 0.0
//     //     if (_bluetoothSearchProgress >= 1.0) {
//     //       _bluetoothSearchProgress = 0.0;
//     //     }
//     //   });
//     // });

//   }

//   // @override
//   // void initState() {
//   //   super.initState();

//   //   WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
//   // }

//   // // Platform messages are asynchronous, so we initialize in an async method.
//   // Future<void> initBluetooth() async {
//   //   bluetoothManager.startScan(timeout: Duration(seconds: 4));

//   //   bool isConnected = await bluetoothManager.isConnected;

//   //   bluetoothManager.state.listen((state) {
//   //     print('cur device status: $state');

//   //     switch (state) {
//   //       case BluetoothManager.CONNECTED:
//   //         setState(() {
//   //           _connected = true;
//   //           tips = 'connect success';
//   //         });
//   //         break;
//   //       case BluetoothManager.DISCONNECTED:
//   //         setState(() {
//   //           _connected = false;
//   //           tips = 'disconnect success';
//   //         });
//   //         break;
//   //       default:
//   //         break;
//   //     }
//   //   });

//   //   if (!mounted) return;

//   //   if (isConnected) {
//   //     setState(() {
//   //       _connected = true;
//   //     });
//   //   }
//   // }

//   // void _onConnect() async {
//   //   if (_device != null && _device!.address != null) {
//   //     await bluetoothManager.connect(_device!);
//   //   } else {
//   //     setState(() {
//   //       tips = 'please select device';
//   //     });
//   //     print('please select device');
//   //   }
//   // }

//   // void _onDisconnect() async {
//   //   await bluetoothManager.disconnect();
//   // }

//   // void _sendData() async {
//   //   List<int> bytes = latin1.encode('Hello world!\n\n\n').toList();

//   //   // Set codetable west. Add import 'dart:typed_data';
//   //   // List<int> bytes = Uint8List.fromList(List.from('\x1Bt'.codeUnits)..add(6));
//   //   // Text with special characters
//   //   // bytes += latin1.encode('blåbærgrød\n\n\n');

//   //   await bluetoothManager.writeData(bytes);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Bluetooth test"),
//       ),
//       body: Column(children: [
//         StreamBuilder<bool>(
//           stream: bluetoothManager.isScanning,
//           builder: (context, snapshot) {
//             bool state = false;
//             if (snapshot.hasData) {
//               state = snapshot.data!;
//             }
//             return SizedBox(
//               width: 200,
//               height: 100,
//               child: Text(state ? "Scanning" : "Not scanning"),
//             );
//           },
//         ),
//         StreamBuilder<bool>(
//           stream: bluetoothManager.isScanning,
//           builder: (context, snapshot) {
//             if (snapshot.hasData && !snapshot.data!) {
//               return OutlinedButton(
//                 onPressed: () {
//                     bluetoothManager.startScan(timeout: _bluetoothSearchDuration);
//                     bluetoothManager.scan(timeout: _bluetoothSearchDuration);
//                 },
//                 child: const Text("Start scanning"),
//               );
//             } else {
//               return OutlinedButton(
//                 onPressed: () {
//                   bluetoothManager.stopScan();
//                 },
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text("Stop scanning"),
//                     Transform.scale(
//                       scale: .5,
//                       child: CircularProgressIndicator(value: _bluetoothSearchProgress,)
//                     )
//                   ],
//                 ),
//               );
//             }
//           }
//         ),
//         StreamBuilder<List<BluetoothDevice>>(
//           stream: bluetoothManager.scanResults,
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               if (snapshot.data!.isEmpty) {
//                 return ColoredBox(
//                   color: Colors.amber.shade200,
//                   child: const SizedBox(
//                     width: 200,
//                     height: 50,
//                   )
//                 );
//               } else {
//                 final items = snapshot.data;
//                 return Expanded(
//                   child: ListView.builder(
//                     itemCount: items!.length,
//                     itemBuilder:(context, index) {
//                       BluetoothDevice item = items[index];
//                       bool itemConnected = false;
//                       if (item.connected != null) itemConnected = item.connected!;
//                       return ListTile(
//                         title: Text(item.name ?? "Unknown"),
//                         subtitle: Text(item.address ?? ""),
//                         leading: Icon(Icons.bluetooth, color: itemConnected ? Colors.blue : Colors.grey,),
//                         onTap: () async {
//                           log("'${item.name}' with address ${item.address}. Trying to connect...");
//                           await bluetoothManager.connect(item);
//                         },
//                       );
//                     },
//                   ),
//                 );
//               }
//             } else if (snapshot.hasError) {
//               return ColoredBox(
//                   color: Colors.red.shade300,
//                   child: const SizedBox(
//                     width: 200,
//                     height: 50,
//                     child: Text("Scanning error"),
//                   )
//                 );
//             } else {
//               return ColoredBox(
//                   color: Colors.purple.shade300,
//                   child: const SizedBox(
//                     width: 200,
//                     height: 50,
//                   )
//                 );
//             }
//           },
//         ),
//         FutureBuilder(
//           future: bluetoothManager.isConnected,
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               final connectionStatus = snapshot.data!;
//               return SizedBox(
//                 height: 50,
//                 child: Text(connectionStatus ? "Connected" : "Disconnected"),
//               );
//             } else {
//               return const SizedBox();
//             }
//           },
//         ),
//       ]),
//     );
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       title: Text(widget.title),
//   //     ),
//   //     body: RefreshIndicator(
//   //       onRefresh: () =>
//   //           bluetoothManager.startScan(timeout: Duration(seconds: 4)),
//   //       child: SingleChildScrollView(
//   //         child: Column(
//   //           children: <Widget>[
//   //             Row(
//   //               mainAxisAlignment: MainAxisAlignment.center,
//   //               children: <Widget>[
//   //                 Padding(
//   //                   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//   //                   child: Text(tips),
//   //                 ),
//   //               ],
//   //             ),
//   //             Divider(),
//   //             StreamBuilder<List<BluetoothDevice>>(
//   //               stream: bluetoothManager.scanResults,
//   //               initialData: [],
//   //               builder: (c, snapshot) {
//   //                 if (snapshot.hasData) {
//   //                   return Column(
//   //                     children: snapshot.data!.map((d) => ListTile(
//   //                               title: Text(d.name ?? ''),
//   //                               subtitle: Text(d.address ?? 'awaiting data'),
//   //                               onTap: () async {
//   //                                 setState(() {
//   //                                   _device = d;
//   //                                 });
//   //                               },
//   //                               trailing:
//   //                                   _device != null && _device!.address == d.address
//   //                                       ? Icon(
//   //                                           Icons.check,
//   //                                           color: Colors.green,
//   //                                         )
//   //                                       : null,
//   //                             ))
//   //                         .toList(),
//   //                   );
//   //                 } else {
//   //                   return Container(width: 100, height: 100, color: Colors.red);
//   //                 }
//   //               }
//   //             ),
//   //             Divider(),
//   //             Container(
//   //               padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
//   //               child: Column(
//   //                 children: <Widget>[
//   //                   Row(
//   //                     mainAxisAlignment: MainAxisAlignment.center,
//   //                     children: <Widget>[
//   //                       OutlinedButton(
//   //                         child: Text('connect'),
//   //                         onPressed: _connected ? null : _onConnect,
//   //                       ),
//   //                       SizedBox(width: 10.0),
//   //                       OutlinedButton(
//   //                         child: Text('disconnect'),
//   //                         onPressed: _connected ? _onDisconnect : null,
//   //                       ),
//   //                     ],
//   //                   ),
//   //                   OutlinedButton(
//   //                     child: Text('Send test data'),
//   //                     onPressed: _connected ? _sendData : null,
//   //                   ),
//   //                 ],
//   //               ),
//   //             )
//   //           ],
//   //         ),
//   //       ),
//   //     ),
//   //     floatingActionButton: StreamBuilder<bool>(
//   //       stream: bluetoothManager.isScanning,
//   //       initialData: false,
//   //       builder: (c, snapshot) {
//   //         if (snapshot.data != null) {
//   //           return FloatingActionButton(
//   //             child: Icon(Icons.stop),
//   //             onPressed: () => bluetoothManager.stopScan(),
//   //             backgroundColor: Colors.red,
//   //           );
//   //         } else {
//   //           return FloatingActionButton(
//   //               child: Icon(Icons.search),
//   //               onPressed: () =>
//   //                   bluetoothManager.startScan(timeout: Duration(seconds: 4)));
//   //         }
//   //       },
//   //     ),
//   //   );
//   // }
// }
