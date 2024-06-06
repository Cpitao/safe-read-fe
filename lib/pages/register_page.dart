import 'dart:math';

import 'package:flutter/material.dart';
import 'package:saferead/auth_ui/register_form.dart';
import 'package:saferead/pages/base_page.dart';

import 'login_page.dart';

class RegisterPage extends BasePage {
  const RegisterPage(super.api, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeRead'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.login),
            tooltip: 'Sign in',
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (BuildContext context) {
                  return LoginPage(api);
                }
                )
              );
            }
          )
        ]
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SizedBox(
              height: max(constraints.maxHeight / 2, 400),
              width: min(constraints.maxWidth, 300),
              child: RegisterForm(api),
            );
          }
        )
      )
    );
  }

}