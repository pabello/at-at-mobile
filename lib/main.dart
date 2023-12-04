import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
// import 'dart:typed_data';

import 'package:at_at_mobile/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// TODO: Brobot: próba połączenia, jak bluetooth już jest połączony wywołuje exception

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  List<_DeviceWithAvailability> devices =
      List<_DeviceWithAvailability>.empty(growable: true);

  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  int _discoverableTimeoutSecondsLeft = 0;

  bool? _isDiscovering;
  bool? isConnecting;
  bool? isDisconnecting;
  bool? isLedOn;

  Timer? _discoverableTimeoutTimer;
  BluetoothConnection? bluetoothConnection;
  bool get isConnected => (bluetoothConnection?.isConnected ?? false);

  @override
  void initState() {
    super.initState();

    _isDiscovering = false;
    isConnecting = false;
    isDisconnecting = false;
    isLedOn = false;

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {});

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoveryStreamSubscription?.cancel();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  void listPairedDevices() {
    FlutterBluetoothSerial.instance
      .getBondedDevices()
      .then((List<BluetoothDevice> bondedDevices) {
        setState(() {
          devices = bondedDevices
            .map((device) => _DeviceWithAvailability(device, _DeviceAvailability.yes))
            .toList();
      });
    });
  }

  void _startDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var iterDevice = i.current;
          if (iterDevice.device == r.device) {
            iterDevice.availability = _DeviceAvailability.yes;
            iterDevice.rssi = r.rssi;
          }
        }
      });
    });

    _discoveryStreamSubscription?.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<ListTile> deviceList = devices
        .map((listDevice) => ListTile(
              title: Text(listDevice.device.name ?? 'Unnamed device'),
              subtitle: Text(listDevice.device.address),
              enabled: listDevice.availability == _DeviceAvailability.yes,
              onTap: () {
                log("Trying to connect to device ${listDevice.device.name} at address ${listDevice.device.address}");
                BluetoothConnection.toAddress(listDevice.device.address).then((connection) {
                  log("Connected successfully!");
                  bluetoothConnection = connection;
                  setState(() {
                    isConnecting = false;
                    isDisconnecting = false;
                  });
                }).onError((error, stackTrace) {
                  log("Connection failed...");
                  print(stackTrace);
                });
              },
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          if (_isDiscovering != null && _isDiscovering!)
            FittedBox(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              ),
            )
          else IconButton(
            icon: const Icon(Icons.replay),
            onPressed: _startDiscovery,
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bluetooth),
          ListTile(
            title: const Text("Enable Bluetooth"),
            subtitle: Text(_bluetoothState.toString()),
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
                  value: _bluetoothState.isEnabled,
                  onChanged: (bool value) {
                    future() async {
                      if (value) {
                        await FlutterBluetoothSerial.instance.requestEnable();
                      } else {
                        await FlutterBluetoothSerial.instance.requestDisable();
                      }
                    }
                    future().then((_) {
                      setState(() {});
                    });
                  },
                )
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              // _startDiscovery();
              listPairedDevices();
            },
            icon: const Icon(Icons.search),
            label: const Text("Show paired devices")
          ),
          ListView(
            shrinkWrap: true,
            children: deviceList
          ),
          ListTile(
            title: ElevatedButton(
              child: const Text('Disconnect bluetooth'),
              onPressed: null,
              // onPressed: isConnected ? () async {
              //   bluetoothConnection?.finish()
              //     .then((_) {
              //       bluetoothConnection?.dispose();
              //       setState(() {});
              //       log("Bluetooth disconnected.");
              //     });
              // } : null
            ),
          ),
          ListTile(
            title: ElevatedButton(
              // onPressed: null,
              onPressed: () => log(actionMessages[RobotAction.goForward]!),
              child: const Text('Test enum'),
            ),
          ),
          FilledButton.icon(
            onPressed: isConnected ? () async {
              if (isLedOn != null && isLedOn!) {
                log("Sending signal OFF");
                bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("LED OFF;")));
                await bluetoothConnection!.output.allSent.then((value) => log("Message sent. Receilved callback: $value")).then((_) => setState(() {
                  isLedOn = false;
                },));
              } else {
                log("Sending signal ON");
                bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode("LED ON;")));
                await bluetoothConnection!.output.allSent.then((value) => log("Message sent. Receilved callback: $value")).then((_) => setState(() {
                  isLedOn = true;
                },));
              }
            } : null,
            icon: isLedOn != null ? 
                (isLedOn! ? const Icon(Icons.lightbulb) : const Icon(Icons.lightbulb_outline))
              : const Icon(Icons.question_mark),
            label: const Text("Power ON/OFF the LED")
          )
        ],
      ),
    );
  }
}

enum _DeviceAvailability {
  yes,
  maybe,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
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
