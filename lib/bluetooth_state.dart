import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:at_at_mobile/constants.dart';


class MyBluetoothState extends ChangeNotifier {
  BluetoothState bluetoothState = BluetoothState.UNKNOWN;

  BluetoothDevice? connectedDevice;
  BluetoothConnection? bluetoothConnection;

  List<BluetoothDevice> pairedDevices = [];

  bool isLedOn = false;
  ActionSignal? robotAction;
  bool? _isBluetoothConnecting;

  bool get isBluetoothOn => bluetoothState.isEnabled;
  bool get isBluetoothConnecting => _isBluetoothConnecting ?? false;
  bool get isBluetoothConnected => connectedDevice != null ? true : false;
  bool get isConnected => (bluetoothConnection?.isConnected ?? false);


  MyBluetoothState() {
    refreshBluetoothState();
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      bluetoothState = state;
      if (state != BluetoothState.STATE_ON) {
        bluetoothConnection = null;
        connectedDevice = null;
      }
      log("Bluetooth state has changed. Current state: ${state.stringValue}");
      notifyListeners();
    });
  }


  void refreshBluetoothState() => 
    FlutterBluetoothSerial.instance.state
    .then((state) => bluetoothState = state)
    .then((_) => notifyListeners());


  void requestBluetoothState(bool enabled) {
    Future<bool?> outcome;
    if (enabled) {
      log("Requesting to enable bluetooth");
      outcome = FlutterBluetoothSerial.instance.requestEnable();
    } else {
      log("Requesting to disable bluetooth");
      outcome = FlutterBluetoothSerial.instance.requestDisable();
    }
    outcome.then((value) {
      if (value ?? false) {
        log("Request successful");
        refreshBluetoothState();
      } else {
        log("Request failed");
      }
    });
  }


  void connectToDevice(BuildContext context, BluetoothDevice device) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    if (!isBluetoothConnecting) {
      if (connectedDevice == null || device.address != connectedDevice!.address) {
        log("Trying to connect to device ${device.name} at address ${device.address}");
        _isBluetoothConnecting = true;
        BluetoothConnection.toAddress(device.address)
        .then((connection) {
          log("Connected successfully!");
          bluetoothConnection = connection;
          connectedDevice = device;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Connected to device!"))
          );
          notifyListeners();})
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Connection failed! Please try again."))
          );})
        .whenComplete(() {
          _isBluetoothConnecting = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are already connected to that device!"))
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bluetooth already connecting, waiting until done..."))
      );
    }
  }


  void disconnectBluetoothDevice() {
    if (bluetoothConnection != null) {
      bluetoothConnection!.finish();
      bluetoothConnection!.dispose();
      bluetoothConnection = null;
      connectedDevice = null;
      log("Bluetooth device disconnected!");
      notifyListeners();
    }
  }


  void updatePairedDevices() async {
    pairedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
    notifyListeners();
  }


  void updateRobotAction(ActionSignal action) {
    robotAction = action;
    notifyListeners();
  }


  void sendMovementSignal(ActionSignal signal) {
    String actionSignal = actionSignals[signal] ?? 'Error signal';
    if (bluetoothConnection != null) {
      bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode(actionSignal)));
      robotAction = signal;
      notifyListeners();
    }
  }


  void sendLedSignal() {
    String ledMessage = isLedOn ? "LED OFF;" : "LED ON;";
    if (bluetoothConnection != null) {
      bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode(ledMessage)));
      isLedOn = !isLedOn;
      notifyListeners();
    }
  }
}
