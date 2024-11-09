import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

class FindDevicesScreenController extends GetxController {
  var devices = <BluetoothDevice>[].obs;
  var scanResults = <ScanResult>[].obs;
  var isScanning = false.obs;

  // 开始扫描设备
  void startScan() {
    FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
    isScanning.value = true;
  }

  // 停止扫描设备
  void stopScan() {
    FlutterBlue.instance.stopScan();
    isScanning.value = false;
  }

  // 更新扫描结果
  void updateScanResults(List<ScanResult> newResults) {
    scanResults.assignAll(newResults);
  }

  // 更新已连接设备列表
  void updateConnectedDevices(List<BluetoothDevice> newDevices) {
    devices.assignAll(newDevices);
  }
}
