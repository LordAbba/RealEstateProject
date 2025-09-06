
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LandingController extends GetxController {
  var searchKeywords = ''.obs;
  var selectedType = 'rent'.obs;
  var selectedPropertyType = 'apartment'.obs;
  var selectedLocation = ''.obs;
  var isSearching = false.obs;

  void onSearch() {
    isSearching.value = true;
    Future.delayed(Duration(seconds: 1), () {
      isSearching.value = false;
      Get.toNamed('/login');
    });
  }

  void goToLogin() {
    Get.toNamed('/login');
  }

  void goToRegister() {
    Get.toNamed('/register');
  }
}