import 'package:flutter/material.dart';
import 'package:saferead/api.dart';
import 'package:saferead/models/document.dart';

class Docs extends ChangeNotifier {
  late Future<List<Doc>?> docs;
  late final String shelf;
  late final BackendAPI _api;

  Docs(this._api, this.shelf) {
    docs = _api.getDocs(shelf);
  }

  void refresh() {
    docs = _api.getDocs(shelf);
    notifyListeners();
  }
}