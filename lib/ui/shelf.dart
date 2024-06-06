import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferead/api.dart';
import 'package:saferead/components/docs.dart';
import 'package:saferead/key_manager.dart';
import 'package:saferead/models/document.dart';

import '../crypto_utils.dart';

class ShelfWidget extends StatelessWidget {
  late final Docs _docs;
  final BackendAPI api;
  final String shelfName;

  ShelfWidget(this.api, this.shelfName, { super.key }) {
    _docs = Docs(api, shelfName);
  }

  void refresh() {
    _docs.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final keyProvider = Provider.of<KeyManager>(context);
    final controller = TextEditingController();
    if (keyProvider.keys[shelfName] == null) {
      return AlertDialog(
          title: const Text('Enter password'),
          content: Stack(
            children: [
              const Text('No valid password for the current shelf provided.'),
              TextField(
                controller: controller,
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                SecretKey secretKey = await getKey(api.user!.username, controller.text);
                keyProvider.keys[shelfName] = secretKey;
                Navigator.popAndPushNamed(context, '/shelf', arguments: shelfName);
              },
              child: const Text('Submit'),
            ),
          ],
        );
    } 
    return ChangeNotifierProvider.value(
      value: _docs,
      child: Consumer<Docs>(
        builder:(context, docs, child) => FutureBuilder(
          future: docs.docs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Center(child: Text('Cannot get the data, try again later'));
            }
            
            return ListView(
                  padding: const EdgeInsets.all(8),
                  children: getShelfWidgets(context, snapshot, keyProvider),
            );
          }
        ),
      ),
    );
  }

  List<Widget> getShelfWidgets(context, AsyncSnapshot<List<Doc>?> snapshot, KeyManager keyProvider) {
    return snapshot.data!.map((e) {
      return Container(
        height: 100,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 53, 58, 63),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pushNamed(context, '/document', 
              arguments: {
                'shelfName': shelfName,
                'docTitle': e.title,
                'secretKey': keyProvider.keys[shelfName] 
              });
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FutureBuilder(
              future: e.decryptTitle(keyProvider.keys[shelfName]!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError || snapshot.data == null) {
                  if (snapshot.error is SecretBoxAuthenticationError) {
                    keyProvider.keys.remove(shelfName);
                    Future.delayed(Duration.zero, () => Navigator.popAndPushNamed(context, '/shelf', arguments: shelfName));
                  }
                  return const Text('Error decrypting title');
                }
                return Row(
                  children: [
                    Expanded(
                      flex: 9,
                      child:  Text(
                        overflow: TextOverflow.clip,
                        style: const TextStyle(fontSize: 20),
                        snapshot.data!,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          var userChoice = await showDialog(
                            context: context,
                            builder:(context) {
                              return AlertDialog(
                                title: const Text('Delete the document?'),
                                content: ElevatedButton(
                                  child: const Text('Confirm'),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                )
                              );
                            },
                          );
                          if (userChoice != null && userChoice!) {
                            api.deleteDocument(shelfName, e.title);
                            _docs.refresh();
                          }
                        },
                      )
                    ),
                  ]
                );
              }
            ),
          ),
        ),
      );
    }).toList();
  }
}