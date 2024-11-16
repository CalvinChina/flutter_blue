import 'package:flutter_blue_example/controller/device_controller.dart';
import 'package:flutter_blue_example/home/home_view.dart';
import 'package:flutter_blue_example/pages/pages.dart';
import 'package:get/get.dart';

final homeRouters = [
  GetPage(
      name: AppRouters.home,
      page: () => HomeView(), // 移除泛型参数
      binding: BindingsBuilder(() => Get.lazyPut(() => DeviceController()))),
];
