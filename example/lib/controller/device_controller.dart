import 'package:get/get.dart';
import '../service/bluetooth_service.dart';
import 'package:flutter_blue/flutter_blue.dart'; // 你提供的库

class DeviceController extends GetxController {
  final IBluetoothService _bluetoothService = Get.find<IBluetoothService>();

  var isConnected = false.obs;
  var isScanning = false.obs;
  var scannedDevices = <BluetoothDevice>[].obs;

  void checkPermissionsAndConnect() async {
    try {
      await _bluetoothService.checkPermissionsAndConnect();
    } catch (e) {
      // 处理权限未授权的情况
    }
  }

  void startDeviceScan() async {
    isScanning.value = true;
    await _bluetoothService.startDeviceScan();
    _bluetoothService.getScannedDevices().listen((devices) {
      scannedDevices.value = devices;
    });
    isScanning.value = false;
  }

  void connectToDevice(String deviceId) async {
    await _bluetoothService.connectToDevice(deviceId);
    isConnected.value = await _bluetoothService.isConnected();
  }

  void disconnectDevice() async {
    await _bluetoothService.disconnectDevice();
    isConnected.value = false;
  }

  void reconnectToDevice() async {
    await _bluetoothService.reconnectToDevice();
    isConnected.value = await _bluetoothService.isConnected();
  }
}
