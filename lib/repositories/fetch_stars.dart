import 'package:github_viewer/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:github_viewer/models/star.dart';
import 'dart:io';
import 'dart:convert';

import '../services/api.dart';

Future<List<Star>> fetchStars({User user, int page = 1}) async {
  final http.Response response = await http.get('$api/users/${user.login}/starred?page=$page&per_page=20');

  if (response.statusCode != 200) {
    throw HttpException('Error. Try Again Later');
  }

  final List parsedStars = json.decode(response.body);

  final List<Star> stars = parsedStars.map((star) => Star.fromJson(star)).toList();

  return stars;
}