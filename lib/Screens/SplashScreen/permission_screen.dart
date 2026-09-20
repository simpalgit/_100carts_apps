import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carts_app/Utils/common_functions.dart';
import 'package:carts_app/Utils/images.dart';
import 'package:carts_app/Widgets/permission_widget.dart';

import 'permission_controller.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CommonFunctions().checkRouteAndRedirect();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
