// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';


// Temporary TODO: remove and restore the proper version from below

import 'package:flutter/material.dart';

class BluetoothPage extends StatelessWidget {
  const BluetoothPage({super.key});

  @override
  Widget build(BuildContext context) {
    throw const Placeholder();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     color: Colors.blue.shade300,
  //     width: 300,
  //     height: 100,
  //     alignment: Alignment.center,
  //     child: const Text("Module not ready yet..."),
  //   );
  // }
}



// PROPER VERSION:

// class BluetoothPage extends StatefulWidget {
//   const BluetoothPage({super.key});

//   @override
//   State<BluetoothPage> createState() => _BluetoothPageState();
// }

// class _BluetoothPageState extends State<BluetoothPage> {
//   BluetoothManager bluetoothManager = BluetoothManager.instance;

//   bool _connected = false;
//   BluetoothDevice? _device;
//   String tips = 'no device connect';

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     // print(bluetoothManager.isConnected);
//     // print(bluetoothManager.state);
//     return const Center(
//       child: Placeholder()
//     );
//   }

//   Future<void> initBluetooth() async {
//     bluetoothManager.startScan(timeout: Duration(seconds: 4));

//     bool isConnected = await bluetoothManager.isConnected;

//     bluetoothManager.state.listen((state) {
//       print('cur device status: $state');

//       switch (state) {
//         case BluetoothManager.CONNECTED:
//           setState(() {
//             _connected = true;
//             tips = 'connect success';
//           });
//           break;
//         case BluetoothManager.DISCONNECTED:
//           setState(() {
//             _connected = false;
//             tips = 'disconnect success';
//           });
//           break;
//         default:
//           break;
//       }
//     });

//     if (!mounted) return;

//     if (isConnected) {
//       setState(() {
//         _connected = true;
//       });
//     }
//   }

//   void _onConnect() async {
//     if (_device != null && _device?.address != null) {
//       await bluetoothManager.connect(_device!);
//     } else {
//       setState(() {
//         tips = 'please select device';
//       });
//       print('please select device');
//     }
//   }
// }
