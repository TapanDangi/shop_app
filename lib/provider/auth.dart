import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }
  //returns true meaning we have a token.
  //returns false meaningtoken is null.

  String? get token {
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }
  //tells us whether we have a available token or not within its expiryDate and returns the token

  String? get userId {
    return _userId;
  }

  static const param = {
    'key': 'AIzaSyCbu7tWhw0tcRQNz3q5kKZFcPjkhecpugc',
  };

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.https(
        'identitytoolkit.googleapis.com', '/v1/accounts:$urlSegment', param);
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
      if (responseData['error'] != null) {
        //means that an error exists
        throw HttpException(responseData['error']['message']);
      }
      //if an error is not encountered, then
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
          //responseData is String but seconds arguments takes an int type.
          //So, we have to parse the data to convert it to String.
        ),
      );
      _autoLogout();
      notifyListeners();
      final preferences = await SharedPreferences.getInstance();
      //getInstance() returns a Future which resolves to type SharedPreferenes.
      //await is used so that we don't store the Future in the preferences variable but the
      //real access to SharedPrefernces since SharedPreferences is used for on-device strorage.
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      //json.encode converts complex map into a String. It is used since setString method requires
      //string as an argument.
      preferences.setString('userData', userData);
      //setString method is used to save the userData in the persistent storage.
      //it can be retrieved with the help of the corresponding key for the String value.
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
    //if we don't return _authenticate, it will also return a Future but that would not
    //wait for the Future of _authenticate to do its job and loading spinner will not work.
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey('userData')) {
      return false;
    }
    //if there is no data stored under userData key, this function returns a Future with false value.
    final extractedUserData =
        json.decode(preferences.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    //this checks returns false if the token is not valid.
    //Past this check, we know we have valid data, so we want to auto login the user.
    //So, all the properties like token, userId and expiryDate are re-initialised.
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
    //if the previous checks are completed, this function returns true which means
    //that we have a token that is valid.
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    //if user chooses to logout, any ongoing timer should be cancelled.
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    preferences.clear();
    //clear all the app's data from SharedPreferences.
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
      //cancel() function cancels a timer. The callback function will not be called by Timer.
      //this is used to cancel existing timers, if available, in order to setup a new timer.
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    //difference method gives us the difference between two timestamps.
    //here, it gives difference between expiryDate and DateTime.now().
    //inSeconds method gives the difference in terms of seconds.
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    //this shows that logout() function is called automatically invoked after the set Duration.
  }
}
