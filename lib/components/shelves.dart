import 'package:flutter/material.dart';
import 'package:saferead/api.dart';
import 'package:saferead/models/shelf.dart';

class Shelves extends ChangeNotifier {
  late Future<List<Shelf>?> shelves;
  late final BackendAPI _api;

  Shelves(this._api) {
    shelves = _api.getShelves();
  }

  void refresh() {
    shelves = _api.getShelves();
    notifyListeners();
  }
}