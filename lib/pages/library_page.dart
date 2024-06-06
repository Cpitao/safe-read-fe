import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferead/components/shelves.dart';
import 'package:saferead/pages/base_page.dart';

import '../ui/library.dart';


class LibraryPage extends BasePage {
  late final Shelves shelves;
  final _shelfFormKey = GlobalKey<FormState>();
  final shelfData = {
    'name': null,
    'description': '',
    'password': '',
  };
  
  LibraryPage(super.api, {super.key}) {
    shelves = Shelves(api);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeRead'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add shelf',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Center(
                    child: Form(
                      key: _shelfFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Shelf name can\'t be empty';
                              }
                              return null;
                            },
                            onChanged:(value) => shelfData['username'] = value,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.shelves),
                              labelText: 'Shelf name',
                            ),
                          ),
                          TextFormField(
                            onChanged: (value) => shelfData['description'] = value,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.description),
                              labelText: 'Description',
                            ),
                            maxLines: 5,
                            minLines: 5
                          ),
                          TextFormField(
                            onChanged: (value) => shelfData['password'] = value,
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
                                  if (_shelfFormKey.currentState!.validate()) {
                                    await api.addShelf(shelfData['username']!, shelfData['description']!);
                                    shelves.refresh();
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Submit'),
                              ),
                          )
                        ]
                      ),
                    ),
                  ),
                )
              );
            }
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              shelves.refresh();
            },
          ),
        ]
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: ChangeNotifierProvider.value(
                value: shelves,
                child: Library(api),
              )
            );
          }
        ),
    );
  }

}