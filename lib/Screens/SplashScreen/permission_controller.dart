import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:carts_app/Utils/common_functions.dart';

class PermissionController extends GetxController {
  var page = 0.obs;
  var pageController = PageController();
  RxBool isStorageLoading = false.obs;
  RxBool isCameraLoading = false.obs;
  // RxBool isLocationLoading = false.obs;
  RxBool isNotificationLoading = false.obs;

  RxString storage = "".obs;
  RxString notification = "".obs;
  RxString camera = "".obs;
  // RxString location = "".obs;
  // RxString latitude = "".obs;
  // RxString longitude = "".obs;

  onPageChanged(input) {
    page.value = input;
  }

  animateTo(int page) {
    if (pageController.hasClients) {
      pageController.animateToPage(page,
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  Future checkNotificationStatus() async {
    CommonFunctions().checkRouteAndRedirect();
  }

  Future requestCameraPermission() async {
    isCameraLoading.value = true;
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      camera.value = "Granted";
    } else if (status.isPermanentlyDenied) {
      camera.value = "Denied";
      await Permission.camera.request();
    } else {
      openAppSettings();
      camera.value = "Permenantly Denied";
    }

    isCameraLoading.value = false;

    if (camera.value == "Granted") {
      animateTo(1);
    }
  }

  Future requestStoragePermission() async {
    isStorageLoading.value = true;
    // PermissionStatus status = await Permission.storage.request();
    final plugin = DeviceInfoPlugin();

    PermissionStatus storageStatus;
    if (Platform.isAndroid) {
      final android = await plugin.androidInfo;
      storageStatus = android.version.sdkInt < 33
          ? await Permission.storage.request()
          : PermissionStatus.granted;
    } else {
      storageStatus = await Permission.storage.status;
    }
    if (storageStatus.isGranted) {
      storage.value = "Granted";
    } else if (storageStatus.isPermanentlyDenied) {
      await Permission.storage.status;
    } else {
      storage.value = "Permenantly Denied";
      openAppSettings();
    }
    isStorageLoading.value = false;
    if (storage.value == "Granted") {
      animateTo(2);
    }
  }

  Future requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
    } else if (status.isDenied) {
      await Permission.location.request();
    } else {
      openAppSettings();
    }
  }

  Future requestNotificationPermission() async {
    isNotificationLoading.value = true;
    PermissionStatus status = await Permission.notification.request();

    if (status.isGranted) {
      notification.value = "Granted";
    } else if (status.isDenied) {
      notification.value = "Denied";
      await Permission.notification.request();
    } else {
      openAppSettings();
      notification.value = "Permenantly Denied";
    }
    isNotificationLoading.value = false;
    if (notification.value == "Granted") {
      // navigate to next page
      CommonFunctions().checkRouteAndRedirect();
    }
  }
}
