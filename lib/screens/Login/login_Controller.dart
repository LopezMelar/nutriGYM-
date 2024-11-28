import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void Login(BuildContext context) {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print('Email: $email');
    print('Password: $password');

    if (isValidForm(email, password)) {
      Get.snackbar('Formulario válido', 'Estado 200');
      Get.toNamed('/Aqui tiene que navegar a la vista de en usaurio ');
    }
  }

  bool isValidForm(String email, String password) {
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Formulario no válido', 'Por favor ingrese un email válido');
      return false;
    }

    if (email.isEmpty) {
      Get.snackbar('Formulario no válido', 'Por favor ingresa un email');
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar('Formulario no válido', 'Por favor ingresa una contraseña válida');
      return false;
    }

    return true;
  }

  void goToRegisterPage() {
    Get.toNamed('/aqui es para registrarse');
  }
}
