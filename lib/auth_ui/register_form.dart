
import 'package:flutter/material.dart';

import '../api.dart';

class RegisterForm extends StatefulWidget {
  final BackendAPI api;
  const RegisterForm(this.api, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegisterFormState(api);
  }
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final BackendAPI api;
  final Map<String, String?> userData = {
    'username': null,
    'password': null,
    'email': null,
  };
  
  _RegisterFormState(this.api);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            validator:(value) {
              
              final r = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (value == null || !r.hasMatch(value)) {
                return 'Invalid email';
              }
              return null;
            },
            onChanged: (value) => userData['email'] = value,
            decoration: const InputDecoration(
              icon: Icon(Icons.mail),
              labelText: 'Mail',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    var user = await api.signUp(userData['username']!, userData['email']!, userData['password']!);
                    api.user = user!;
                    Navigator.pushReplacementNamed(
                      context,
                      '/',
                    );
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => const AlertDialog(
                        title: Text('Registration successful'),
                        content: Text('Log in to continue'),
                      ),
                    );
                  } catch(e) {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Registration error'),
                        content: Text(e.toString().substring(11)),
                      )
                    );
                    return;
                  }
                }
              },
              child: const Text('Submit'),
            )
          )
        ]
      )
    );
  }
}