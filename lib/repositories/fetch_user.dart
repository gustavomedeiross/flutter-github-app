import 'package:github_viewer/models/user.dart';
import 'package:http/http.dart' as http;

import 'dart:io';
import 'dart:convert';

import '../services/api.dart';

Future<User> fetchUser(String user) async {
  final http.Response response = await http.get('$api/users/$user');

  if (response.statusCode == 404) {
    throw HttpException('User not Found');
  }

  if (response.statusCode != 200) {
    throw HttpException('Error. Try Again Later');
  }

  return User.fromJson(json.decode(response.body));
}
