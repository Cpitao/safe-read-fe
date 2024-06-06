import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cookie_store/cookie_store.dart';
import 'package:saferead/models/shelf.dart';

import 'models/document.dart';
import 'models/user.dart';

enum AuthStatus { unauthenticated, authenticated }

class BackendAPI extends ChangeNotifier {
  var _status = AuthStatus.unauthenticated;
  static const String baseURL = '';
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'cookie': '',
  };
  User? user;
  final _cookieStore = CookieStore();

  AuthStatus get status {
    return _status;
  }

  Future<User?> logIn(String username, String password) async {
    var body = jsonEncode({'username': username, 'password': password});
    final resp = await _post(Uri.parse('$baseURL/login'), body, headers);
    try {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return User(username: jsonDecode(resp.body)['username']!);
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<User?> signUp(String username, String email, String password) async {
    var body = jsonEncode({'username': username, 'password': password, 'email': email});
    final resp = await _post(Uri.parse('$baseURL/signup'), body, headers);    
    if (resp.statusCode == 409) {
      throw Exception(jsonDecode(resp.body)['err']);
    }
    return User(username: jsonDecode(resp.body)['username']!);
  }

  void logout() async {
    await _post(Uri.parse('$baseURL/logout'), null, headers);
  }

  Future<List<Shelf>?> getShelves() async {
    final resp = await _get(Uri.parse('$baseURL/shelf'), headers);

    if (resp.statusCode != 200) {
      return null;
    }
    List<Shelf> shelves = List.empty(growable: true);
    for (var s in jsonDecode(resp.body)) {
      var shelf = Shelf(s['name'], s['description']);
      shelves.add(shelf);
    }
    return shelves;
  }

  Future<List<Doc>?> getDocs(String shelfName) async {
    final resp = await _get(Uri.parse('$baseURL/shelf/$shelfName'), headers);

    if (resp.statusCode != 200) {
      return null;
    }
    List<Doc> docs = List.empty(growable: true);
    for (var s in jsonDecode(resp.body)) {
      var doc = Doc(s['title']);
      docs.add(doc);
    }
    return docs;
  }

  Future<Doc?> getDocument(String shelfName, String documentTitle) async {
    final dataResp = await _get(Uri.parse('$baseURL/shelf/$shelfName/$documentTitle'), headers);
    if (dataResp.statusCode != 200) {
      return null;
    }
    Uint8List docData = dataResp.bodyBytes;
    var doc = Doc(documentTitle, data: docData);
    if (dataResp.headers['page'] != null) {
      doc.currentPage = int.parse(dataResp.headers['page']!);
    }

    return doc;
  }

  Future<Shelf?> addShelf(String name, String description) async {
    var body = jsonEncode({
      'name': name,
      'description': description,
    });
    final resp = await _post(Uri.parse('$baseURL/shelf'), body, headers);
    if (resp.statusCode != 200) {
      return null;
    }
    return Shelf(resp.body, description);
  }

  void updatePageNumber(String shelf, String doc, int pageNumber) async {
    final body = jsonEncode({'page': pageNumber});
    await _put(Uri.parse('$baseURL/shelf/$shelf/$doc'), body, headers);
  }

  Future<int> getPageNumber(String shelf, String doc) async {
    final resp = await _get(Uri.parse('$baseURL/shelf/$shelf/$doc/page'), headers);
    final page = jsonDecode(resp.body)['page'];
    return page ?? 1;
  }

  Future<http.StreamedResponse> uploadFile(String shelfName, List<int> filename, List<int> content) async {
    String hexFilename = hex.encode(filename);
    Uri path = Uri.parse('$baseURL/shelf/$shelfName/$hexFilename');
    var request = http.MultipartRequest('POST', path)
      ..files.add(http.MultipartFile.fromBytes('file', content, filename: hexFilename))
      ..headers.addAll(headers);
    var resp = await request.send();
    if (resp.statusCode == 401) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
    if (resp.headers.containsKey('set-cookie')) {
        final domain = path.toString().split('/')[0];
        _cookieStore.updateCookies(resp.headers['set-cookie']!, domain, '/');
        headers['cookie'] = CookieStore.buildCookieHeader(_cookieStore.cookies);
        for (var c in _cookieStore.cookies) {
          if (c.name == 'csrf_access_token') {
            headers['X-CSRF-TOKEN'] = c.value;
          }
        }
    }
    return resp;
  }

  void deleteDocument(String shelf, String doc) async {
    await _delete(Uri.parse('$baseURL/shelf/$shelf/$doc'), null, headers);
  }

  Future<bool> deleteShelf(String shelf) async {
    final resp = await _delete(Uri.parse('$baseURL/shelf/$shelf'), null, headers);
    return resp.statusCode == 201;
  }

  Future<http.Response> _delete(Uri path, Object? body, Map<String, String>? headers) async {
    final resp = await http.delete(path, body: body, headers: headers);
    refreshHttpData(resp, path);
    return resp;
  }
  
  Future<http.Response> _put(Uri path, Object? body, Map<String, String>? headers) async {
    final resp = await http.put(path, body: body, headers: headers);
    refreshHttpData(resp, path);
    return resp;
  }

  Future<http.Response> _post(Uri path, Object? body, Map<String, String>? headers) async {
    final resp = await http.post(path, body: body, headers: headers);
    refreshHttpData(resp, path);
    return resp;
  }

  Future<http.Response> _get(Uri path, Map<String, String>? headers) async {
    final resp = await http.get(path, headers: headers);
    refreshHttpData(resp, path);
    return resp;
  }

  void refreshHttpData(http.Response resp, Uri path) {
    try {
      if (resp.headers.containsKey('set-cookie')) {
        final domain = path.toString().split('/')[0];
        _cookieStore.updateCookies(resp.headers['set-cookie']!, domain, '/');
        headers['cookie'] = CookieStore.buildCookieHeader(_cookieStore.cookies);
        for (var c in _cookieStore.cookies) {
          if (c.name == 'csrf_access_token') {
            headers['X-CSRF-TOKEN'] = c.value;
          }
        }
      }
    } finally {
      if (resp.statusCode == 401) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    }
  }
}