// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// import 'package:flutter_blue_example/ble_off.dart';
// import 'package:flutter_blue_example/find_device.dart';

// void main() {
//   runApp(FlutterBlueApp());
// }

// class FlutterBlueApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       color: Colors.lightBlue,
//       home: StreamBuilder<BluetoothState>(
//           stream: FlutterBlue.instance.state,
//           initialData: BluetoothState.unknown,
//           builder: (c, snapshot) {
//             final state = snapshot.data;
//             if (state == BluetoothState.on) {
//               return FindDevicesScreen();
//             }
//             return BluetoothOffScreen();
//           }),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_blue_example/home/home_view.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_example/controller/device_controller.dart';
import 'package:flutter_blue_example/pages/pages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Bluetooth Demo',
      initialBinding:
          BindingsBuilder(() => Get.lazyPut(() => DeviceController())),
      home: HomeView(), // 直接使用HomeView作为首页
      getPages: appRouters, // 使用appRouters中的路由
    );
  }
}
