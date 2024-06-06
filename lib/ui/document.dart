import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:saferead/api.dart';
import 'package:saferead/models/document.dart';

class DocumentWidget extends StatelessWidget {
  final BackendAPI api;
  final SecretKey secretKey;
  late final Future<Doc?> document;
  final String shelfName;
  late final PdfViewerController _controller;
  late final PdfViewerParams _viewOptions;
  Future<Uint8List>? decrypted;

  DocumentWidget(this.api, this.shelfName, this.document, this.secretKey, { super.key }) {
    _controller = getController();
    _viewOptions = getParams();
  }

  PdfViewerController getController() {
    return PdfViewerController(
      
    );
  }

  PdfViewerParams getParams() {
    return PdfViewerParams(
      enableTextSelection: true,
      margin: 0,
      maxScale: 5,
      minScale: 0.2,
      onPageChanged:(pageNumber) async {
        final doc = await document;
        try {
          if (pageNumber == 1) return;
          api.updatePageNumber(shelfName, doc!.title, pageNumber!);
        // ignore: empty_catches
        } catch(e) {}
      },
      scrollByMouseWheel: 0.5,
      viewerOverlayBuilder: (context, size) {
        return <Widget>[
          PdfViewerScrollThumb(
            controller: _controller,
            orientation: ScrollbarOrientation.right,
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: document,
      builder: (context, document) {
        if (document.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                Text('Downloading the document'),
              ],
            ),
          );
        } else if (document.hasError || document.data == null) {
          return const Center(child: Text('Unable to retrieve the document, try again later'));
        }
        decrypted ??= document.data!.decryptDocument(secretKey);
        return FutureBuilder(
          future: decrypted!,
          builder: (context, decrypted) {
            if (decrypted.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    Text('Decrypting the document'),
                  ],
                ),
              );
            } else if (decrypted.hasError || decrypted.data == null) {
              return const Center(child: Text('Unable to decrypt the file'));
            }
            var viewer = PdfViewer.data(
              decrypted.data!,
              controller: _controller,
              sourceName: document.data!.title,
              params: _viewOptions,
              initialPageNumber: document.data!.currentPage,
            );
            
            return viewer;
          }
        );
      }
    );
  }
}