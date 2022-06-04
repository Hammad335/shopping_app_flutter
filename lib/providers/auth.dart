import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _tokenExpiryDate;
  String? _userId;
  Timer? _authTimer;

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB0JdWX7P7s_uTmJ2cNeihc8n9NWGArB9Q');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      // manually handling errors of status code less than 200
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw Exception(responseData['error']['message']);
      }

      // storing token received in responseData
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _tokenExpiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout(); // logout automatically when token expires
      notifyListeners();
    } catch (exception) {
      rethrow;
    }
  }

  bool get isAuthenticated {
    return _token != null;
  }

  String get getToken {
    if (_tokenExpiryDate != null &&
        _tokenExpiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token!;
    }
    return '';
  }

  String get getUserId {
    return _userId ?? '';
  }

  void logout() {
    _token = null;
    _userId = null;
    _tokenExpiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpire = _tokenExpiryDate?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire!), logout);
  }
}
