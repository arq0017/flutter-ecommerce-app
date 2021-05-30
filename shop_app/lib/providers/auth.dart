import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shop_app/model/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  //! for checking if user is logged in
  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  //! for checking if token is valid or not
  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    // firebase auth endpoint
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBbSWs2GUuHHvcsivLuNKhh6RrCdtXuSiM');
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
      final responseData = json.decode(response.body);
      // error exists - fire base authentication error is not an error . It's a json obj .
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();

      final preferences = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiresIn': _expiryDate.toIso8601String(),
      });
      preferences.setString('userData', userData);
    } catch (error) {
      return Future.error(error);
    }
  }

  // SignUp
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  // SignIn
  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  // login
  Future<bool> autoLogin() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('userData')) return false;
    //! extracting user data
    final extractUserData = await json.decode(preferences.getString('userData'))
        as Map<String, dynamic>;
    //! checking expiry date for token validation
    final expiryDate = DateTime.parse(extractUserData['expiresIn']);
    if (expiryDate.isBefore(DateTime.now())) return false;
    _token = extractUserData['token'];
    _userId = extractUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  // method for deleting saved data

  // logout
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  // auto logout
  Future<void> _autoLogout() async {
    if (_authTimer != null) _authTimer.cancel();
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
