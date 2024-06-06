import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:saferead/crypto_utils.dart';
import 'package:saferead/key_manager.dart';
import 'package:saferead/pages/base_page.dart';

import '../ui/shelf.dart';

class ShelfPage extends BasePage {

  const ShelfPage(super.api, {super.key});

  @override
  Widget build(BuildContext context) {
    final keyProvider = Provider.of<KeyManager>(context);
    final shelfName = ModalRoute.of(context)!.settings.arguments as String;
    final shelfWidget = ShelfWidget(api, shelfName);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeRead'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Upload document',
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                dialogTitle: 'Upload document',
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );
              if (result != null) {
                try {
                  File file = File(result.files.single.path!);
                  SecretKey secretKey = keyProvider.keys[shelfName]!;
                  List<int> encryptedFilename = await encryptUtil(secretKey, basename(file.path).codeUnits);
                  List<int> encryptedContent = await encryptUtil(secretKey, file.readAsBytesSync());
                  final resp = api.uploadFile(shelfName, encryptedFilename, encryptedContent);
                  if ((await resp).statusCode == 413) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          title: Text('File too large'),
                          content: Text('Try uploading smaller files'),
                        );
                      }
                    );
                    return;
                  }
                  shelfWidget.refresh();
                } catch(e) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      Navigator.popAndPushNamed(context, '/');
                      return const AlertDialog(
                        title: Text('Error encrypting file, try again.'),
                        content: Text('Have you entered the password?'),
                      );
                    }
                  );
                }
              }
            }
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              shelfWidget.refresh();
            },
          ),
        ]
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: shelfWidget,
            );
          }
        ),
    );
  }

}