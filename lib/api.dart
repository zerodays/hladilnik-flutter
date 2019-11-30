import 'dart:convert';

import 'package:http/http.dart' as http;

class User {
  int id;
  String name;
  double balance;

  User(this.id, this.name, this.balance);

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    balance = json['balance'];
  }

  String toString() {
    return 'User "$name" with balance $balance';
  }
}

class Api {
  static final Api _api = Api._internal();

//  static final String _baseUrl = 'http://10.0.2.2:8000/api/';
//  static final String _baseUrl = 'http://192.168.1.14:8000/api/';
  static final String _baseUrl = 'https://hladilnik.recompile.it/api/';

  bool hasData = false;
  List<User> users = [];
  bool loading = false;

  factory Api() {
    return _api;
  }

  Api._internal();

  void _parseResponseBody(String body) {
    List<dynamic> data = json.decode(body);
    this.users =
        data.map((d) => User.fromJson(d as Map<String, dynamic>)).toList();
  }

  Future<bool> getData() async {
    if (loading) return false;
    loading = true;

    String url = _baseUrl + 'users';

    http.Response response;
    try {
      response = await http.get(url);
    } catch (e) {
      print(e);

      loading = false;
      return false;
    }

    if (response.statusCode != 200) {
      loading = false;
      return false;
    }

    _parseResponseBody(response.body);

    hasData = true;
    loading = false;

    return true;
  }

  Future<bool> addBalance(int userId, double amount) async {
    Map<String, dynamic> data = {
      'id': userId,
      'balance': amount,
    };
    String body = json.encode(data);

    String url = _baseUrl + 'add_balance';

    http.Response response;

    try {
      response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
        encoding: utf8,
      );
    } catch (e) {
      return false;
    }

    if (response.statusCode != 200) {
      return false;
    }

    _parseResponseBody(response.body);
    hasData = true;

    return true;
  }
}
