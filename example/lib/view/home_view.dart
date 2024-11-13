import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/device_controller.dart';

class HomeView extends StatelessWidget {
  final DeviceController deviceController = Get.find<DeviceController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Connection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() => Text(
                'Connection Status: ${deviceController.isConnected.value ? "Connected" : "Not Connected"}')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => deviceController.checkPermissionsAndConnect(),
              child: Text('Check Permissions & Connect'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => deviceController.startDeviceScan(),
              child: Text('Start Device Scan'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => deviceController.reconnectToDevice(),
              child: Text('Reconnect to Device'),
            ),
          ],
        ),
      ),
    );
  }
}
