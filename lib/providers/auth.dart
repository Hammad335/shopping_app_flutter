import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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
      final response = await http
          .post(url,
              body: json.encode(
                {
                  'email': email,
                  'password': password,
                  'returnSecureToken': true,
                },
              ))
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Slow internet connection, try again later.');
      });
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

      // storing login details using shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _tokenExpiryDate?.toIso8601String(),
      });
      prefs.setString('userData', userData);
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

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _tokenExpiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();

    // removing prefs data on logout
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpire = _tokenExpiryDate?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire!), logout);
  }

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('userData')) {
        return false;
      }
      final extractedUserData =
          json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
      final expiryDate =
          DateTime.parse(extractedUserData['expiryDate'].toString());
      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      }
      _token = extractedUserData['token'].toString();
      _userId = extractedUserData['userId'].toString();
      _tokenExpiryDate = expiryDate;
      notifyListeners();
      _autoLogout();
      return true;
    } catch (exception) {
      print(exception.toString());
      return false;
    }
  }

  bool isAdmin() {
    const String _adminUid = 'I6T2AS4jFkdIJTsPbCEGCKTz54F3';
    return _userId == _adminUid;
  }
}
