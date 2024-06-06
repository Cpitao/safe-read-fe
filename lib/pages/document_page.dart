import 'dart:io' show Platform;
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:saferead/models/document.dart';

import '../ui/document.dart';
import 'base_page.dart';

class DocumentPage extends BasePage {
  Future<Doc?>? document;
  DocumentWidget? docWidget;
  DocumentPage(super.api, {super.key});

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments as Map<String, Object?>;
    String shelfName = args['shelfName']! as String;
    String docTitle = args['docTitle']! as String;
    SecretKey secretKey = args['secretKey'] as SecretKey;
    document ??= api.getDocument(shelfName, docTitle);
    docWidget ??= DocumentWidget(api, shelfName, document!, secretKey);
    var appBar = Platform.isAndroid ? null : AppBar(
      title: const Text('SafeRead'),
    );
    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: docWidget,
          );
        }
      ),
    );
  }

}