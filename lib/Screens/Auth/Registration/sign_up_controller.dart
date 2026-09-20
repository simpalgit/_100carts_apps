import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carts_app/Repositories/auth_repository.dart';
import 'package:carts_app/Utils/common_functions.dart';

class SignUpController extends GetxController {
  AuthRepository authRepository = AuthRepository();

  final Rx<TextEditingController> ctlUserName = TextEditingController().obs;
  final Rx<TextEditingController> ctlMobile = TextEditingController().obs;
  final Rx<TextEditingController> ctlEmail = TextEditingController().obs;
  final Rx<TextEditingController> ctlPassword = TextEditingController().obs;
  final Rx<TextEditingController> ctlConfPassword = TextEditingController().obs;
  final Rx<TextEditingController> ctlOtp = TextEditingController().obs;

  RxBool showHidePass = true.obs;
  RxBool showHideConfPass = true.obs;
  RxBool otpLoading = false.obs;
  RxBool isLoading = false.obs;
  RxBool showOtp = false.obs;
  RxString mobileNo = "".obs;

  RxString errorMobileText = "".obs,
      errorUserNameText = "".obs,
      errorPasswordText = "".obs,
      errorEmailText = "".obs,
      errorOTPText = "".obs;

  initData() {
    ctlUserName.value.clear();
    ctlMobile.value.clear();
    ctlEmail.value.clear();
    ctlPassword.value.clear();
    ctlConfPassword.value.clear();
    showHidePass.value = true;
    showHideConfPass.value = true;
    isLoading.value = false;
    otpLoading.value = false;
    showOtp.value = false;
    errorMobileText.value = "";
    errorUserNameText.value = "";
    errorPasswordText.value = "";
    errorEmailText.value = "";
    errorOTPText.value = "";
  }

  @override
  void dispose() {
    ctlUserName.value.dispose();
    ctlMobile.value.dispose();
    ctlEmail.value.dispose();
    ctlPassword.value.dispose();
    ctlConfPassword.value.dispose();
    ctlOtp.value.dispose();
    super.dispose();
  }

  Future onChangedFun(String mobile, BuildContext context) async {
    if (mobile.length == 10) {
      mobileNo.value = mobile;
      await getOtp(context);
    } else {
      errorMobileText.value = "";
      showOtp.value = false;
      ctlOtp.value.clear();
    }
  }

  loadingFun(bool val) {
    isLoading.value = val;
  }

  otpLoadingFun(bool val) {
    otpLoading.value = val;
  }

  void changeShowhidePass() {
    showHidePass.value = !showHidePass.value;
  }

  void changeShowhideConfPass() {
    showHideConfPass.value = !showHideConfPass.value;
  }

  Future<void> registerUser(
    BuildContext context,
  ) async {
    loadingFun(true);
    CommonFunctions.hideKeyboard(context);

    // Agar confirm password field empty hai lekin validate ho gaya to bhi
    // ya password aur confirm password match nahi ho rahe.
    if (ctlPassword.value.text.isEmpty) {
      CommonFunctions.showErrorSnackbar("Please enter password.");
      loadingFun(false);
      return;
    }

    if (ctlConfPassword.value.text.isNotEmpty && ctlPassword.value.text != ctlConfPassword.value.text) {
      CommonFunctions.showErrorSnackbar("Password does not match.");
      loadingFun(false);
      return;
    }

    // Since you don't seem to have a Confirm Password TextField in UI as per the screenshot,
    // (There is only one password field visible). 
    // We should skip checking for `ctlConfPassword.value.text` if it's empty in this context,
    // or you need to uncomment/add Confirm Password UI in sign_up.dart

    var emailVal = ctlEmail.value.text.trim().isNotEmpty
        ? ctlEmail.value.text.trim()
        : "${ctlMobile.value.text.trim()}@100carts.com";
    var jsonBody = json.encode({
      "name": ctlUserName.value.text,
      "email": emailVal,
      "mobile": ctlMobile.value.text,
      "password": ctlPassword.value.text,
      "otp": ctlOtp.value.text
    });
    var result = await authRepository.registerUser(jsonBody);

      result.fold((error) {
        CommonFunctions.showErrorSnackbar(error.message);

        loadingFun(false);
      }, (data) {
        errorUserNameText.value = "";
        errorMobileText.value = "";
        errorPasswordText.value = "";
        errorEmailText.value = "";
        if (data != null) {
          var responseJson = json.decode(data.body);

          if (data.statusCode == 400) {
            responseJson['errors'].forEach((k, v) {
              if (k == "name") {
                errorUserNameText.value = v[0];
              }
              if (k == "mobile") {
                errorMobileText.value = v[0];
              }
              if (k == "password") {
                errorPasswordText.value = v[0];
              }
              if (k == "email") {
                errorEmailText.value = v[0];
              }
              if (k == "otp") {
                errorEmailText.value = v[0];
              }
            });
          } else {
            if (responseJson['response'] == true) {
              CommonFunctions.showSuccessSnackbar("Login with new credentials");
              Get.back();
            } else {
              CommonFunctions.showErrorSnackbar(responseJson['msg']);
            }
          }
        }

        loadingFun(false);
      });
    // Removed the wrapping 'else' block from the old code logic
  }

  Future<void> getOtp(BuildContext context) async {
    otpLoadingFun(true);

    var passedData = json.encode({
      "mobile": ctlMobile.value.text,
    });
    final result = await authRepository.sendOtp(
      passedData: passedData,
    );

    result.fold(
      (error) {
        CommonFunctions.showErrorSnackbar(error.message);
        otpLoadingFun(false);
      },
      (data) {
        errorMobileText.value = "";

        if (data != null) {
          var responseJson = json.decode(data.body);

          if (data.statusCode == 400) {
            if (responseJson['response'] == false) {
              responseJson['errors'].forEach((k, v) {
                if (k == "mobile") {
                  errorMobileText.value = v[0];
                }
              });
            }
          } else if (data.statusCode == 200) {
            showOtp.value = true;
            if (responseJson['otp'] != null) {
              ctlOtp.value.text = responseJson['otp'].toString();
            }
            CommonFunctions.showSuccessSnackbar("Otp sent Successfully");
          }
        }

        otpLoadingFun(false);
      },
    );
  }
}
