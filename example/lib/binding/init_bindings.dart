import 'package:get/get.dart';
import '../service/bluetooth_service.dart';
import '../controller/device_controller.dart';

class InitBindings extends Bindings {
  @override
  void dependencies() {
    // 注册 BluetoothService
    Get.lazyPut<IBluetoothService>(() => BluetoothServiceImpl());
    // 注册 DeviceController
    Get.lazyPut<DeviceController>(() => DeviceController());
  }
}
