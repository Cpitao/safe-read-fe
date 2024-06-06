import 'package:flutter/material.dart';

import '../api.dart';

class LoginForm extends StatefulWidget {
  final BackendAPI api;
  const LoginForm(this.api, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginFormState(api);
  }
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final BackendAPI api;
  final Map<String, String?> userData = {
    'username': null,
    'password': null,
  };
  
  _LoginFormState(this.api) {
    userData['username'] = api.user?.username == null ? '' : api.user!.username;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Username field can\'t be empty';
              }
              return null;
            },
            onChanged:(value) => userData['username'] = value,
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              labelText: 'Username',
            ),
            initialValue: api.user?.username == null ? '' : api.user!.username,
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password field can\'t be empty';
              }
              return null;
            },
            onChanged: (value) => userData['password'] = value,
            obscureText: true,
            decoration: const InputDecoration(
              icon: Icon(Icons.password),
              labelText: 'Password',
            )
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child:
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var user = await api.logIn(userData['username']!, userData['password']!);
                    api.user = user;
                    if (user == null) {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => const AlertDialog(
                          title: Text('Login error'),
                          content: Text('Invalid username or password'),
                        )
                      );
                      return;
                    }
                  }
                },
                child: const Text('Submit'),
              ),
          )
        ]
      )
    );
  }
}