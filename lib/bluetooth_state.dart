import 'package:flutter/cupertino.dart';
import 'package:at_at_mobile/constants.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BlouetoothState extends ChangeNotifier {
  bool? isBluetoothOn;
  BluetoothDevice? connectedDevice;
  RobotAction? robotAction;

  bool get isBluetoothConnected => connectedDevice != null ? true : false;


  void updateBluetoothOn(bool isBluetoothOn) {
    this.isBluetoothOn = isBluetoothOn;
    notifyListeners();
  }

  void updateConnectedDevice(BluetoothDevice device) {
    connectedDevice = device;
    notifyListeners();
  }

  void updateRobotAction(RobotAction action) {
    robotAction = action;
    notifyListeners();
  }
}