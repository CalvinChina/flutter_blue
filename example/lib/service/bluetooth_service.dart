import 'package:get/get.dart';
import 'package:flutter_blue/flutter_blue.dart'; // 你提供的库
import 'package:permission_handler/permission_handler.dart';

abstract class IBluetoothService {
  Future<void> checkPermissionsAndConnect();
  Future<void> startDeviceScan();
  Future<void> stopDeviceScan();
  Future<void> connectToDevice(String deviceId);
  Future<void> disconnectDevice();
  Future<void> reconnectToDevice();
  Stream<List<BluetoothDevice>> getScannedDevices();
  Future<bool> isConnected();
}

class BluetoothServiceImpl extends IBluetoothService {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final RxList<BluetoothDevice> scannedDevices = <BluetoothDevice>[].obs;
  BluetoothDevice? connectedDevice;

  @override
  Future<void> checkPermissionsAndConnect() async {
    // 检查并请求蓝牙权限
    if (await _checkAndRequestPermissions()) {
      if (await flutterBlue.isOn) {
        startDeviceScan();
      } else {
        throw Exception("Bluetooth is not enabled.");
      }
    } else {
      throw Exception("Bluetooth permissions not granted.");
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    // 检查蓝牙和位置权限
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    // 检查是否所有权限都已授予
    return statuses.values.every((status) => status.isGranted);
  }

  @override
  Future<void> startDeviceScan() async {
// 启动扫描
    flutterBlue.startScan(timeout: Duration(seconds: 30));
    // 订阅 scanResults 流，实时更新 scannedDevices 列表
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        // 如果设备不在已扫描列表中，则添加
        if (!scannedDevices.contains(result.device)) {
          scannedDevices.add(result.device);
        }
      }
    });
  }

  @override
  Future<void> stopDeviceScan() async {
    flutterBlue.stopScan();
  }

  @override
  Future<void> connectToDevice(String deviceId) async {
    BluetoothDevice? device =
        scannedDevices.firstWhereOrNull((d) => d.id == deviceId);
    if (device != null) {
      await device.connect();
      connectedDevice = device;
    } else {
      throw Exception("Device not found.");
    }
  }

  @override
  Future<void> disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
    }
  }

  @override
  Future<void> reconnectToDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.connect();
    }
  }

  @override
  Stream<List<BluetoothDevice>> getScannedDevices() {
    return scannedDevices.stream;
  }

  @override
  Future<bool> isConnected() async {
    return connectedDevice != null;
  }
}
