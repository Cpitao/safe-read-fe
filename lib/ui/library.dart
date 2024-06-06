import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saferead/api.dart';
import 'package:saferead/components/shelves.dart';

class Library extends StatelessWidget {
  final BackendAPI api;
  
  const Library(this.api, { super.key });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<Shelves>(
      builder: (context, shelves, child) => FutureBuilder(
        future: shelves.shelves,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Cannot get the data, try again later'));
          }
          List<Widget> shelfWidgets = snapshot.data!.map((e) {
            return Container(
              height: 100,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 53, 58, 63),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushNamed(context, '/shelf', arguments: e.name);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                            overflow: TextOverflow.clip,
                            style: const TextStyle(fontSize: 20),
                            e.name,
                          )
                      ),
                      Expanded(
                        flex: 7,
                        child: Text(
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 18),
                            e.name,
                          )
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
                                  title: const Text('Delete entire shelf? This will delete all documents inside!'),
                                  content: ElevatedButton(
                                    child: const Text('Confirm'),
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                  )
                                );
                              },
                            );
                            if (userChoice != null && userChoice) {
                              await api.deleteShelf(e.name);
                              shelves.refresh();
                            }
                          },
                        ),
                      )
                    ],
                  ),
              ),
            ),
          );
          }).toList();
          return ListView(
            padding: const EdgeInsets.all(8),
            children: shelfWidgets);
        }
      ),
    );
  }

  
}