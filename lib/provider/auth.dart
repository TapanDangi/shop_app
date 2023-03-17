import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  late String _token;
  late DateTime _expiryDate;
  late String _userId;

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
}
