import 'dart:math';

import 'package:flutter/material.dart';
import 'package:saferead/pages/base_page.dart';

import '../auth_ui/login_form.dart';

class LoginPage extends BasePage {
  const LoginPage(super.api, {super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeRead'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.app_registration),
            tooltip: 'Sign up',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/register');
            }
          ),
        ]
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SizedBox(
              height: max(constraints.maxHeight / 2, 400),
              width: min(constraints.maxWidth, 300),
              child: LoginForm(api),
            );
          }
        )
      ),
      
    );
  }

}