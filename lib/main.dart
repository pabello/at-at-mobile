import 'package:at_at_mobile/provider/bluetooth_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:at_at_mobile/page_router.dart';


void main() => runApp(
  ChangeNotifierProvider(
    create: (context) => MyBluetoothState(),
    child: const MyApp())
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      routerConfig: router ,
    );
  }
}
